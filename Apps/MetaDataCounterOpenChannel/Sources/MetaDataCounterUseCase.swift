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
        if isMetaDataExists(for: "votes_background", message: message) {
            let value = valueForKey("votes_background", message: message)
            let incrementalCount = (Int(value) ?? 0) + 1
            let valuesToAdd = [
                "votes_background": [String(incrementalCount)]
            ]
            channel.addMessageMetaArrayValues(message: message, keyValues: valuesToAdd) { _, _ in
                // Update message
            }
        } else {
            channel.createMessageMetaArrayKeys(message: message, keys: ["votes_background"]) { [weak self] _, error in
                guard error == nil else { return }
                let valuesToAdd = [
                    "votes_background": ["1"],
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
    
    private func valueForKey(_ key: String, message: BaseMessage) -> String {
        return message.metaArrays?.first(where: { metaArray in
            metaArray.key == key
        })?.value.first ?? "0"
    }
}
