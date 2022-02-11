//
//  GroupChannelViewController+EditMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK

extension GroupChannelViewController {
    
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
        let alert = UIAlertController(title: "Update message", message: "Enter new text", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = message.message
        }

        alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak alert, weak self] _ in
            guard let textField = alert?.textFields?.first else { return }
            
            self?.inputUseCase.updateMessage(message, to: textField.text ?? "", completion: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            })
        })
        
        self.present(alert, animated: true)
    }
    
    private func deleteMessage(_ message: SBDBaseMessage) {
        inputUseCase.deleteMessage(message) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    private func presentEditFileMessageAlert(for message: SBDFileMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: "(File)", preferredStyle: .actionSheet)
        
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
    
}
