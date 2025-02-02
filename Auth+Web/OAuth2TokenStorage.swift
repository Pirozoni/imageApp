import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    var token: String? {
        get {
            let token: String? = KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
            return token
        }
        set {
            guard let token = newValue else { preconditionFailure("Token doesn't exist") }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            guard isSuccess else { preconditionFailure("Token didn't save") }
        }
    }
    
    private enum Keys: String {
        case token = "Auth token"
    }
    
    static let shared = OAuth2TokenStorage()
    
    private init() {}
}
