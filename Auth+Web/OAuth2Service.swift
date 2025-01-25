import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Public Properties
    static let shared = OAuth2Service()
    var isAuthenticated: Bool {
        storage.token != nil
    }
    
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private let builder = URLRequestBuilder.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread, "Not in Main thread")
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        guard let request: URLRequest = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) {
            [weak self] (response: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            switch response {
            case .success(let responseBody):
                let authToken = responseBody.accessToken
                self.storage.token = authToken
                completion(.success(authToken))
            case .failure(let error):
                print("OAuth2Service Error in \(#function): error = \(error)")
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashGetTokenURLString) else {
            print("Логирование ошибки: failed URL components")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: Constants.grantType)
        ]
        guard let url = urlComponents.url?.absoluteString else {
            print("Логирование ошибки: failed group of URL components in \(#function)")
            assertionFailure("Failed to create URL")
            return nil
        }
        let request = builder.makeHTTPRequest(path: url, httpMethod: "POST", baseURLString: Constants.defaultBaseURLString)
        
        return request
    }
}
