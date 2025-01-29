//
//  ImagesListCell.swift
//  imageApp
//
//  Created by Надежда Пономарева on 06.11.2024.
//
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: imageListViewCellDelegate?
    
    // MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
    
    // MARK: - IB Actions
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    func refreshLikeImage(to isLike: Bool) {
        likeButton.setImage(isLike ? UIImage(named: "Like") : UIImage(named: "Dislike"), for: .normal)
    }
}
