//
//  GroupChannelIncomingImageCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import Kingfisher

public final class GroupChannelIncomingImageCell: UITableViewCell, GroupChannelImageCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameTextLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        nicknameTextLabel.text = nil
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = nil
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = nil
    }
    
    public func configure(with message: SBDFileMessage) {
        if let sender = message.sender {
            nicknameTextLabel.text = "\(sender.nickname ?? "(Unknown)")"
            profileImageView.setProfileImageView(for: sender)
        }
        
        guard let imageURL = imageURL(for: message) else { return }
        
        messageImageView.kf.setImage(with: imageURL) { [weak self] result in
            switch result {
            case .success:
                self?.placeholderImageView.isHidden = true
            case .failure:
                self?.placeholderImageView.isHidden = false
            }
        }
    }
    
    private func imageURL(for message: SBDFileMessage) -> URL? {
        if let thumbnailURLString = message.thumbnails?.first?.url {
            return URL(string: thumbnailURLString)
        } else if message.type.hasPrefix("image") {
            return URL(string: message.url)
        }
        
        return nil
    }

}
