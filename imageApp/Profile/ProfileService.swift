import UIKit

final class ProfileService {
    
    static let shared = ProfileService()
    private var currentTask: URLSessionTask?
    private var lastToken: String?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    private let builder = URLRequestBuilder.shared
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread, "Not in Main thread")
        if currentTask != nil {
            if lastToken != token {
                currentTask?.cancel()
            } else {
                if lastToken == token {
                    completion(.failure(AuthServiceError.invalidRequest))
                }
            }
            lastToken = token
        }
        guard let request: URLRequest = makeProfileRequest() else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) {
            [weak self] (response: Result<ProfileResult, Error>) in
            
            guard let self else { return }
            switch response {
            case .success(let profileResult):
                let profile = Profile(result: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Profile service error in \(#function): error = \(error)")
                completion(.failure(error))
            }
            self.currentTask = nil
            self.lastToken = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    func makeProfileRequest() -> URLRequest? {
        builder.makeHTTPRequest(
            path: "/me",
            httpMethod: "GET",
            baseURLString: Constants.defaultBaseAPIURLString
        )
    }
}
