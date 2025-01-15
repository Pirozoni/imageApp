//  ProfileViewController.swift
//  imageApp

import UIKit

final class ProfileViewController: UIViewController {
        
    // MARK: - Private Properties
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "UserPhoto")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        let buttonImage = UIImage(named: "Exit")
        button.setImage(buttonImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 23.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label

    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        drawSelf()
        setupView()
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
        view.addSubview(avatarImageView)
        view.addSubview(logoutButton)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        
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
        self.nameLabel.text = "Екатерина Новикова"
        self.nameLabel.textColor = .ypWhite
        
        self.loginNameLabel.text = "@ekaterina_nov"
        self.loginNameLabel.textColor = .ypGray
        
        self.descriptionLabel.text = "Hello, World!"
        self.descriptionLabel.textColor = .ypWhite
    }
}

