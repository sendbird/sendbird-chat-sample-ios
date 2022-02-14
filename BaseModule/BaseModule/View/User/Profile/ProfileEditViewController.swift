//
//  ProfileEditViewController.swift
//  BaseModule
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
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                
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
        
        present(alert, animated: true, completion: nil)

    }
    
}

extension ProfileEditViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private struct MediaFile {
        let data: Data
        let name: String
        let mimeType: String
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let file = extractFile(from: info) else { return }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let image = UIImage(data: file.data) else { return }
            self?.profileEditView.setImage(with: image)
            self?.selectedImageData = file.data
        }
    }
    
    private func extractFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo {
            return extractImageFile(from: info)
        }
        
        return nil
    }
    
    private func extractImageFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        if let imagePath = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let imageName = imagePath.lastPathComponent
            let ext = (imageName as NSString).pathExtension
            guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() else { return nil }
            guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return nil }
            let mimeType = retainedValueMimeType as String
            guard let imageData = try? Data.init(contentsOf: imagePath) else { return nil }
            
            return MediaFile(data: imageData, name: imageName, mimeType: mimeType)
        } else {
            guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return nil }
            guard let imageData = originalImage.jpegData(compressionQuality: 1.0) else { return nil }
            
            return MediaFile(data: imageData, name: "image.jpg", mimeType: "image/jpeg")
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
