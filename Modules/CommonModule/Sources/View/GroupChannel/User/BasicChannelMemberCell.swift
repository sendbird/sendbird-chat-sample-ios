//
//  BasicChannelMemberCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendbirdChatSDK

public class BasicChannelMemberCell: UITableViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView: UIImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.backgroundColor = .secondarySystemBackground
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        return profileImageView
    }()
    
    public lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10.0
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var profileLabel: UILabel = {
        let profileLabel: UILabel = UILabel()
        profileLabel.textColor = .label
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.font = .systemFont(ofSize: 16)
        return profileLabel
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentStackView.addArrangedSubview(profileImageView)
        contentStackView.addArrangedSubview(profileLabel)
        contentView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            contentStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        profileLabel.text = nil
        profileImageView.kf.cancelDownloadTask()
        profileImageView.image = nil
    }

    public func configure(with user: User) {
        profileLabel.text = "\(user.nickname ?? "(Unknown)") \(connectionStatus(with: user))"
        profileImageView.setProfileImageView(for: user)
    }
    
    private func connectionStatus(with user: User) -> String {
        switch user.connectionStatus {
        case .online:
            return "(online)"
        default:
            return ""
        }
    }
    
}
