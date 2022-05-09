//
//  MentionedUserMessageCell.swift
//  MentionUsersInMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 07.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class MentionedUserMessageCell: BasicMessageCell {
    
    lazy var usersLabel: UILabel = {
        let usersLabel: UILabel = UILabel()
        usersLabel.translatesAutoresizingMaskIntoConstraints = false
        usersLabel.font = .systemFont(ofSize: 12)
        usersLabel.textAlignment = .right
        usersLabel.textColor = .systemBlue
        return usersLabel
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
        contentStackView.addArrangedSubview(usersLabel)
    }
    
    func updateMessageDetails(
        with message: BaseMessage
    ) {
        configure(with: message)
        let userNames: [String] = message.mentionedUsers.map {
            $0.nickname ?? $0.userID
        }
        usersLabel.text = userNames.joined(separator: ",")
    }
}
