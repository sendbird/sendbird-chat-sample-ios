//
//  CreateOpenChannelViewController.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import CommonModule
import SendBirdSDK
import MobileCoreServices

class CreateOpenChannelViewController: UIViewController {
    
    typealias DidCreateChannelHandler = (SBDOpenChannel) -> Void
    
    @IBOutlet private weak var channelNameTextField: UITextField!
    @IBOutlet private weak var profileImageView: ProfileImageView!
    
    private let didCreateChannel: DidCreateChannelHandler?
    private var channelImageData: Data?
    
    private lazy var useCase = CreateOpenChannelUseCase()
    
    private lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoLibrary, .photoCamera])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()

    init(didCreateChannel: DidCreateChannelHandler? = nil) {
        self.didCreateChannel = didCreateChannel
        super.init(nibName: "CreateOpenChannelViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTextField()
        setupProfileImageView()
    }
    
    private func setupTextField() {
        channelNameTextField.placeholder = "Channel Name"
    }
    
    private func setupProfileImageView() {
        self.profileImageView.isUserInteractionEnabled = true
        let tapCoverImageGesture = UITapGestureRecognizer(target: self, action: #selector(didTouchProfileImageView(_ :)))
        self.profileImageView.addGestureRecognizer(tapCoverImageGesture)
        
        profileImageView.makeCircularWithSpacing(spacing: 1)
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
        let channelName = self.channelNameTextField.text != "" ? self.channelNameTextField.text : self.channelNameTextField.placeholder

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
    
    @objc private func didTouchProfileImageView(_ sender: UIView) {
        imagePickerRouter.presentAlert()
    }
    
}

// MARK: - ImagePickerRouterDelegate

extension CreateOpenChannelViewController: ImagePickerRouterDelegate {
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        guard let image = UIImage(data: mediaFile.data) else { return }
        
        profileImageView.setImage(with: image)
        channelImageData = mediaFile.data
    }
    
}
