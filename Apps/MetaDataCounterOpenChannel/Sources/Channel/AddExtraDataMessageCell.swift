//
//  AddExtraDataMessageCell.swift
//  AddExtraDataMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

class AddExtraDataMessageCell: BasicMessageCell {
    
    lazy var dataLabel: UILabel = {
        let dataLabel: UILabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = .systemFont(ofSize: 12)
        dataLabel.textAlignment = .right
        return dataLabel
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
        contentStackView.addArrangedSubview(dataLabel)
    }
    
    func updateMessageDetails(
        with message: BaseMessage
    ) {
        configure(with: message)
        var metaString = [String]()
        if let metaArray = message.metaArrays {
            for data in metaArray {
                let values = data.value.joined(separator: ",")
                let key = data.key
                metaString.append(String(format: "%@: %@", key, values))
            }
            dataLabel.isHidden = false
            dataLabel.text = metaString.joined(separator: ",")
        } else {
            dataLabel.isHidden = true
        }
    }
}
