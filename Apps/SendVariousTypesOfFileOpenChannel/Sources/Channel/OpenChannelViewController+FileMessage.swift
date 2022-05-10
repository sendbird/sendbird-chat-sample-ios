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
        let actionSheet = UIAlertController(title: "Choose", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(
            UIAlertAction(title: "Choose Album", style: .default) { [weak self] _ in
                self?.imagePickerRouter.presentAlert()
            }
        )

        actionSheet.addAction(
            UIAlertAction(title: "Upload PDF", style: .destructive) { [weak self] _ in
                self?.sendPDFFile()
            }
        )
        
        actionSheet.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(actionSheet, animated: true, completion: nil)
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
    
    func sendPDFFile() {
        var sendingMessage: BaseMessage?
        guard let url = Bundle.main.url(
            forResource: "Sample_Sendbird",
            withExtension: "pdf"
        ) else {
            return
        }
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        sendingMessage = fileMessageUseCase.sendFile(.init(data: data, name: "Sample_Sendbird.pdf", mimeType: "application/pdf")) { [weak self] result in
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
