//
//  GroupChannelFileCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import Kingfisher

final class GroupChannelFileCell: UITableViewCell {
    
    @IBOutlet private weak var messageTextLabel: UILabel!
    @IBOutlet private weak var messageImageView: UIImageView!
    @IBOutlet private weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    private weak var message: SBDFileMessage?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message = nil
        messageTextLabel.textAlignment = .left
        messageTextLabel.text = nil
        
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = UIImage(named: "img_icon_general_file")
    }
    
    func configure(with message: SBDFileMessage) {
        self.message = message
        
        let isMyMessage = message.sender?.userId == SBDMain.getCurrentUser()?.userId
        
        if isMyMessage {
            messageTextLabel.text = "(FILE) \(message.name)"
        } else {
            messageTextLabel.text = "\(message.sender?.nickname ?? "-"): (FILE) \(message.message)"
        }
        
        messageTextLabel.textAlignment = isMyMessage ? .right : .left
        imageViewLeadingConstraint.isActive = isMyMessage == false
        imageViewTrailingConstraint.isActive = isMyMessage

        if message.type.hasPrefix("image"), let imageURL = URL(string: message.url) {
            messageImageView.kf.setImage(with: imageURL)
        }
    }

}
