//
//  GroupChannelListCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendBirdSDK

public class GroupChannelListCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public func configure(with channel: SBDGroupChannel) {
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
