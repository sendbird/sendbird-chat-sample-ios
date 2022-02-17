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
        title = "Create Group Channel"
        navigationItem.largeTitleDisplayMode = .never

        let createButtonItem = UIBarButtonItem(title: "Create", style: .done, target: self, action: #selector(didTouchCreateGroupChannel(_ :)))
        navigationItem.rightBarButtonItem = createButtonItem
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
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        alert.modalPresentationStyle = .popover
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(
                UIAlertAction(title: "Take Photo...", style: .default) { [weak self] action in
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    let mediaTypes = [String(kUTTypeImage)]
                    picker.mediaTypes = mediaTypes
                    picker.delegate = self
                    self?.present(picker, animated: true)
                }
            )
        }
        
        alert.addAction(
            UIAlertAction(title: "Choose from Library...", style: .default) { [weak self] action in
                let picker = UIImagePickerController()
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                let mediaTypes = [String(kUTTypeImage)]
                picker.mediaTypes = mediaTypes
                picker.delegate = self
                self?.present(picker, animated: true)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Close", style: .cancel)
        )
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = sender
            presenter.sourceRect = sender.frame
        }
        
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension CreateOpenChannelViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        picker.dismiss(animated: true) { [weak self] in
            guard CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo,
                  let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self?.profileImageView.setImage(with: originalImage)

            guard let imageData = originalImage.jpegData(compressionQuality: 0.5) else { return }
            self?.channelImageData = imageData
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

}
