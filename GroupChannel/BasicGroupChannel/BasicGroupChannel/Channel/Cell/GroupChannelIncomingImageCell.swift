//
//  GroupChannelIncomingImageCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import Kingfisher

final class GroupChannelIncomingImageCell: UITableViewCell, GroupChannelFileCell {
    
    @IBOutlet private weak var messageTextLabel: UILabel!
    @IBOutlet private weak var messageImageView: UIImageView!
    
    private weak var message: SBDFileMessage?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        message = nil
        messageTextLabel.text = nil
        
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = UIImage(named: "img_icon_general_file")
    }
    
    func configure(with message: SBDFileMessage) {
        self.message = message
        
        messageTextLabel.text = "(FILE) \(message.name)"
        
        if let thumbnailURLString = message.thumbnails?.first?.url,
           let thumbnailURL = URL(string: thumbnailURLString) {
            messageImageView.kf.setImage(with: thumbnailURL)
        } else if message.type.hasPrefix("image"), let imageURL = URL(string: message.url) {
            messageImageView.kf.setImage(with: imageURL)
        }
    }

}
