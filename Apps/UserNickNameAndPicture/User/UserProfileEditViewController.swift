//
//  ProfileEditViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import UIKit
import PhotosUI
import MobileCoreServicesc
import CommonModule

public class UserProfileEditViewController: UIViewController {
    
    public typealias CompletionHandler = () -> Void
    
    private lazy var profileEditView: ProfileEditView = {
        let profileEditView = ProfileEditView { [weak self] in
            self?.imagePickerRouter.presentAlert()
        }
        profileEditView.placeholder = "Please write your nickname"
        
        if let currentUser = UserConnectionUseCase.shared.currentUser {
            profileEditView.setUsers([currentUser])
            profileEditView.text = currentUser.nickname
        }
        
        return profileEditView
    }()
    
    private lazy var userUpdateUseCase = UserNicknameAndPictureUseCase()
    
    private let completion: CompletionHandler?
    
    private var selectedImageData: Data?
    
    private lazy var cancelButtonItem = UIBarButtonItem(
        title: "Cancel",
        style: .plain,
        target: self,
        action: #selector(didTouchCancelButton)
    )
    
    private lazy var doneButtonItem = UIBarButtonItem(
        title: "Done",
        style: .done,
        target: self,
        action: #selector(didTouchUpdateButton)
    )
    
    private lazy var imagePickerRouter: ImagePickerRouter = {
        let imagePickerRouter = ImagePickerRouter(target: self, sourceTypes: [.photoLibrary])
        imagePickerRouter.delegate = self
        return imagePickerRouter
    }()
    
    init(completion: CompletionHandler? = nil) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigation()
        setupProfileEditView()
    }
    
    private func setupNavigation() {
        title = "Profile Image & Name"
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = doneButtonItem
    }
    
    private func setupProfileEditView() {
        view.addSubview(profileEditView)
        profileEditView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileEditView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            profileEditView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            profileEditView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            profileEditView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    @objc private func didTouchCancelButton() {
        dismiss(animated: true) { [weak self] in
            self?.completion?()
        }
    }
    
    @objc private func didTouchUpdateButton() {
        userUpdateUseCase.updateUserInfo(nickname: profileEditView.text, profileImage: selectedImageData) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true, completion: {
                    self?.completion?()
                })
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
}

// MARK: - ImagePickerRouterDelegate

extension UserProfileEditViewController: ImagePickerRouterDelegate {

    public func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        guard let image = UIImage(data: mediaFile.data) else { return }
        
        profileEditView.setImage(image)
        selectedImageData = mediaFile.data
    }

}
