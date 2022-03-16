//
//  SelectableUserTableViewCell.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 18/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendbirdChat

public class SelectableUserTableViewCell: UITableViewCell {
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!
    
    public var selectedUser: Bool = false {
        didSet {
            checkImageView.image = selectedUser ? UIImage.named("img_list_checked") : UIImage.named("img_list_unchecked")
        }
    }
    
    public static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    public func configure(with user: SBDUser, isSelected: Bool) {
        nicknameLabel.text = user.nickname
        profileImageView.setProfileImageView(for: user)
        selectedUser = isSelected
    }

}
