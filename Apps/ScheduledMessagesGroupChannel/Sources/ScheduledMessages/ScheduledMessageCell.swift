//
//  ScheduledMessageCell.swift
//  ScheduledMessagesGroupChannel
//
//  Created by Mihai Moisanu on 21.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import CommonModule
import SendbirdChatSDK

class ScheduledMessageCell : BasicMessageCell{
    override func configure(with message: BaseMessage) {
        super.configure(with: message)
        let date = "Scheduled for \(Date.sbu_from(message.createdAt).sbu_toString(format:.yyyyMMddhhmm))"
        messageLabel.text = "\(date)\n\(message.message)"
    }
}

class ScheduledFileMessageCell: BasicFileCell{
    override func configure(with message: FileMessage) {
        super.configure(with: message)
        let date = "Scheduled for \(Date.sbu_from(message.createdAt).sbu_toString(format:.yyyyMMddhhmm))"
        messageLabel.text = "\(date)\n\(message.message)"
    }
}
