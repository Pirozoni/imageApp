import UIKit

protocol AlertPresenterProtocol {
    static func showAlert(model: AlertModel, vc: UIViewController)
}

final class AlertPresenter: AlertPresenterProtocol {
    
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
        vc.present(alertController, animated: true, completion: nil)
    }
}
