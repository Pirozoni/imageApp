//  SingleImageViewController.swift
//  imageApp
//  Created by Надежда Пономарева on 11.11.2024.

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    
    @IBAction private func backButton(_ sender: Any) {
        dismiss( animated: true, completion: nil)
    }
}

