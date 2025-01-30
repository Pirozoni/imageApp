//  SingleImageViewController.swift
//  imageApp
//  Created by Надежда Пономарева on 11.11.2024.

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var photo: Photo?
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
//        bringButtonsToFront()
        guard let url = photo?.largeImageURL else { return }
        loadImage(by: url)
    }
    
    // MARK: - Methods
    func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - Private Methods
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let imageResult):
                    completion(imageResult.image)
                case .failure:
                    self.showError()
                }
            }
        }
    }
    
    private func showError() {
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Попробовать ещё раз?",
            firstButtonText: "Повторить", secondButtonText: "Не надо"
        ) { [weak self] in
            guard let self else { return }
            guard let url = photo?.largeImageURL else { return }
            
            imageView.removeFromSuperview()
            
            loadImage(by: url)
        }
        AlertPresenter.showAlert(model: alertModel, vc: self)
    }
    
    
    
    // MARK: - IB Action
    @IBAction private func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let shareButton = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(shareButton, animated: true, completion: nil)
    }
    
    private func loadImage(by url: URL) {
        UIBlockingProgressHUD.show()
        let placeholderImage = UIImage(named: "singleImagePlaceholder2")
        imageView = UIImageView()
        imageView.frame = CGRect(
            x: (view.frame.width - (placeholderImage?.size.width ?? 0)) * 0.5,
            y: (view.frame.height - (placeholderImage?.size.height ?? 0)) * 0.5,
            width: placeholderImage?.size.width ?? 0,
            height: placeholderImage?.size.height ?? 0
        )
        imageView.contentMode = .scaleAspectFit
        imageView.image = placeholderImage
        self.scrollView.addSubview(imageView)
        loadImage(from: url) { [weak self] image in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            self.imageView.frame = CGRect.zero
            self.image = image
        }
    }
//    private func bringButtonsToFront() {
//        view.bringSubviewToFront(backButton)
//        view.bringSubviewToFront(didTapShareButton)
//    }
}

    // MARK: - Extensions
extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

