import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let ImageListService = ImagesListService.shared
    private init() {}
    
    func logout() {
        cleanCookies()
        cleanToken()
        clearProfileImage()
        clearImageListImages()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "Auth token")
        guard removeSuccessful else {
            print("Error in \(#function): token not removed")
            return
        }
    }
    
    private func clearProfileImage() {
        profileImageService.clearAvatarURL()
    }
    
    private func clearImageListImages() {
        ImageListService.clearPhotos()
    }
}
