import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
           guard var urlComponents = URLComponents(string: Constants.unsplashGetTokenURLString) else {
               print("Логирование ошибки")
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
               print("Логирование ошибки")
               return nil
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           
           print("Request for makeOAuthTokenRequest method \(request)")
           
           return request
       }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
          guard let request: URLRequest = makeOAuthTokenRequest(code: code) else { return }
          
          let task = urlSession.data(for: request) { [weak self] result in
              guard let self else { return }
              
              switch result {
              case .success(let data):
                  do {
                      let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                      print(responseBody)
                      print(responseBody.accessToken)
                      self.storage.token = responseBody.accessToken
                      completion(.success(responseBody.accessToken))
                  } catch {
                      completion(.failure(error))
                  }
              case .failure(let error):
                  completion(.failure(error))
              }
          }
          task.resume()
      }
}
