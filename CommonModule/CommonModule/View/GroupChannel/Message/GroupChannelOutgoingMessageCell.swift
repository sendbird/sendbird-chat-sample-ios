//
//  GroupChannelOutgoingMessageCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

public class GroupChannelOutgoingMessageCell: UITableViewCell, GroupChannelMessageCell {
    
    @IBOutlet private weak var sendingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var resendButton: UIButton!
    @IBOutlet private weak var messageLabel: UILabel!
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        resendButton.isHidden = true
        sendingIndicator.stopAnimating()
    }

    public func configure(with message: SBDBaseMessage) {
        resendButton.isHidden = shouldHideResendButton(for: message)

        if shouldStartSendingIndicator(for: message) {
            sendingIndicator.startAnimating()
        } else {
            sendingIndicator.stopAnimating()
        }
        
        messageLabel.text = message.message
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
