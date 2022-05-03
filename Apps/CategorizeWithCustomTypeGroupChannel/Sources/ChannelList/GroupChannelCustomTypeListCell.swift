//
//  GroupChannelCustomTypeListCell.swift
//  CategorizeWithCustomTypeGroupChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

class GroupChannelCustomTypeListCell: GroupChannelListCell {
    override func configure(with channel: GroupChannel) {
        let customType =  channel.customType ?? "none"
        let channelText = channel.name + "\n" + "CustomType: " +  (customType.isEmpty ? "none" : customType)
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            content.text = channelText
            content.secondaryText = channel.lastMessage?.message
            contentConfiguration = content
        } else {
            textLabel?.text = channelText
            detailTextLabel?.text = channel.lastMessage?.message
        }
    }
}
