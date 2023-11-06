//
//  CreateOpenChannelViewController.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import SendbirdChatSDK
import MobileCoreServices

class CreateOpenChannelViewController: UIViewController {
    
    typealias DidCreateChannelHandler = (OpenChannel) -> Void
        
    private let didCreateChannel: DidCreateChannelHandler?
    private var channelImageData: Data?
    
    private lazy var useCase = CreateOpenChannelUseCase()
    
    private lazy var channelEditView = ProfileEditView(didTouchProfile: { [weak self] in
        self?.imagePickerRouter.presentAlert()
    })
        
    private lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoLibrary, .photoCamera])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()

    init(didCreateChannel: DidCreateChannelHandler? = nil) {
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
        channelEditView.placeholder = "Channel Name"
    }
        
    private func setupNavigation() {
        title = "Create Open Channel"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTouchCancelButton(_ :)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTouchCreateGroupChannel(_ :)))
    }
    
    @objc private func didTouchCancelButton(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    @objc private func didTouchCreateGroupChannel(_ sender: AnyObject) {
        let channelName = channelEditView.text != "" ? channelEditView.text : channelEditView.placeholder

        useCase.createOpenChannel(channelName: channelName, imageData: channelImageData) { [weak self] result in
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

extension CreateOpenChannelViewController: ImagePickerRouterDelegate {
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        guard let image = UIImage(data: mediaFile.data) else { return }
        
        channelEditView.setImage(image)
        channelImageData = mediaFile.data
    }
    
}
