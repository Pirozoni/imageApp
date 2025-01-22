import UIKit

protocol AlertPresenterProtocol {
    static func showAlert(model: AlertModel, vc: UIViewController)
}

class AlertPresenter: AlertPresenterProtocol {
    
    private init() { }
    
    static func showAlert(model: AlertModel, vc: UIViewController) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let alertAction = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        alertController.addAction(alertAction)
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alertController, animated: true, completion: nil)
        } else {
            vc.present(alertController, animated: true, completion: nil)
        }
        vc.present(alertController, animated: true, completion: nil)
    }
}
