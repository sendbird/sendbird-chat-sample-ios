//
//  MessageUndeliveredStatusCell.swift
//  MessageUndeliveredCountGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChat

class MessageUndeliveredStatusCell: BasicMessageCell {
    
    lazy var unReadStatusLabel: UILabel = {
        let unReadStatusLabel: UILabel = UILabel()
        unReadStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        unReadStatusLabel.font = .systemFont(ofSize: 12)
        unReadStatusLabel.textAlignment = .right
        return unReadStatusLabel
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
        contentStackView.addArrangedSubview(unReadStatusLabel)
    }
    
    func updateMessageDetails(
        with message: BaseMessage,
        undeliveredCountUseCase: MessageUndeliveredMembersCountUseCase
    ) {
        configure(with: message)
        let currentUserId = UserConnectionUseCase.shared.currentUser?.userId
        if message.sender?.userId == currentUserId {
            unReadStatusLabel.isHidden = false
            unReadStatusLabel.text = undeliveredCountUseCase.getUndeliveredMessageStatus(for: message)
        } else {
            unReadStatusLabel.isHidden = true
        }
    }
}
