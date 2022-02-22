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
    
    @IBOutlet private weak var profileEditView: ProfileEditView!
    
    private var selectedImageData: Data?
    
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
    
    public init() {
        super.init(nibName: "ProfileEditViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile Image & Name"
        navigationItem.rightBarButtonItem = doneButtonItem
        
        profileEditView.delegate = self
        
        guard let currentUser = UserConnectionUseCase.shared.currentUser else { return }
        
        profileEditView.setUsers([currentUser])
        profileEditView.text = currentUser.nickname
        profileEditView.placeholder = "Please write your nickname"
    }
    
    @objc private func didTouchUpdateButton() {
        UserConnectionUseCase.shared.updateUserInfo(nickname: profileEditView.text, profileImage: selectedImageData) { [weak self] result in
            switch result {
            case .success:
                self?.dismiss(animated: true)
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
