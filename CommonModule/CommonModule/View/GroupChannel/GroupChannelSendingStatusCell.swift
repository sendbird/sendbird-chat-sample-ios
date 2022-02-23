//
//  GroupChannelSendingStatusCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

protocol GroupChannelSendingStatusCell {
    var sendingIndicator: UIActivityIndicatorView! { get }
    var resendButton: UIButton! { get }
}

extension GroupChannelSendingStatusCell {
    
    func updateSendingStatusUI(for message: SBDBaseMessage) {
        resendButton.isHidden = shouldHideResendButton(for: message)

        if shouldStartSendingIndicator(for: message) {
            sendingIndicator.startAnimating()
        } else {
            sendingIndicator.stopAnimating()
        }
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

}
