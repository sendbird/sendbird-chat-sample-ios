//
//  OpenChannelCell.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK

class OpenChannelCell: UITableViewCell {
    
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
        
        textLabel?.text = nil
    }
    
    func configure(with message: SBDBaseMessage) {
        textLabel?.textAlignment = .left
        textLabel?.text = "\(message.sender?.nickname ?? "-"): \(message.message)"
    }
    
}
