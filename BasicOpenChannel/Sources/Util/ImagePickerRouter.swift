//
//  ImagePicker.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/22.
//

import UIKit
import MobileCoreServices

public struct ImagePickerMediaFile {
    public let data: Data
    public let name: String
    public let mimeType: String
}

public protocol ImagePickerRouterDelegate: AnyObject {
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile)
}

public class ImagePickerRouter: NSObject {
    
    typealias MediaFile = ImagePickerMediaFile
    
    public enum SourceType {
        case photoLibrary
        case photoCamera
        case videoCamera
    }
    
    public weak var delegate: ImagePickerRouterDelegate?
    
    private unowned let target: UIViewController
    
    private let sourceTypes: Set<SourceType>
    
    public init(target: UIViewController, sourceTypes: Set<SourceType>) {
        self.target = target
        self.sourceTypes = sourceTypes
        super.init()
    }
    
    public func presentAlert() {
        let alert = UIAlertController(title: "Attach file", message: nil, preferredStyle: .actionSheet)
        
        if sourceTypes.contains(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Choose from Library...", style: .default) { [weak self] _ in
                self?.presentMediaFilePicker(sourceType: .photoLibrary)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if sourceTypes.contains(.photoCamera) {
                alert.addAction(UIAlertAction(title: "Take Photo...", style: .default) { [weak self] _ in
                    self?.presentMediaFilePicker(sourceType: .photoCamera)
                })
            }
            
            if sourceTypes.contains(.videoCamera) {
                alert.addAction(UIAlertAction(title: "Take Video...", style: .default) { [weak self] _ in
                    self?.presentMediaFilePicker(sourceType: .videoCamera)
                })
            }
        }
        
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        
        target.present(alert, animated: true)
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
        
        target.present(imagePicker, animated: true)
    }

}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ImagePickerRouter: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaFile = extractMediaFile(from: info) else { return }
        
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.imagePickerRouter(self, didFinishPickingMediaFile: mediaFile)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func extractMediaFile(from info: [UIImagePickerController.InfoKey : Any]) -> MediaFile? {
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
    
}

