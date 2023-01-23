//
//  PinMessageCell.swift
//  PinMessageGroupChannel
//
//  Copyright © 2023 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import CommonModule

class PinMessageCell : BasicMessageCell{
    func configure(with message: BaseMessage, isPinned: Bool) {
        super.configure(with: message)
        if isPinned{
            messageLabel.text = "Pinned:\n\(messageLabel.text!)"
        }
    }
}

class PinFileCell : BasicFileCell{
    func configure(with message: FileMessage, isPinned: Bool) {
        super.configure(with: message)
        if isPinned{
            messageLabel.text = "Pinned:\n\(messageLabel.text!)"
        }
    }
}

