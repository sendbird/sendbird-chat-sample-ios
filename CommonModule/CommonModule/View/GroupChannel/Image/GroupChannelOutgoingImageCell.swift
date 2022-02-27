//
//  GroupChannelOutgoingImageCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import Kingfisher

public final class GroupChannelOutgoingImageCell: UITableViewCell, GroupChannelSendingStatusCell, GroupChannelOutgoingCell {
    
    public weak var delegate: GroupChannelOutgoingCellDelegate?
    private weak var message: SBDFileMessage?
    
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var sendingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resendButton: UIButton!
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        message = nil
        delegate = nil
        messageImageView.kf.cancelDownloadTask()
        messageImageView.image = nil
        placeholderImageView.isHidden = false
        resendButton.isHidden = true
        sendingIndicator.stopAnimating()
    }
    
    public func configure(with message: SBDFileMessage) {
        self.message = message
        updateSendingStatusUI(for: message)
        
        guard let imageURL = imageURL(for: message) else {
            return
        }
        
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

    @IBAction private func didTouchResendButton(_ sender: UIButton) {
        guard let message = message else { return }
        delegate?.groupChannelOutgoingCell(self, didTouchResendButton: sender, forFileMessage: message)
    }
}
