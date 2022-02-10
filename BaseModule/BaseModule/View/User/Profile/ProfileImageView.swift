//
//  ProfileImageView.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import SendBirdSDK
import Kingfisher

public class ProfileImageView: UIView {
    
    public var users: [SBDUser] = [] {
        didSet {
            let index = (users.count > 3) ? 4 : users.count
            users = Array(users[0..<index])
            setUpImageStack()
        }
    }
    
    public var spacing: CGFloat = 0 {
        didSet {
            for subView in self.subviews{
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
        for subView in self.subviews{
            subView.removeFromSuperview()
        }
        
        let mainStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        mainStackView.axis = .horizontal
        mainStackView.spacing = spacing
        mainStackView.distribution = .fillEqually
        self.addSubview(mainStackView)
        
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
        
        for user in users{
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(withUser: user)
            imageContainerView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            if users.count == 1 {
                mainStackView.addArrangedSubview(imageContainerView)
            }
            else {
                
                let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                stackView.addArrangedSubview(imageContainerView)
                stackView.axis = .vertical
                stackView.distribution = .fillEqually
                stackView.spacing = spacing
                
                imageView.heightAnchor.constraint(equalToConstant: imageContainerView.frame.height).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                
                if mainStackView.arrangedSubviews.count < 2 {
                    mainStackView.addArrangedSubview(stackView)
                }
                else {
                    for subView in mainStackView.arrangedSubviews {
                        if (subView as? UIStackView)?.arrangedSubviews.count == 1 {
                            (subView as? UIStackView)?.addArrangedSubview(imageContainerView)
                        }
                    }
                }
            }
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
        }
    }
    
    
    public init(users: [SBDUser], frame: CGRect){
        super.init(frame: frame)
        self.setUser(newUsers: users)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public func setUser(newUsers: [SBDUser]) {
        self.users = newUsers
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    public func setImage(withImage image: UIImage){
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
    
    public convenience init(withUser user: SBDUser) {
        self.init()
        setProfileImageView(for: user)
    }
    
    public func setProfileImageView(for user: SBDUser) {
        if let url = URL(string: ImageUtil.transformUserProfileImage(user: user)){
            kf.setImage(with: url, placeholder: ImageUtil.getDefaultUserProfileImage(user: user))
        } else {
            image = ImageUtil.getDefaultUserProfileImage(user: user)
        }
    }
}

class ImageUtil {
    static func transformUserProfileImage(user: SBDUser) -> String {
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
    
    static func getDefaultUserProfileImage(user: SBDUser) -> UIImage? {
        if let nickname = user.nickname, let image = UIImage.named("img_default_profile_image_\(nickname.count % 4)") {
            return image
        }
        
        return UIImage.named("img_default_profile_image_1")
    }
}
