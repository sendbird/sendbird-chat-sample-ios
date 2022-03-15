//
//  ProfileEditViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import UIKit
import PhotosUI
import MobileCoreServices

public class ProfileEditViewController: UIViewController {
    
    public typealias CompletionHandler = () -> Void
    
    @IBOutlet private weak var profileEditView: ProfileEditView!
    
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
    
    public init(completion: CompletionHandler? = nil) {
        self.completion = completion
        super.init(nibName: "ProfileEditViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupProfileEditView()
    }
    
    private func setupNavigation() {
        title = "Profile Image & Name"
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = doneButtonItem
    }
    
    private func setupProfileEditView() {
        profileEditView.placeholder = "Please write your nickname"
        profileEditView.delegate = self
        
        guard let currentUser = UserConnectionUseCase.shared.currentUser else { return }
        
        profileEditView.setUsers([currentUser])
        profileEditView.text = currentUser.nickname
    }
    
    @objc private func didTouchCancelButton() {
        dismiss(animated: true) { [weak self] in
            self?.completion?()
        }
    }
    
    @objc private func didTouchUpdateButton() {
        UserConnectionUseCase.shared.updateUserInfo(nickname: profileEditView.text, profileImage: selectedImageData) { [weak self] result in
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

// MARK: - ProfileEditViewDelegate

extension ProfileEditViewController: ProfileEditViewDelegate {

    public func profileEditViewDidTouchProfileImage(_ profileEditView: ProfileEditView) {
        imagePickerRouter.presentAlert()
    }
    
}

// MARK: - ImagePickerRouterDelegate

extension ProfileEditViewController: ImagePickerRouterDelegate {

    public func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        guard let image = UIImage(data: mediaFile.data) else { return }
        
        profileEditView.setImage(with: image)
        selectedImageData = mediaFile.data
    }

}
