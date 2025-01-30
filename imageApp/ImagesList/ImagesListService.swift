import Foundation

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private let builder = URLRequestBuilder.shared
    private var dataTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private var pageCount: Int? //?
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    func clearPhotos() {
        photos.removeAll()
        pageCount = nil
    }
    
    func fetchPhotosNextPage(completion: @escaping (Result<[PhotoResult], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makePhotosRequest() else {
            print(NetworkError.urlRequestError)
            return
        }
        guard dataTask == nil else { return }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                response.forEach { response in
                    self.photos.append(Photo(from: response))
                }
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                let nextPage = (pageCount ?? 0) + 1
                self.dataTask = nil
                self.pageCount = nextPage
            case .failure(let error):
                print("ImageListService Error in \(#function): error = \(error)")
            }
            self.dataTask = nil
            completion(result)
        }
        self.dataTask = task
        task.resume()
    }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        likeTask?.cancel()
        
        assert(Thread.isMainThread)
        guard let request = makeLikeRequest(id: photoId, isLiked: isLike) else {
            print(NetworkError.urlRequestError)
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeModel, Error>) in
            guard let self else { return }
            switch result {
            case .success(let isLikedPhoto):
                let currentLike = isLikedPhoto.photo.likedByUser
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: currentLike
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(currentLike))
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            case .failure(let error):
                print("ImageListService Error in \(#function): error = \(error)")
            }
        }
        self.likeTask = task
        task.resume()
    }
    
    private func makePhotosRequest() -> URLRequest? {
        let nextPage = (pageCount ?? 0) + 1
        pageCount = nextPage
        
        guard var urlComponents = URLComponents(string: Constants.defaultBaseAPIURLString + "/photos") else {
            print("Failed construct URL in \(#function)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: nextPage.description)
        ]
        
        guard let url = urlComponents.url?.absoluteString else {
            print("Failed construct URL in \(#function)")
            assertionFailure("Failed to create URL")
            return nil
        }
        
        let request = builder.makeHTTPRequest(path: url, httpMethod: "GET", baseURLString: Constants.defaultBaseAPIURLString)
        return request
    }
    private func makeLikeRequest(id: String, isLiked: Bool) -> URLRequest? {
        guard
            let urlComponents = URLComponents(string: Constants.defaultBaseAPIURLString + "/photos/\(id)/like"),
            let url = urlComponents.url?.absoluteString
        else {
            print("Failed construct URL in \(#function)")
            return nil
        }
        
        let httpMethod = isLiked ? "POST" : "DELETE"
        let request = builder.makeHTTPRequest(path: url, httpMethod: httpMethod, baseURLString: Constants.defaultBaseAPIURLString)
        
        return request
    }
}
