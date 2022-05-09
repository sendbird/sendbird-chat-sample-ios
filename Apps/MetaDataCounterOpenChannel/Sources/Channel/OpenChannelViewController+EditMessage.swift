//
//  OpenChannelViewController+EditMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendbirdChatSDK

extension OpenChannelViewController {
    
    func presentEditMessageAlert(for message: BaseMessage) {
        guard message.sender?.userID == SendbirdChat.getCurrentUser()?.userID else { return }
        
        if let userMessage = message as? UserMessage {
            presentEditUserMessageAlert(for: userMessage)
        } else if let fileMessage = message as? FileMessage {
            presentEditFileMessageAlert(for: fileMessage)
        }
    }
    
    private func presentEditUserMessageAlert(for message: UserMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.message, preferredStyle: .actionSheet)
        
        if message.sendingStatus == .failed {
            alert.addAction(
                UIAlertAction(title: "Resend", style: .default) { [weak self] _ in
                    self?.resend(message)
                }
            )
        }
        
        alert.addAction(
            UIAlertAction(title: "Vote for background", style: .default) { [weak self] _ in
                self?.addExtraData(for: message)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                self?.presentUpdateUserMessageAlert(for: message)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.deleteMessage(message)
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(alert, animated: true)
    }
    
    private func addExtraData(for message: BaseMessage) {
        addExtraDataMessageUseCase.addExtraDataToMessage(message)
    }
    
    private func presentUpdateUserMessageAlert(for message: UserMessage) {
        presentTextFieldAlert(title: "Update message", message: "Enter new text", defaultTextFieldMessage: message.message) { [weak self] editedMessage in
            self?.userMessageUseCase.updateMessage(message, to: editedMessage, completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            })
        }
    }
    
    private func deleteMessage(_ message: BaseMessage) {
        userMessageUseCase.deleteMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    private func presentEditFileMessageAlert(for message: FileMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.name, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.deleteMessage(message)
            }
        )
        
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
