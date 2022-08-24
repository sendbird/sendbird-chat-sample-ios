//
//  GroupChannelViewController+Setting.swift
//  BasicGroupChannel
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendbirdChatSDK
import CommonModule

extension GroupChannelViewController {
    
    @objc func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: "Choose action for channel", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(
            UIAlertAction(title: "Member List", style: .default) { [weak self] _ in
                self?.pushMemberList()
            }
        )
        
        actionSheet.addAction(
            UIAlertAction(title: "Invite Members", style: .default) { [weak self] _ in
                self?.presentInviteMember()
            }
        )
        
        actionSheet.addAction(
            UIAlertAction(title: "Leave Channel", style: .destructive) { [weak self] _ in
                self?.presentLeaveChannelAlert()
            }
        )
        
        if channel.myRole == .operator {
            actionSheet.addAction(
                UIAlertAction(title: "Update Channel Name", style: .default) { [weak self] _ in
                    self?.presentChangeChannelNameAlert()
                }
            )
            
            actionSheet.addAction(
                UIAlertAction(title: "Delete Channel", style: .destructive) { [weak self] _ in
                    self?.presentDeleteChannelAlert()
                }
            )
        }

        actionSheet.addAction(
            UIAlertAction(title: "Pinned Messages", style: .default) { [weak self] _ in
                self?.pushPinnedMessageList()
            }
        )
        
        actionSheet.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(actionSheet, animated: true)
    }

    private func pushMemberList() {
        let memberListViewController = GroupMemberListViewController(channel: channel)
        
        navigationController?.pushViewController(memberListViewController, animated: true)
    }

    private func pushPinnedMessageList() {
        let messageListViewController = GroupChannelPinnedMessagesViewController(channel: channel, timestampStorage: TimestampStorage())

        navigationController?.pushViewController(messageListViewController, animated: true)
    }

    
    private func presentInviteMember() {
        let userSelection = UserSelectionViewController(channel: channel) { [weak self] sender, users in
            self?.settingUseCase.invite(users: users) { result in
                sender.dismiss(animated: true) {
                    switch result {
                    case .success:
                        break
                    case .failure(let error):
                        self?.presentAlert(error: error)
                    }
                }
            }
        }
        
        let navigation = UINavigationController(rootViewController: userSelection)
        
        present(navigation, animated: true)
    }
    
    private func presentChangeChannelNameAlert() {
        presentTextFieldAlert(title: "Change channel name", message: nil, defaultTextFieldMessage: channel.name) { [weak self] editedName in
            self?.settingUseCase.updateChannelName(editedName) { result in
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        }
    }
    
    private func presentLeaveChannelAlert() {
        let alert = UIAlertController(title: "Leave Channel", message: "Are you sure you want to leave this channel?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Leave", style: .destructive) { [weak self] _ in
            self?.settingUseCase.leaveChannel { result in
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func presentDeleteChannelAlert() {
        let alert = UIAlertController(title: "Delete Channel", message: "Are you sure you want to delete this channel?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.settingUseCase.deleteChannel { result in
                switch result {
                case .success:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .failure(let error):
                    self?.presentAlert(error: error)
                }
            }
        })
        
        present(alert, animated: true)
    }

}
