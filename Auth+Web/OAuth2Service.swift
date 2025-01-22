import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Private Properties
    static let shared = OAuth2Service()
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
        guard let url = urlComponents.url else {
            print("Логирование ошибки: failed group of URL components")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print("Request for makeOAuthTokenRequest method \(request)")
        
        return request
    }
    
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
        
        guard let request: URLRequest = makeOAuthTokenRequest(code: code) else { return }
        
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
    //        let task = urlSession.objectTask(for: request) { [weak self] result in
    //            guard let self else { return }
    //
    //            switch result {
    //            case .success(let data):
    //                do {
    //                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
    //                    self.storage.token = responseBody.accessToken
    //                    completion(.success(responseBody.accessToken))
    //                } catch {
    //                    print("Логирование ошибки: decode failure")
    //                    completion(.failure(error))
    //                }
    //            case .failure(let error):
    //                print("Логирование ошибки: failure")
    //                completion(.failure(error))
    //            }
    //        }
    //        task.resume()
}
