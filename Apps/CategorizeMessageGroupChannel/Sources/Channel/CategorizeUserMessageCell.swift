//
//  CategorizeUserMessageCell.swift
//  CategorizeMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class CategorizeUserMessageCell: BasicMessageCell {
    
    lazy var categorizeLabel: UILabel = {
        let categorizeLabel: UILabel = UILabel()
        categorizeLabel.translatesAutoresizingMaskIntoConstraints = false
        categorizeLabel.font = .systemFont(ofSize: 12)
        categorizeLabel.textAlignment = .right
        return categorizeLabel
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
        contentStackView.addArrangedSubview(categorizeLabel)
    }
    
    func updateMessageDetails(
        with message: BaseMessage
    ) {
        configure(with: message)
        if let customType = message.customType, !customType.isEmpty {
            categorizeLabel.isHidden = false
            categorizeLabel.text = String(format: "%@", customType)
        } else {
            categorizeLabel.isHidden = true
        }
    }
}
