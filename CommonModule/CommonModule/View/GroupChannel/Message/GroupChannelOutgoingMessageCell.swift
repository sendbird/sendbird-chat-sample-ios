//
//  GroupChannelOutgoingMessageCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

public class GroupChannelOutgoingMessageCell: UITableViewCell, GroupChannelSendingStatusCell, GroupChannelOutgoingCell {

    public weak var delegate: GroupChannelOutgoingCellDelegate?
    private weak var message: SBDUserMessage?

    @IBOutlet weak var sendingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        message = nil
        delegate = nil
        resendButton.isHidden = true
        sendingIndicator.stopAnimating()
    }

    public func configure(with message: SBDUserMessage) {
        self.message = message
        updateSendingStatusUI(for: message)
        messageLabel.text = message.message
    }
    
    @IBAction private func didTouchResendButton(_ sender: UIButton) {
        guard let message = message else { return }
        delegate?.groupChannelOutgoingCell(self, didTouchResendButton: sender, forUserMessage: message)
    }
}
