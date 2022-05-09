//
//  MesageThreadCell.swift
//  OpenGraphTagsOpenChannel
//
//  Created by Yogesh Veeraraj on 08.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

class MesageThreadCell: BasicMessageCell {
    
    lazy var titleLabel: UILabel = {
        let dataLabel: UILabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = .systemFont(ofSize: 14)
        dataLabel.numberOfLines = 0
        return dataLabel
    }()
        
    lazy var descriptionLabel: UILabel = {
        let dataLabel: UILabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = .systemFont(ofSize: 14)
        dataLabel.numberOfLines = 0
        return dataLabel
    }()
    
    lazy var parentMessageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8.0
        stackView.backgroundColor = .systemGray6
        return stackView
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
        parentMessageStackView.addArrangedSubview(titleLabel)
        parentMessageStackView.addArrangedSubview(descriptionLabel)
        contentStackView.insertArrangedSubview(parentMessageStackView, at: 0)
    }
    
    func updateMessageDetails(
        with message: BaseMessage
    ) {
        configure(with: message)
        if let parentMessage = message.parentMessage {
            parentMessageStackView.isHidden = false
            titleLabel.text = parentMessage.sender?.nickname
            descriptionLabel.text = "\(parentMessage.message) (\(Date.sbu_from(parentMessage.createdAt).sbu_toString(format: .hhmma)))"
        } else {
            parentMessageStackView.isHidden = true
        }
    }
}
