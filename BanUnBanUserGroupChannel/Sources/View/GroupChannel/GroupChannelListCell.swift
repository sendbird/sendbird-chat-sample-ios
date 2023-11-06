//
//  GroupChannelListCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendbirdChatSDK

open class GroupChannelListCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    open func configure(with channel: GroupChannel) {
        if #available(iOS 14.0, *) {
            var content = defaultContentConfiguration()
            content.text = channel.name
            content.secondaryText = channel.lastMessage?.message
            contentConfiguration = content
        } else {
            textLabel?.text = channel.name
            detailTextLabel?.text = channel.lastMessage?.message
        }
    }
    
}
