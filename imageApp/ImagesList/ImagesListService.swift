import Foundation

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let urlSession = URLSession.shared
    private let builder = URLRequestBuilder.shared
    private var dataTask: URLSessionTask?
    private var likeTask: URLSessionTask?
    private var pageCount: Int?
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    func fetchPhotosNextPage(completion: @escaping (Result<[PhotoResult], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makePhotosRequest() else {
            print(NetworkError.urlRequestError)
            return
        }
        guard dataTask == nil else { return }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
        }
        self.dataTask = task
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
}
