//
//  GroupChannelFileCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

public class GroupChannelFileCell: UITableViewCell {
    
    private lazy var profileLabel: UILabel = {
        let profileLabel: UILabel = UILabel()
        profileLabel.textColor = .secondaryLabel
        profileLabel.font = .systemFont(ofSize: 14)
        profileLabel.numberOfLines = 0
        return profileLabel
    }()
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView: UIImageView = UIImageView()
        profileImageView.contentMode = .scaleToFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .secondarySystemBackground
        return profileImageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let messageLabel: UILabel = UILabel()
        messageLabel.textColor = .label
        messageLabel.font = .systemFont(ofSize: 17)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    private lazy var previewImageView: UIImageView = {
        let previewImageView = UIImageView()
        previewImageView.backgroundColor = .secondarySystemBackground
        previewImageView.contentMode = .scaleToFill
        previewImageView.layer.cornerRadius = 10
        previewImageView.clipsToBounds = true
        return previewImageView
    }()
    
    private lazy var previewPlaceholderImageView: UIImageView = {
        let previewPlaceholderImageView = UIImageView()
        previewPlaceholderImageView.image = .named("img_icon_general_file")
        return previewPlaceholderImageView
    }()
    
    private lazy var sendingIndicator: UIActivityIndicatorView = {
        let sendingIndicator = UIActivityIndicatorView(style: .medium)
        sendingIndicator.hidesWhenStopped = true
        sendingIndicator.startAnimating()
        return sendingIndicator
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(previewImageView)
        contentView.addSubview(previewPlaceholderImageView)
        contentView.addSubview(sendingIndicator)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewPlaceholderImageView.translatesAutoresizingMaskIntoConstraints = false
        sendingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        NSLayoutConstraint.activate([
            profileLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            profileLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: profileLabel.bottomAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: profileLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            previewImageView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: 240),
            previewImageView.heightAnchor.constraint(equalToConstant: 160),
        ])
                
        NSLayoutConstraint.activate([
            previewPlaceholderImageView.centerXAnchor.constraint(equalTo: previewImageView.centerXAnchor),
            previewPlaceholderImageView.centerYAnchor.constraint(equalTo: previewImageView.centerYAnchor),
            previewPlaceholderImageView.widthAnchor.constraint(equalToConstant: 50),
            previewPlaceholderImageView.heightAnchor.constraint(equalToConstant: 50),
        ])

        NSLayoutConstraint.activate([
            sendingIndicator.leadingAnchor.constraint(equalTo: previewImageView.trailingAnchor),
            sendingIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        profileLabel.text = nil
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = nil
        messageLabel.text = nil
        sendingIndicator.stopAnimating()
    }

    public func configure(with message: SBDFileMessage) {
        if let sender = message.sender {
            profileLabel.text = "\(sender.nickname ?? "(Unknown)")"
            profileImageView.setProfileImageView(for: sender)
        } else if message is SBDAdminMessage {
            profileLabel.text = "Admin"
        }
        
        messageLabel.text = "\(message.message)"
        
        switch message.sendingStatus {
        case .pending:
            sendingIndicator.startAnimating()
        default:
            sendingIndicator.stopAnimating()
        }
        
        previewPlaceholderImageView.isHidden = false
        
        guard let imageURL = imageURL(for: message) else {
            return
        }
        
        previewImageView.kf.setImage(with: imageURL) { [weak self] result in
            switch result {
            case .success:
                self?.previewPlaceholderImageView.isHidden = true
            case .failure:
                self?.previewPlaceholderImageView.isHidden = false
            }
        }
    }
    
    private func imageURL(for message: SBDFileMessage) -> URL? {
        if let thumbnailURLString = message.thumbnails?.first?.url {
            return URL(string: thumbnailURLString)
        } else if message.type.hasPrefix("image") {
            return URL(string: message.url)
        }
        
        return nil
    }
    
}
