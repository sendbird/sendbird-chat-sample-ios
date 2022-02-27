//
//  GroupChannelMessageCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

public class GroupChannelMessageCell: UITableViewCell {
    
    private lazy var profileLabel: UILabel = {
        let profileLabel: UILabel = UILabel()
        profileLabel.textColor = .secondaryLabel
        profileLabel.font = .systemFont(ofSize: 14)
        return profileLabel
    }()
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView: UIImageView = UIImageView()
        profileImageView.contentMode = .scaleToFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        return profileImageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let messageLabel: UILabel = UILabel()
        messageLabel.textColor = .label
        messageLabel.font = .systemFont(ofSize: 17)
        return messageLabel
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

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

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
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        profileLabel.text = nil
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = nil
        messageLabel.text = nil
    }

    public func configure(with message: SBDUserMessage) {
        if let sender = message.sender {
            profileLabel.text = "\(sender.nickname ?? "(Unknown)")"
            profileImageView.setProfileImageView(for: sender)
        }
        
        messageLabel.text = "\(message.message)\n\(message.createdAt)"
    }
    
}
