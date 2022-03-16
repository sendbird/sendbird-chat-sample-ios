//
//  OpenChannelViewController+EditMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendbirdChat

extension OpenChannelViewController {
    
    func presentEditMessageAlert(for message: SBDBaseMessage) {
        guard message.sender?.userId == SBDMain.getCurrentUser()?.userId else { return }
        
        if let userMessage = message as? SBDUserMessage {
            presentEditUserMessageAlert(for: userMessage)
        } else if let fileMessage = message as? SBDFileMessage {
            presentEditFileMessageAlert(for: fileMessage)
        }
    }
    
    private func presentEditUserMessageAlert(for message: SBDUserMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.message, preferredStyle: .actionSheet)
        
        if message.sendingStatus == .failed {
            alert.addAction(
                UIAlertAction(title: "Resend", style: .default) { [weak self] _ in
                    self?.resend(message)
                }
            )
        }
        
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
    
    private func presentUpdateUserMessageAlert(for message: SBDUserMessage) {
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
    
    private func deleteMessage(_ message: SBDBaseMessage) {
        userMessageUseCase.deleteMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    private func presentEditFileMessageAlert(for message: SBDFileMessage) {
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
    
    private func resend(_ message: SBDUserMessage) {
        userMessageUseCase.resendMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    private func resend(_ message: SBDFileMessage) {
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
