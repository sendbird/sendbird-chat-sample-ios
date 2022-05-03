//
//  OpenChannelViewController+Setting.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/03/04.
//

import UIKit
import SendbirdChatSDK
import CommonModule

extension OpenChannelViewController {

    @objc func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: "Choose action for channel", message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(
            UIAlertAction(title: "Participant List", style: .default) { [weak self] _ in
                self?.pushMemberList()
            }
        )

        actionSheet.addAction(
            UIAlertAction(title: "Leave Channel", style: .destructive) { [weak self] _ in
                self?.presentLeaveChannelAlert()
            }
        )
        
        if settingUseCase.isCurrentOperator {
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
            UIAlertAction(title: "Cancel", style: .cancel)
        )

        present(actionSheet, animated: true)
    }

    private func pushMemberList() {
        let memberListViewController = OpenChannelParticipantListViewController(channel: channel)

        navigationController?.pushViewController(memberListViewController, animated: true)
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
        let alert = UIAlertController(title: "Exit Channel", message: "Are you sure you want to leave this channel?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.settingUseCase.exitChannel { result in
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
