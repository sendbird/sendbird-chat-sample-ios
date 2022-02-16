//
//  GroupChannelCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK

class GroupChannelCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        textLabel?.numberOfLines = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel?.textAlignment = .left
        textLabel?.text = nil
    }
    
    func configure(with message: SBDBaseMessage) {
        if message.sender?.userId == SBDMain.getCurrentUser()?.userId {
            textLabel?.textAlignment = .right
            textLabel?.text = message.message
        } else {
            textLabel?.textAlignment = .left
            textLabel?.text = "\(message.sender?.nickname ?? "-"): \(message.message)"
        }
    }
    
}
