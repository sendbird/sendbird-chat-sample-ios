//
//  OpenChannelViewController+FileMessage.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import MobileCoreServices

extension OpenChannelViewController {

    private enum SourceType {
        case photoLibrary
        case photoCamera
        case videoCamera
    }

    func presentAttachFileAlert() {
        let alert = UIAlertController(title: "Attach file", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Choose from Library...", style: .default) { [weak self] _ in
            self?.presentMediaFilePicker(sourceType: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "Take Photo...", style: .default) { [weak self] _ in
            self?.presentMediaFilePicker(sourceType: .photoCamera)
        })
        alert.addAction(UIAlertAction(title: "Take Video...", style: .default) { [weak self] _ in
            self?.presentMediaFilePicker(sourceType: .videoCamera)
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func presentMediaFilePicker(sourceType: SourceType) {
        let imagePicker = UIImagePickerController()

        switch sourceType {
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        case .photoCamera:
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [String(kUTTypeImage)]
        case .videoCamera:
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
        }
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }

}

extension OpenChannelViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private struct MediaFile {
        let data: Data
        let name: String
        let mimeType: String
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let file = extractFile(from: info) else { return }
        
        picker.dismiss(animated: true) { [weak self] in
            self?.fileMessageUseCase.sendFile(.init(data: file.data, name: file.name, mimeType: file.mimeType)) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        }
    }
    
    private func extractFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        
        if CFStringCompare(mediaType, kUTTypeImage, []) == .compareEqualTo {
            return extractImageFile(from: info)
        } else if CFStringCompare(mediaType, kUTTypeMovie, []) == .compareEqualTo {
            return extractVideoFile(from: info)
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
    
    private func extractVideoFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
        guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              let videoFileData = try? Data(contentsOf: videoUrl) else { return nil }
        
        let videoName = videoUrl.lastPathComponent
        let ext = (videoName as NSString).pathExtension
        guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue(),
              let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)?.takeRetainedValue() else { return nil }

        let mimeType = retainedValueMimeType as String
        
        return MediaFile(data: videoFileData, name: videoName, mimeType: mimeType)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
