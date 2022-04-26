//
//  OpenChannelViewController+FileMessage.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendbirdChatSDK
import CommonModule

extension OpenChannelViewController: ImagePickerRouterDelegate {

    func presentAttachFileAlert() {
        imagePickerRouter.presentAlert()
    }
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        var sendingMessage: BaseMessage?
        
        sendingMessage = fileMessageUseCase.sendFile(.init(data: mediaFile.data, name: mediaFile.name, mimeType: mediaFile.mimeType)) { [weak self] result in
            switch result {
            case .success(let message):
                self?.targetMessageForScrolling = message
                self?.messageListUseCase.didSuccessSendMessage(message)
            case .failure(let error):
                self?.targetMessageForScrolling = nil
                self?.messageListUseCase.didFailSendMessage(sendingMessage)
                self?.presentAlert(error: error)
            }
        }

        targetMessageForScrolling = sendingMessage
        messageListUseCase.didStartSendMessage(sendingMessage)
    }
    
}
