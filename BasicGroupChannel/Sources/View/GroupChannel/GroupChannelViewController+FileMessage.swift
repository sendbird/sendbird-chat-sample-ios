//
//  GroupChannelViewController+FileMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendbirdChatSDK

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
