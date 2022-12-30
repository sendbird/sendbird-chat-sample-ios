//
// Copyright (c) 2022 Sendbird. All rights reserved.
//

import Foundation
import UIKit
import SendbirdChatSDK


extension GroupChannelViewController: PollCellDelegate {

    func pollOptionVoted(_ pollCell: PollCell, _ poll: SendbirdChatSDK.Poll, _ optionVoted: SendbirdChatSDK.PollOption) {
        let optionsIds = poll.options.map({ $0.pollOptionId })
        var listToUpdate = [Int64]()
        if poll.allowMultipleVotes {
            listToUpdate = poll.votedPollOptionIds
            if let index = listToUpdate.firstIndex(of: optionVoted.pollOptionId) {
                listToUpdate.remove(at: index)
            } else {
                listToUpdate.append(optionVoted.pollOptionId)
            }
        } else {
            if listToUpdate.contains(optionVoted.pollOptionId) {
                listToUpdate = [Int64]()
            } else {
                listToUpdate = [optionVoted.pollOptionId]
            }
        }
        listToUpdate = listToUpdate.filter({ optionsIds.contains($0) })
        pollUseCase.votePollOptions(poll, listToUpdate, { [weak self] error in
            if let error = error {
                self?.presentAlert(error: error)
                return
            }
        })
    }

    func pollOptionLongPressed(_ pollCell: PollCell, _ poll: Poll, _ option: PollOption) {
        let alert = UIAlertController(title: "Choose action for PollOption", message: "", preferredStyle: .actionSheet)
        alert.addAction(
                UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    self?.deletePollOption(poll, option)
                }
        )

        alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel)
        )
        present(alert, animated: true)
    }

    private func deletePollOption(_ poll: Poll, _ pollOption: PollOption) {
        channel.deletePollOption(pollId: poll.pollId, pollOptionId: pollOption.pollOptionId) { [weak self] error in
            guard let error = error else {
                return
            }
            self?.presentAlert(error: error)
        }
    }

    func addOptionToPoll(_ pollCell: PollCell, _ poll: SendbirdChatSDK.Poll) {
        presentTextFieldAlert(title: "Add Option", message: "Enter option Name", defaultTextFieldMessage: "") { [weak self] optionToAdd in
            self?.pollUseCase.addPollOption(poll, optionToAdd, onOptionAdded: { [weak self] error in
                self?.presentAlert(error: error)
            })
        }
    }

    func closePoll(_ pollCell: PollCell, _ poll: SendbirdChatSDK.Poll) {
        pollUseCase.closePoll(poll: poll, onPollClosed: { [weak self] error in
            if let error = error {
                self?.presentAlert(error: error)
                return
            }
        })
    }
}
