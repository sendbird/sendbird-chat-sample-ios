//
//  GroupChannelViewController+EditMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendbirdChatSDK

extension GroupChannelViewController {
    
    func handleLongPress(for message: BaseMessage) {
        if let userMessage = message as? UserMessage {
            presentEditUserMessageAlert(for: userMessage)
        } else if let fileMessage = message as? FileMessage {
            presentEditFileMessageAlert(for: fileMessage)
        }
    }
    
    private func presentEditUserMessageAlert(for message: UserMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.message, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Reply", style: .default) { [weak self] _ in
                self?.presentReplyUserMessageAlert(for: message)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(alert, animated: true)
    }
    
    private func presentReplyUserMessageAlert(for message: UserMessage) {
        presentTextFieldAlert(title: "Reply to message", message: "Enter your reply", defaultTextFieldMessage: "") { [weak self] messageString in
            self?.replyMessageUseCase.replyToMessage(message,reply: messageString) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        }
    }
    
    private func presentEditFileMessageAlert(for message: FileMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.name, preferredStyle: .actionSheet)
        
        if message.sendingStatus == .failed {
            alert.addAction(
                UIAlertAction(title: "Resend", style: .default) { [weak self] _ in
                    self?.resend(message)
                }
            )
        }
                
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(alert, animated: true)
    }
    
    private func resend(_ message: UserMessage) {
        userMessageUseCase.resendMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    private func resend(_ message: FileMessage) {
        fileMessageUseCase.resendMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
}
