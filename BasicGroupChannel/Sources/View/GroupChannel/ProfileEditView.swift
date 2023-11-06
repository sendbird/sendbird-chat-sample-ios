//
//  ProfileEditView.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/31.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class ProfileEditView: UIView {
    
    public typealias DidTouchProfileHandler = () -> Void
        
    public var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    public var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    private let didTouchProfile: DidTouchProfileHandler
            
    private lazy var bottomBorderView: UIView = {
        let bottomBorderView: UIView = UIView()
        bottomBorderView.backgroundColor = .label
        return bottomBorderView
    }()
    
    private lazy var profileImageView: ProfileImageView = {
        let profileImageView = ProfileImageView(frame: .zero)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.makeCircularWithSpacing(spacing: 1)
        
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTouchProfileImageView(_ :)))
        profileImageView.addGestureRecognizer(tapCoverImageGesture)
        
        return profileImageView
    }()
    
    private lazy var cameraImageView: UIImageView = {
        let cameraIamgeView = UIImageView()
        cameraIamgeView.image = BasicGroupChannelAsset.imgIconEditCamera.image
        return cameraIamgeView
    }()
    
    private lazy var textField: UITextField = {
        let channelNameTextField = UITextField()
        channelNameTextField.placeholder = "Channel Name"
        return channelNameTextField
    }()
    
    public init(didTouchProfile: @escaping DidTouchProfileHandler) {
        self.didTouchProfile = didTouchProfile
        super.init(frame: .zero)
        
        backgroundColor = .systemGroupedBackground
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
    private func setupSubviews() {
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        
        addSubview(cameraImageView)
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraImageView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cameraImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            cameraImageView.widthAnchor.constraint(equalToConstant: 28),
            cameraImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTouchProfileImageView(_ sender: UIView) {
        didTouchProfile()
    }
    
    public func setImage(_ image: UIImage) {
        profileImageView.setImage(with: image)
    }
    
    public func setUser(_ user: User) {
        profileImageView.setUsers([])
    }
    
    public func setUsers(_ newUsers: [User]) {
        profileImageView.setUsers(newUsers)
    }
    
    public func setImage(withCoverUrl coverUrl: String) {
        profileImageView.setImage(withCoverUrl: coverUrl)
    }
    
}
