//
//  SelectableUserTableViewCell.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 18/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SelectableUserTableViewCell: UITableViewCell {
    
    private lazy var checkImageView = UIImageView(image: CommonModuleAsset.imgListChecked.image)

    private lazy var profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = 22.5
        profileImageView.clipsToBounds = true
        return profileImageView
    }()
    
    private lazy var nicknameLabel = UILabel()
    
    public var selectedUser: Bool = false {
        didSet {
            checkImageView.image = selectedUser ? CommonModuleAsset.imgListChecked.image : CommonModuleAsset.imgListUnchecked.image
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubViews() {
        contentView.addSubview(checkImageView)
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        contentView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: checkImageView.trailingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 45),
            profileImageView.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        contentView.addSubview(nicknameLabel)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nicknameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            nicknameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    public func configure(with user: User, isSelected: Bool) {
        nicknameLabel.text = user.nickname
        profileImageView.setProfileImageView(for: user)
        selectedUser = isSelected
    }

}
