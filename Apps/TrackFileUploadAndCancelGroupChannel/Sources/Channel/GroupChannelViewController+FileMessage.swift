//
//  GroupChannelViewController+FileMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendbirdChatSDK
import CommonModule

extension GroupChannelViewController: ImagePickerRouterDelegate {

    func presentAttachFileAlert() {
        imagePickerRouter.presentAlert()
    }
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        targetMessageForScrolling = fileMessageUseCase.sendFile(.init(data: mediaFile.data, name: mediaFile.name, mimeType: mediaFile.mimeType)) { [weak self] result in
            switch result {
            case .success(let sendedMessage):
                self?.targetMessageForScrolling = sendedMessage
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }

}

extension GroupChannelViewController: TrackAndCancelFileUploadUseCaseDelegate {
    func trackAndCancelFileUploadUseCase(_ usecase: TrackAndCancelFileUploadUseCase, willUploadMessage message: FileMessage?) {
        present(alertView, animated: true, completion: {
            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: 72.0, width: self.alertView.view.frame.width - margin * 2.0 , height: 2.0)
            self.progressView.frame = rect
            self.alertView.view.addSubview(self.progressView)
        })

    }
    
    func trackAndCancelFileUploadUseCase(_ usecase: TrackAndCancelFileUploadUseCase, didSuccessUploadMessage message: FileMessage) {
        alertView.dismiss(animated: true, completion: nil)
    }
    
    func trackAndCancelFileUploadUseCase(_ usecase: TrackAndCancelFileUploadUseCase, didFailedUploadMessage error: SBError) {
        alertView.dismiss(animated: true, completion: nil)
    }
    func trackAndCancelFileUploadUseCase(_ usecase: TrackAndCancelFileUploadUseCase, fileProgress progress: Float) {
        progressView.progress = progress
    }
}
