import Foundation

struct Profile {
    // MARK: - Public Properties
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

// MARK: - Initialiser Extension
extension Profile {
    init(result profile: ProfileResult) {
        self.init(
            username: profile.username,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.username)",
            bio: profile.bio
        )
    }
}
