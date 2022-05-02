//
//  MentionedUserMessageCell.swift
//  MentionUsersInMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 02.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//
import UIKit
import SendbirdChatSDK
import CommonModule

class MessageUndeliveredStatusCell: BasicMessageCell {
    
    lazy var mentionedUsersLabel: UILabel = {
        let mentionedUsersLabel: UILabel = UILabel()
        mentionedUsersLabel.translatesAutoresizingMaskIntoConstraints = false
        mentionedUsersLabel.font = .systemFont(ofSize: 12)
        mentionedUsersLabel.textAlignment = .right
        return mentionedUsersLabel
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
        contentStackView.addArrangedSubview(mentionedUsersLabel)
    }
    
    func updateMessageDetails(
        with message: BaseMessage,
        undeliveredCountUseCase: MessageUndeliveredMembersCountUseCase
    ) {
        configure(with: message)
    }
}
