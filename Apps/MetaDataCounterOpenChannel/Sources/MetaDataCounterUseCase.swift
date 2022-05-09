//
//  AddExtraDataToMessageUseCase.swift
//  AddExtraDataMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class MetaDataCounterUseCase {
    private let channel: OpenChannel
    
    init(channel: OpenChannel) {
        self.channel = channel
    }
    
    func addExtraDataToMessage(_ message: BaseMessage) {
        if isMetaDataExists(for: "copied_users", message: message) {
            let currentUserId = SendbirdChat.getCurrentUser()?.userID ?? "UnKnown"
            let valuesToAdd = [
                "copied_users": [currentUserId]
            ]
            channel.addMessageMetaArrayValues(message: message, keyValues: valuesToAdd) { _, _ in
                // Update message
            }
        } else {
            channel.createMessageMetaArrayKeys(message: message, keys: ["copied_users"]) { [weak self] _, error in
                guard error == nil else { return }
                let currentUserId = SendbirdChat.getCurrentUser()?.userID ?? "UnKnown"
                let valuesToAdd = [
                    "copied_users": [currentUserId],
                ]
                self?.channel.addMessageMetaArrayValues(message: message, keyValues: valuesToAdd) { _, _ in
                    // Update message
                }
            }
        }
    }
    
    private func isMetaDataExists(
        for key: String,
        message: BaseMessage
    ) -> Bool {
        guard let metaArrays = message.metaArrays else {
            return false
        }
       return metaArrays.contains(where: { metaArray in
            metaArray.key == key
        })
    }
}
