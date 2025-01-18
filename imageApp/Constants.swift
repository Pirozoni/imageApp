import Foundation

enum Constants {
    static let accessKey = "HnCc_DGGc8Qk2_JdYReDmWzOXwKL1rnLmUD1PyEcqzQ"
    static let secretKey = "QK64AoZAj5XuE0-WDMEi-rMnWAaIpnTLRBYkyFEP5A0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let grantType = "authorization_code"
    
    static private var defaultBaseURLchecker: URL {
            guard let url = URL(string: "https://api.unsplash.com") else { preconditionFailure("Unable to construct unsplashUrl") }
            return url
        }
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashGetTokenURLString = "https://unsplash.com/oauth/token"
    static let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
//    static let tabBarViewController = "TabBarViewController"
}
