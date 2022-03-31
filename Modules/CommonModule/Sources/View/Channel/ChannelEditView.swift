//
//  ChannelEditView.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/31.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChat

public class ChannelEditView: UIView {
    
    public typealias DidTouchProfileHandler = () -> Void
    
    public var textFieldPlaceholder: String? {
        get { channelNameTextField.placeholder }
        set { channelNameTextField.placeholder = newValue }
    }
    
    public var textFieldText: String? {
        get { channelNameTextField.text }
        set { channelNameTextField.text = newValue }
    }
    
    private let didTouchProfile: DidTouchProfileHandler
    
    private var users: [User]
        
    private lazy var bottomBorderView: UIView = {
        let bottomBorderView: UIView = UIView()
        bottomBorderView.backgroundColor = .label
        return bottomBorderView
    }()
    
    private lazy var profileImageView: ProfileImageView = {
        let profileImageView = ProfileImageView(users: users, frame: .zero)
        profileImageView.isUserInteractionEnabled = true
        profileImageView.makeCircularWithSpacing(spacing: 1)
        
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTouchProfileImageView(_ :)))
        profileImageView.addGestureRecognizer(tapCoverImageGesture)
        
        return profileImageView
    }()
    
    private lazy var cameraImageView: UIImageView = {
        let cameraIamgeView = UIImageView()
        cameraIamgeView.image = CommonModuleAsset.imgIconEditCamera.image
        return cameraIamgeView
    }()
    
    private lazy var channelNameTextField: UITextField = {
        let channelNameTextField = UITextField()
        channelNameTextField.placeholder = "Channel Name"
        return channelNameTextField
    }()
    
    public init(users: [User] = [], didTouchProfile: @escaping DidTouchProfileHandler) {
        self.users = users
        self.didTouchProfile = didTouchProfile
        super.init(frame: .zero)
        
        backgroundColor = .systemGroupedBackground
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setImage(_ image: UIImage) {
        profileImageView.setImage(with: image)
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
        
        addSubview(channelNameTextField)
        channelNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            channelNameTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            channelNameTextField.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            channelNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTouchProfileImageView(_ sender: UIView) {
        didTouchProfile()
    }
    
}
