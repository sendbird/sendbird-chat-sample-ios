//
//  SelectedUserCollectionViewCell.swift
//  SendBird-iOS
//
//  Created by Jaesung Lee on 27/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendbirdChat
import Kingfisher

public class SelectedUserCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!
    
    public static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    public static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    public func configure(_ user: SBDUser) {
        if let profileUrlString = user.profileUrl,
            let profileUrl = URL(string: profileUrlString) {
            profileImageView.kf.setImage(with: profileUrl, placeholder: UIImage(named: "img_default_profile_image_1"))
        }
        else {
            profileImageView.image = UIImage(named: "img_default_profile_image_1")
        }
        nicknameLabel.text = user.nickname
    }
}
