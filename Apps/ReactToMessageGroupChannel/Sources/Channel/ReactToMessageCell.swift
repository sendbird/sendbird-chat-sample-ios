//
//  ReactToMessageCell.swift
//  ReactToMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class ReactToMessageCell: BasicMessageCell {
    
    lazy var reactionLabel: UILabel = {
        let reactionLabel: UILabel = UILabel()
        reactionLabel.translatesAutoresizingMaskIntoConstraints = false
        reactionLabel.font = .systemFont(ofSize: 12)
        reactionLabel.textAlignment = .right
        return reactionLabel
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentStackView.addArrangedSubview(reactionLabel)
    }
    
    func updateMessageDetails(
        with message: BaseMessage
    ) {
        configure(with: message)
        let reactions = message.reactions.map {
            $0.key
        }
        reactionLabel.text = reactions.joined(separator: " ")
    }
}
