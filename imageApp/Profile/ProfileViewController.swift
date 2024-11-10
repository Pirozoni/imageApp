//  ProfileViewController.swift
//  imageApp
//
//  Created by Надежда Пономарева on 09.11.2024.

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var userPhoto: UIImageView!
    
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var profileUserNickname: UILabel!
    @IBOutlet weak var profileUserText: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBAction private func didTapExitButton(_ sender: Any) {
    }
    
}
