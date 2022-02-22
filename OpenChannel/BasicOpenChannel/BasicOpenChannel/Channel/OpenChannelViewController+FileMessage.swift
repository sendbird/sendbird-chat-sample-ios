//
//  OpenChannelViewController+FileMessage.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import CommonModule

extension OpenChannelViewController: ImagePickerRouterDelegate {

    func presentAttachFileAlert() {
        imagePickerRouter.presentAlert()
    }
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        fileMessageUseCase.sendFile(.init(data: mediaFile.data, name: mediaFile.name, mimeType: mediaFile.mimeType)) { [weak self] result in
            switch result {
            case .success(let message):
                self?.messageListUseCase.didSendMessage(message)
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
}
