//
//  OGMetaDataMessageCell.swift
//  OpenGraphTagsOpenChannel
//
//  Created by Yogesh Veeraraj on 08.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Kingfisher
import CommonModule

class OGMetaDataMessageCell: BasicMessageCell {
    
    lazy var titleLabel: UILabel = {
        let dataLabel: UILabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = .systemFont(ofSize: 14)
        dataLabel.numberOfLines = 0
        return dataLabel
    }()
    
    lazy var urlLabel: UILabel = {
        let dataLabel: UILabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = .systemFont(ofSize: 10)
        dataLabel.textColor = .systemBlue
        return dataLabel
    }()
    
    lazy var descriptionLabel: UILabel = {
        let dataLabel: UILabel = UILabel()
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.font = .systemFont(ofSize: 14)
        dataLabel.numberOfLines = 0
        return dataLabel
    }()
    
    lazy var ogImage: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 150),
            imageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        return imageView
    }()

    lazy var ogStackView: UIStackView = {
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
        ogStackView.addArrangedSubview(urlLabel)
        ogStackView.addArrangedSubview(titleLabel)
        ogStackView.addArrangedSubview(descriptionLabel)
        ogStackView.addArrangedSubview(ogImage)
        contentStackView.addArrangedSubview(ogStackView)
    }
    
    func updateMessageDetails(
        with message: BaseMessage
    ) {
        configure(with: message)
        if let metaData =  message.ogMetaData {
            ogStackView.isHidden = false
            urlLabel.text = metaData.url
            titleLabel.text = metaData.title
            descriptionLabel.text = metaData.desc
            if let imageData =  metaData.defaultImage,
                let urlString = imageData.url,
               let imageURL = URL(string: urlString) {
                ogImage.kf.setImage(with: imageURL, placeholder: CommonModuleAsset.imgDefaultProfileImage1.image)
            }
        } else {
            ogStackView.isHidden = true
        }
    }
}
