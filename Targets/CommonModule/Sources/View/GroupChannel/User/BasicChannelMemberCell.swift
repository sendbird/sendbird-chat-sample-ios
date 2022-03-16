//
//  BasicChannelMemberCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendbirdChat

public class BasicChannelMemberCell: UITableViewCell {
    
    private lazy var profileImageView: UIImageView = {
        let profileImageView: UIImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .secondarySystemBackground
        return profileImageView
    }()
    
    private lazy var profileLabel: UILabel = {
        let profileLabel: UILabel = UILabel()
        profileLabel.textColor = .label
        profileLabel.font = .systemFont(ofSize: 16)
        return profileLabel
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileLabel)

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        NSLayoutConstraint.activate([
            profileLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            profileLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
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

    public func configure(with user: SBDUser) {
        profileLabel.text = "\(user.nickname ?? "(Unknown)") \(connectionStatus(with: user))"
        profileImageView.setProfileImageView(for: user)
    }
    
    private func connectionStatus(with user: SBDUser) -> String {
        switch user.connectionStatus {
        case .online:
            return "(online)"
        default:
            return ""
        }
    }
    
}
