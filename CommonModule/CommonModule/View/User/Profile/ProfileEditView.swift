//
//  ProfileEditView.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import UIKit
import SendBirdSDK

public protocol ProfileEditViewDelegate: AnyObject {
    func profileEditViewDidTouchProfileImage(_ profileEditView: ProfileEditView)
}

// MARK: - ProfileEditView

public class ProfileEditView: UIView, NibLoadable {
    
    public weak var delegate: ProfileEditViewDelegate?
    
    @IBOutlet private weak var profileImageView: ProfileImageView!
    
    @IBOutlet private weak var textField: UITextField!
    
    public var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    public var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        setupFromNib()
        profileImageView.makeCircularWithSpacing(spacing: 1)
        profileImageView.isUserInteractionEnabled = true
        let tapProfileImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTouchProfileImage))
        profileImageView.addGestureRecognizer(tapProfileImageGesture)
    }
    
    public func setUsers(_ newUsers: [SBDUser]) {
        profileImageView.setUsers(newUsers)
    }
    
    public func setImage(withCoverUrl coverUrl: String) {
        profileImageView.setImage(withCoverUrl: coverUrl)
    }
    
    public func setImage(with image: UIImage) {
        profileImageView.setImage(with: image)
    }
    
    @objc private func didTouchProfileImage() {
        delegate?.profileEditViewDidTouchProfileImage(self)
    }
    
}
