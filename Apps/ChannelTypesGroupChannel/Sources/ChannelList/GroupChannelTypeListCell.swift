//
//  GroupChannelTypeListCell.swift
//  CategorizeWithCustomTypeGroupChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

class GroupChannelTypeListCell: GroupChannelListCell {
    
    override func configure(with channel: GroupChannel) {
        var channelType: String
        if channel.isPublic {
            channelType = "Public"
        } else if channel.isSuper {
            channelType = "Super Group"
        } else {
            channelType = "Private"
        }
        let channelDisplayTitle = channel.name + " " + String(format: "(%@)", channelType)
        
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            content.text = channelDisplayTitle
            content.secondaryText = channel.lastMessage?.message
            contentConfiguration = content
        } else {
            textLabel?.text = channelDisplayTitle
            detailTextLabel?.text = channel.lastMessage?.message
        }
    }
    
}
