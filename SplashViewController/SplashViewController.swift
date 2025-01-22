import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.shared
    private let profileImageService = ProfileImageService.shared
    private var authenticateStatus = false
    private var splashScreenLogoImageView: UIImageView?
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticate()
        //        if oauth2TokenStorage.token != nil {
        //            switchToTabBarController()
        //        } else {
        //            performSegue(withIdentifier: Constants.showAuthenticationScreenSegueIdentifier, sender: nil)
        //        }
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                break
            }
        }
    }
    private func fetchProfile(completion: @escaping () -> Void) {
        guard let token = storage.token else { return }
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.switchToTabBarController()
                let username = profile.userName
                self.fetchProfileImageURL(username: username)
            case .failure(let error):
                print("Fetch token error in \(#function): error = \(error)")
                self.showLoginAlert()
            }
            completion()
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfileImageURL(with: username) { result in
            switch result {
            case .success(let imageURL):
                print("imageURL - \(imageURL)")
            case .failure(let error):
                print("Fetch image error in \(#function): error = \(error)")
                self.showLoginAlert()
            }
        }
    }
    
    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard
            let navigationViewController = storyboard.instantiateViewController(withIdentifier: Constants.navigationController) as? UINavigationController,
            let authViewController = navigationViewController.topViewController as? AuthViewController
        else {
            print("Failed to create AuthViewController \(#function)")
            return
        }
        authViewController.delegate = self
        navigationViewController.modalPresentationStyle = .fullScreen
        present(navigationViewController, animated: true) {
        }
    }
    
    private func isAuthenticated() {
        guard !authenticateStatus else { return }
        
        authenticateStatus = true
        if storage.token != nil {
            UIBlockingProgressHUD.show()
            fetchProfile { [weak self] in
                guard let self else { return }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            }
        } else {
            showAuthController()
        }
    }
    private func setSplashScreenLogoImageView() {
        let splashScreenLogoImageView = UIImageView()
        let splashScreenLogo = UIImage(named: "splashScreenLogo")
        splashScreenLogoImageView.image = splashScreenLogo
        splashScreenLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenLogoImageView)
        splashScreenLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splashScreenLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        splashScreenLogoImageView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        splashScreenLogoImageView.widthAnchor.constraint(equalToConstant: 72).isActive = true
        self.splashScreenLogoImageView = splashScreenLogoImageView
    }
    
    private func setupSplashScreen() {
        setSplashScreenLogoImageView()
        view.backgroundColor = .ypBlack
    }
    
    private func authenticate() {
        guard !authenticateStatus else { return }
        authenticateStatus = true
        if storage.token != nil {
            UIBlockingProgressHUD.show()
            fetchProfile { [weak self] in
                guard let self else { return }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()}
        } else {
            showAuthController()
        }
    }
}

// MARK: - Extension
extension SplashViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constants.showAuthenticationScreenSegueIdentifier, sender: nil)
    }
}

//extension SplashViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showAuthenticationScreenSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
//            viewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
        }
    }
    private func showLoginAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { preconditionFailure("weak self error")}
            let alertModel = AlertModel(
                title: "Что-то пошло не так(",
                message: "Не удалось войти в систему",
                buttonText: "Ок"
            ) { [weak self] in
                guard let self else { preconditionFailure("weak self error")}
                self.authenticateStatus = false
                self.isAuthenticated()
            }
            AlertPresenter.showAlert(model: alertModel, vc: self)
        }
    }
}
