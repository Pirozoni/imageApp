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
        let alertFirstAction = UIAlertAction(title: model.firstButtonText, style: .default) { _ in
            model.completion()
        }
        alertController.addAction(alertFirstAction)
        
        if model.secondButtonText != nil {
            let alertSecondAction = UIAlertAction(title: model.secondButtonText, style: .default) { _ in
                vc.dismiss(animated: true)
            }
            alertController.addAction(alertSecondAction)
        }
        
        vc.present(alertController, animated: true, completion: nil)
    }
}
