//
//  ProfileImageView.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import SendbirdChat
import Kingfisher

public class ProfileImageView: UIView {
    
    public var users: [SBDUser] = [] {
        didSet {
            let maxLength = min(4, users.count)
            users = Array(users.prefix(maxLength))
            setUpImageStack()
        }
    }
    
    public var spacing: CGFloat = 0 {
        didSet {
            for subView in self.subviews {
                if let stack = subView as? UIStackView{
                    for subStack in stack.arrangedSubviews{
                        (subStack as? UIStackView)?.spacing = spacing
                    }
                }
                (subView as? UIStackView)?.spacing = spacing
            }
        }
    }
    
    public func makeCircularWithSpacing(spacing: CGFloat){
        self.layer.cornerRadius = self.frame.height/2
        self.spacing = spacing
    }
    
    private func setUpImageStack() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        let mainStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        mainStackView.axis = .horizontal
        mainStackView.spacing = spacing
        mainStackView.distribution = .fillEqually
        addSubview(mainStackView)
        
        if users.isEmpty {
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(image: UIImage(named: "img_default_profile_image_1"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            
            imageContainerView.addSubview(imageView)
            mainStackView.addArrangedSubview(imageContainerView)
            
            imageView.heightAnchor.constraint(equalTo: imageContainerView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
        }
        
        users.forEach { user in
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(with: user)
            imageContainerView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false

            if users.count == 1 {
                mainStackView.addArrangedSubview(imageContainerView)
            } else {
                let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                stackView.addArrangedSubview(imageContainerView)
                stackView.axis = .vertical
                stackView.distribution = .fillEqually
                stackView.spacing = spacing
                
                imageView.heightAnchor.constraint(equalToConstant: imageContainerView.frame.height).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                
                if mainStackView.arrangedSubviews.count < 2 {
                    mainStackView.addArrangedSubview(stackView)
                } else {
                    mainStackView.arrangedSubviews
                        .compactMap { $0 as? UIStackView }
                        .filter { $0.arrangedSubviews.count == 1 }
                        .forEach { $0.addArrangedSubview($0) }
                }
            }
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
        }
    }
    
    public init(users: [SBDUser], frame: CGRect){
        super.init(frame: frame)
        self.setUsers(users)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setUsers(_ newUsers: [SBDUser]) {
        self.users = newUsers
    }
    
    public func setImage(withCoverUrl coverUrl: String){
        let imageView = UIImageView()
        if let url = URL(string: coverUrl){
            imageView.kf.setImage(with: url, placeholder: UIImage.named("img_cover_image_placeholder_1"))
        }
        else {
            imageView.image = UIImage.named("img_cover_image_placeholder_1")
        }
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        self.addSubview(stackView)
        makeCircularWithSpacing(spacing: 0)
    }
    
    public func setImage(with image: UIImage){
        let imageView = UIImageView(image: image)
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        self.addSubview(stackView)
        makeCircularWithSpacing(spacing: 0)
    }
    
}

extension UIImageView {
    
    public convenience init(with user: SBDUser) {
        self.init()
        setProfileImageView(for: user)
    }
    
    public func setProfileImageView(for user: SBDUser) {
        if let url = URL(string: transformUserProfileImage(user: user)){
            kf.setImage(with: url, placeholder: defaultUserProfileImage(user: user))
        } else {
            image = defaultUserProfileImage(user: user)
        }
    }
    
    private func transformUserProfileImage(user: SBDUser) -> String {
        if let profileUrl = user.profileUrl {
            if profileUrl.hasPrefix("https://sendbird.com/main/img/profiles") {
                return ""
            }
            else {
                return profileUrl
            }
        }
        
        return ""
    }
    
    private func defaultUserProfileImage(user: SBDUser) -> UIImage? {
        if let nickname = user.nickname, let image = UIImage.named("img_default_profile_image_\(nickname.count % 4)") {
            return image
        }
        
        return UIImage.named("img_default_profile_image_1")
    }
    
}
