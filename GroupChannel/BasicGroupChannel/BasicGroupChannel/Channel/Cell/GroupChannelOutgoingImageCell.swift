//
//  GroupChannelOutgoingImageCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import Kingfisher

protocol GroupChannelFileCell: UITableViewCell {
    func configure(with message: SBDFileMessage)
}

final class GroupChannelOutgoingImageCell: UITableViewCell, GroupChannelFileCell {
    
    @IBOutlet private weak var messageImageView: UIImageView!
    @IBOutlet private weak var placeholderImageView: UIImageView!
    @IBOutlet private weak var sendingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var resendButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = nil
        placeholderImageView.isHidden = false
        resendButton.isHidden = true
        sendingIndicator.stopAnimating()
    }
    
    func configure(with message: SBDFileMessage) {
        resendButton.isHidden = shouldHideResendButton(for: message)

        if shouldStartSendingIndicator(for: message) {
            sendingIndicator.startAnimating()
        } else {
            sendingIndicator.stopAnimating()
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
    
    private func shouldStartSendingIndicator(for message: SBDBaseMessage) -> Bool {
        switch message.sendingStatus {
        case .pending:
            return true
        default:
            return false
        }
    }
    
    private func shouldHideResendButton(for message: SBDBaseMessage) -> Bool {
        switch message.sendingStatus {
        case .failed, .canceled:
            return false
        default:
            return true
        }
    }
    
    @IBAction private func didTouchResendButton(_ sender: UIButton) {
        
    }
}
