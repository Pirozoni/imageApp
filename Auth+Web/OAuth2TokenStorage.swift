import Foundation

final class OAuth2TokenStorage {
    var token: String? {
        get { storage.string(forKey: Keys.token.rawValue) }
        set { storage.set(newValue, forKey: Keys.token.rawValue) }
    }
    
    private enum Keys: String {
        case token
    }
    
    static let shared = OAuth2TokenStorage()
    private let storage = UserDefaults.standard
    
    private init(){}
}
