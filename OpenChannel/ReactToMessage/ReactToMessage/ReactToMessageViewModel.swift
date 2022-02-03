//
//  ReactToMessageViewModel.swift
//  ReactToMessage
//
//  Created by Ernest Hong on 2022/02/03.
//

import UIKit
import Common
import SendBirdSDK

final class ReactToMessageViewModel: BaseGroupChannelViewModel {
    
    override func createMessageListParams() -> SBDMessageListParams {
        let messageListParams = super.createMessageListParams()
        messageListParams.includeReactions = true
        return messageListParams
    }
    
    required init(channel: SBDGroupChannel) {
        super.init(channel: channel)
        SBDMain.add(self as SBDChannelDelegate, identifier: description)
    }
    
    deinit {
        SBDMain.removeChannelDelegate(forIdentifier: description)
    }
    
    override func cellText(for message: SBDBaseMessage) -> String? {
        let cellText = super.cellText(for: message)
        let reactions = message.reactions.map { $0.key }.joined(separator: ",")
        return cellText?.appending("\nreactions: \(reactions)")
    }
    
    func addReaction(to message: SBDBaseMessage) {
        let emojiKey = "smile"
        
        channel.addReaction(with: message, key: emojiKey) { [weak self] event, error in
            if let error = error {
                self?.notify(error)
                return
            }
            
            guard let event = event else { return }
            
            print("[Add Reaction] event: \(event)")
        }
    }
    
    func deleteReaction(in message: SBDBaseMessage) {
        let emojiKey = "smile"
        
        channel.deleteReaction(with: message, key: emojiKey) { [weak self] event, error in
            if let error = error {
                self?.notify(error)
                return
            }
            
            guard let event = event else { return }
            
            print("[Delete Reaction] event: \(event)")
        }
    }
    
}

// MARK: - SBDChannelDelegate

extension ReactToMessageViewModel: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, updatedReaction reactionEvent: SBDReactionEvent) {
        let updatedMessage = message(byMessageId: reactionEvent.messageId)
        updatedMessage?.apply(reactionEvent)
        delegate?.groupChannelViewModelDidUpdateMessages(self)
    }
    
}
