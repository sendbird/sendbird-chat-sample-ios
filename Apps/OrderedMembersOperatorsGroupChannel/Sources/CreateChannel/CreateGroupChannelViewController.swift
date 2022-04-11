//
//  CreateGroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import CommonModule
import SendbirdChatSDK
import MobileCoreServices

class CreateGroupChannelViewController: UIViewController {
    
    typealias DidCreateChannelHandler = (GroupChannel) -> Void
        
    private let users: [User]
    private let didCreateChannel: DidCreateChannelHandler?
    private var channelImageData: Data?
    
    private lazy var useCase = CreateGroupChannelUseCase(users: users)
    
    private lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoCamera, .photoLibrary])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()
    
    private lazy var channelEditView: ProfileEditView = {
        let channelEditView = ProfileEditView(didTouchProfile: { [weak self] in
            self?.imagePickerRouter.presentAlert()
        })
        channelEditView.setUsers(users)
        return channelEditView
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
        
        setupNavigation()
        setupEditView()
        setupTextField()
    }
    
    private func setupEditView() {
        view.addSubview(channelEditView)
        channelEditView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            channelEditView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            channelEditView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            channelEditView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            channelEditView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupTextField() {
        let memberNicknames = Array(users.prefix(4)).compactMap { $0.nickname }
        let channelNamePlaceholder = memberNicknames.joined(separator: ", ")
        channelEditView.placeholder = channelNamePlaceholder
    }
        
    private func setupNavigation() {
        title = "Create Group Channel"
        navigationItem.largeTitleDisplayMode = .never

        let createButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTouchCreateGroupChannel(_ :)))
        navigationItem.rightBarButtonItem = createButtonItem
    }
    
    @objc private func didTouchCreateGroupChannel(_ sender: AnyObject) {
        let channelName = channelEditView.text != "" ? channelEditView.text : channelEditView.placeholder

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
    
}

// MARK: - ImagePickerRouterDelegate

extension CreateGroupChannelViewController: ImagePickerRouterDelegate {
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        guard let image = UIImage(data: mediaFile.data) else { return }
        
        channelEditView.setImage(image)
        channelImageData = mediaFile.data
    }
    
}
