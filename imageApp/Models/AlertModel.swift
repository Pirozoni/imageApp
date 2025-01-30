import Foundation

struct AlertModel {
    
    let title: String
    let message: String
    let firstButtonText: String
    let secondButtonText: String?
    let completion: (() -> Void)
}
