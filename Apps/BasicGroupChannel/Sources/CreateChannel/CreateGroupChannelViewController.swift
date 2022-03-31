//
//  CreateGroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import CommonModule
import SendbirdChat
import MobileCoreServices

class CreateGroupChannelViewController: UIViewController {
    
    typealias DidCreateChannelHandler = (GroupChannel) -> Void
    
    private lazy var containerView: UIView = {
        let containerView: UIView = UIView()
        containerView.backgroundColor = .systemGroupedBackground
        return containerView
    }()
    
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
        cameraIamgeView.image = BasicGroupChannelAsset.imgIconEditCamera.image
        return cameraIamgeView
    }()
    
    private lazy var channelNameTextField: UITextField = {
        let channelNameTextField = UITextField()
        channelNameTextField.placeholder = "Channel Name"
        return channelNameTextField
    }()
    
    private let users: [User]
    private let didCreateChannel: DidCreateChannelHandler?
    private var channelImageData: Data?
    
    private lazy var useCase = CreateGroupChannelUseCase(users: users)
    
    private lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoCamera, .photoLibrary])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()

    init(users: [User], didCreateChannel: DidCreateChannelHandler? = nil) {
        self.users = users
        self.didCreateChannel = didCreateChannel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        containerView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        
        containerView.addSubview(cameraImageView)
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraImageView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cameraImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            cameraImageView.widthAnchor.constraint(equalToConstant: 28),
            cameraImageView.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        containerView.addSubview(channelNameTextField)
        channelNameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            channelNameTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            channelNameTextField.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            channelNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
        
        setupNavigation()
        setupTextField()
    }
    
    private func setupTextField() {
        let memberNicknames = Array(users.prefix(4)).compactMap { $0.nickname }
        let channelNamePlaceholder = memberNicknames.joined(separator: ", ")
        channelNameTextField.placeholder = channelNamePlaceholder
    }
        
    private func setupNavigation() {
        title = "Create Group Channel"
        navigationItem.largeTitleDisplayMode = .never

        let createButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTouchCreateGroupChannel(_ :)))
        navigationItem.rightBarButtonItem = createButtonItem
    }
    
    @objc private func didTouchCreateGroupChannel(_ sender: AnyObject) {
        let channelName = self.channelNameTextField.text != "" ? self.channelNameTextField.text : self.channelNameTextField.placeholder

        useCase.createGroupChannel(channelName: channelName, imageData: channelImageData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let channel):
                    self?.dismiss(animated: true) {
                        self?.didCreateChannel?(channel)
                    }
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        }
    }
    
    @objc private func didTouchProfileImageView(_ sender: UIView) {
        imagePickerRouter.presentAlert()
    }
    
}

// MARK: - ImagePickerRouterDelegate

extension CreateGroupChannelViewController: ImagePickerRouterDelegate {
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        guard let image = UIImage(data: mediaFile.data) else { return }
        
        profileImageView.setImage(with: image)
        channelImageData = mediaFile.data
    }
    
}
