import Foundation

final class URLRequestBuilder {
    
    static let shared = URLRequestBuilder()
    
    private let storage: OAuth2TokenStorage
    private init(storage: OAuth2TokenStorage = .shared) {
        self.storage = storage
    }
    
    func makeHTTPRequest(path: String, httpMethod: String, baseURLString: String) -> URLRequest? {
        guard
            let url = URL(string: baseURLString),
            let baseUrl = URL(string: path, relativeTo: url)
        else {
            print("url or baseUrl creation failed in \(#function): baseURLString = \(baseURLString), path = \(path)")
            return nil
        }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = httpMethod
        
        if let token = storage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
