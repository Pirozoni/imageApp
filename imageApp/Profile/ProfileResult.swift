import Foundation

struct ProfileResult: Codable {
    
    let userLogin: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
            case userLogin = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
            case profileImage = "profile_image"
        }
}
