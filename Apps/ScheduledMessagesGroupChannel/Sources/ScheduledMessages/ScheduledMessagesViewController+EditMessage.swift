//
//  ScheduledMessagesViewController+EditMessage.swift
//  ScheduledMessagesGroupChannel
//
//  Created by Mihai Moisanu on 21.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension ScheduledMessagesViewController{
    
    func handleLongPress(for message:BaseMessage){
        guard message.sender?.userId == SendbirdChat.getCurrentUser()?.userId else { return }
        if let userMessage = message as? UserMessage {
            presentEditUserMessageAlert(for: userMessage)
        } else if let fileMessage = message as? FileMessage {
            presentEditFileMessageAlert(for: fileMessage)
        }
    }
    
    private func presentEditUserMessageAlert(for message: UserMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.message, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Send now", style: .default) { [weak self] _ in
                guard let scheduleInfo = message.scheduledInfo else { return }
                self?.channel.sendScheduledMessageNow(scheduledMessageId: scheduleInfo.scheduledMessageId, completionHandler: { [weak self] error in
                    if let error = error {
                        self?.presentAlert(error: error)
                        return
                    }
                    self?.loadMessages()
                }
                )
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Reschedule", style: .default) { [weak self] _ in
                self?.presentScheduleMessageAlert(onDateSelected: {[weak self] timestamp in
                    guard let scheduleInfo  = message.scheduledInfo else { return }
                    self?.scheduledMesssagesUseCase.rescheduleUserMessage(timestamp, scheduleInfo.scheduledMessageId, completion: {[weak self] error in
                        if let error = error {
                            self?.presentAlert(error: error)
                            return
                        }
                        self?.loadMessages()
                    })
                })
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let scheduleInfo = message.scheduledInfo else { return }
                self?.channel.cancelScheduledMessage(scheduledMessageId: scheduleInfo.scheduledMessageId, completionHandler: { [weak self] error in
                    if let error = error {
                        self?.presentAlert(error: error)
                        return
                    }
                    self?.loadMessages()
                })})
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        present(alert, animated: true)
    }
    
    private func presentEditFileMessageAlert(for message: FileMessage) {
        let alert = UIAlertController(title: "Choose action for message", message: message.message, preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Send now", style: .default) { [weak self] _ in
                guard let scheduleInfo = message.scheduledInfo else { return }
                self?.channel.sendScheduledMessageNow(scheduledMessageId: scheduleInfo.scheduledMessageId, completionHandler: { [weak self] error in
                    if let error = error {
                        self?.presentAlert(error: error)
                        return
                    }
                    self?.loadMessages()
                }
                )
            })
        
        alert.addAction(
            UIAlertAction(title: "Reschedule", style: .default) { [weak self] _ in
                self?.presentScheduleMessageAlert(onDateSelected: {[weak self] timestamp in
                    guard let scheduleInfo  = message.scheduledInfo else { return }
                    self?.scheduledMesssagesUseCase.rescheduleFileMessage(timestamp, scheduleInfo.scheduledMessageId, completion: {[weak self] error in
                        if let error = error {
                            self?.presentAlert(error: error)
                            return
                        }
                        self?.loadMessages()
                    })
                })
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let scheduleInfo = message.scheduledInfo else { return }
                self?.channel.cancelScheduledMessage(scheduledMessageId: scheduleInfo.scheduledMessageId, completionHandler: { [weak self] error in
                    if let error = error {
                        self?.presentAlert(error: error)
                        return
                    }
                    self?.loadMessages()
                }
                )
            }
        )
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        
        present(alert, animated: true)
    }
}
