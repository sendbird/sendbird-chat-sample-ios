//
//  StructuredDataMessageCell.swift
//  CategorizeMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import CommonModule
import SendbirdChatSDK

class StructuredDataMessageCell: BasicMessageCell {
    
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
        let data = message.data
        if data.isEmpty {
            categorizeLabel.isHidden = true
        } else {
            let dictionary = try? JSONDecoder().decode([String: String].self, from: Data(data.utf8))
            if let structuredData = dictionary {
                categorizeLabel.isHidden = false
                categorizeLabel.text = structuredData["description"]
                categorizeLabel.textColor = UIColor(hexString: structuredData["color"] ?? "#6a0dad")
            }
        }
    }
}
