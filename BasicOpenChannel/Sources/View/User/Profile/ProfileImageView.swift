//
//  ProfileImageView.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import SendbirdChatSDK
import Kingfisher

public class ProfileImageView: UIView {
    
    public var users: [User] = [] {
        didSet {
            let maxLength = min(4, users.count)
            users = Array(users.prefix(maxLength))
            updateImageStack()
        }
    }
    
    public var spacing: CGFloat = 0 {
        didSet {
            mainStackView.spacing = spacing
            topSubStackView.spacing = spacing
            bottomSubStackView.spacing = spacing
        }
    }
    
    private lazy var mainStackView: UIStackView = {
        let mainStackView: UIStackView = UIStackView(frame: .zero)
        mainStackView.axis = .horizontal
        mainStackView.spacing = spacing
        mainStackView.distribution = .fillEqually
        return mainStackView
    }()
            
    private lazy var topSubStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        return stackView
    }()
    
    private lazy var bottomSubStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        return stackView
    }()
    
    private lazy var mainImageView: UIImageView = {
        let mainImageView = UIImageView(image: BasicOpenChannelAsset.imgDefaultProfileImage1.image)
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.clipsToBounds = true
        mainImageView.contentMode = .scaleAspectFill
        return mainImageView
    }()
    
    private lazy var subImageViews: [UIImageView] = (0..<4).map { _ in
        let imageView = UIImageView(image: BasicOpenChannelAsset.imgDefaultProfileImage1.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageStack()
    }
        
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupImageStack()
    }
    
    public func setUsers(_ newUsers: [User]) {
        self.users = newUsers
    }
    
    public func makeCircularWithSpacing(spacing: CGFloat){
        self.layer.cornerRadius = self.frame.height/2
        self.spacing = spacing
        self.clipsToBounds = true
    }
    
    public func setImage(withCoverUrl coverUrl: String) {
        makeCircularWithSpacing(spacing: 0)
        users = []
        
        if let url = URL(string: coverUrl){
            mainImageView.kf.setImage(with: url, placeholder: BasicOpenChannelAsset.imgDefaultProfileImage1.image)
        } else {
            mainImageView.image = BasicOpenChannelAsset.imgDefaultProfileImage1.image
        }
    }
    
    public func setImage(with image: UIImage) {
        makeCircularWithSpacing(spacing: 0)
        users = []
        
        mainImageView.image = image
    }
        
    private func setupImageStack() {
        addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        if users.isEmpty {
            mainImageView.translatesAutoresizingMaskIntoConstraints = false
            mainStackView.addArrangedSubview(mainImageView)
            mainImageView.clipsToBounds = true
        }
        
        mainStackView.addArrangedSubview(topSubStackView)
        topSubStackView.addArrangedSubview(subImageViews[0])
        topSubStackView.addArrangedSubview(subImageViews[1])
        
        mainStackView.addArrangedSubview(bottomSubStackView)
        bottomSubStackView.addArrangedSubview(subImageViews[2])
        bottomSubStackView.addArrangedSubview(subImageViews[3])
        
        updateImageStack()
        makeCircularWithSpacing(spacing: 0)
    }
    
    private func updateImageStack() {
        switch users.count {
        case 0:
            mainImageView.image = BasicOpenChannelAsset.imgDefaultProfileImage1.image
            mainImageView.isHidden = false
            topSubStackView.isHidden = true
            bottomSubStackView.isHidden = true
        case 1, 2:
            mainImageView.isHidden = true
            topSubStackView.isHidden = false
            bottomSubStackView.isHidden = true
        case 3, 4:
            mainImageView.isHidden = true
            topSubStackView.isHidden = false
            bottomSubStackView.isHidden = false
        default:
            assertionFailure("The number of users must not exceed 4.")
        }
        
        subImageViews.forEach {
            $0.isHidden = true
        }
        
        users.enumerated().forEach { index, user in
            subImageViews[index].isHidden = false
            subImageViews[index].setProfileImageView(for: user)
        }
    }
    
}

extension UIImageView {
    
    public convenience init(with user: User) {
        self.init()
        setProfileImageView(for: user)
    }
    
    public func setProfileImageView(for user: User) {
        if let url = URL(string: transformUserProfileImage(user: user)){
            kf.setImage(with: url, placeholder: defaultUserProfileImage(user: user))
        } else {
            image = defaultUserProfileImage(user: user)
        }
    }
    
    private func transformUserProfileImage(user: User) -> String {
        if let profileUrl = user.profileURL {
            if profileUrl.hasPrefix("https://sendbird.com/main/img/profiles") {
                return ""
            }
            else {
                return profileUrl
            }
        }
        
        return ""
    }
    
    private func defaultUserProfileImage(user: User) -> UIImage? {
        if let image = UIImage.named("img_default_profile_image_\(user.nickname.count % 4)") {
            return image
        }
        
        return BasicOpenChannelAsset.imgDefaultProfileImage1.image
    }
    
}
