import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileLogoutService = ProfileLogoutService.shared
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "UserPhoto")
        return view
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "Exit")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 23.0)
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        return label
        
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        return label
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        drawSelf()
        setupView()
        updateProfileDetails()
        
        if let url = profileImageService.avatarURL {
            updateAvatar(url: url)
        }
        addProfileImageObserver()
    }
    
    // MARK: - Private Methods
    private func avatarImageViewConstrains() -> [NSLayoutConstraint] {
        return [
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor, multiplier: 1.0/1.0)
        ]
    }
    
    private func logoutButtonConstrains() -> [NSLayoutConstraint] {
        return [
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ]
    }
    
    private func nameLabelConstrains() ->[NSLayoutConstraint] {
        return [
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ]
    }
    
    private func loginNameLabelConstrains() -> [NSLayoutConstraint] {
        return [
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ]
    }
    
    private func descriptionLabelConstrains() -> [NSLayoutConstraint] {
        return [
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ]
    }
    
    private func drawSelf() {
        [avatarImageView, logoutButton, nameLabel, loginNameLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        let avatarImageViewConstrains = self.avatarImageViewConstrains()
        let logoutButtonConstrains = self.logoutButtonConstrains()
        let nameLabelConstrains = self.nameLabelConstrains()
        let loginNameLabelConstrains = self.loginNameLabelConstrains()
        let descriptionLabelConstrains = self.descriptionLabelConstrains()
        
        NSLayoutConstraint.activate(
            avatarImageViewConstrains +
            logoutButtonConstrains +
            nameLabelConstrains + loginNameLabelConstrains +
            descriptionLabelConstrains
        )
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        nameLabel.textColor = .ypWhite
        loginNameLabel.textColor = .ypGray
        descriptionLabel.textColor = .ypWhite
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        
        self.nameLabel.text = profile.name
        self.loginNameLabel.text = profile.loginName
        self.descriptionLabel.text = profile.bio
        
        profileImageService.fetchProfileImageURL(with: profile.username) { _ in
        }
    }
    
    private func addProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: Constants.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self else { return }
                self.updateAvatar(notification: notification)
            }
    }
    
    @objc
    private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let profileImageURL = notification.userInfoImageURL,
            let url = URL(string: profileImageURL)
        else { return }
        updateAvatar(url: url)
    }
    
    private func updateAvatar(url: URL) {
        avatarImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61, backgroundColor: .ypBlack)
        avatarImageView.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            print("Error in \(#function): Invalid Configuration")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    private func showLogoutAlert() {
        let alertModel = AlertModel(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            firstButtonText: "Да", secondButtonText: "Нет"
        ) { [weak self] in
            guard let self else { return }
            self.profileLogoutService.logout()
            self.switchToSplashViewController()
        }
        AlertPresenter.showAlert(model: alertModel, vc: self)
    }
}

// MARK: - Extension
extension Notification {
    static let userInfoImageURLKey: String = "URL"
    var userInfoImageURL: String? {
        userInfo?[Notification.userInfoImageURLKey] as? String
    }
}

