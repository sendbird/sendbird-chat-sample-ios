//
//  AddExtraDataToMessageUseCase.swift
//  AddExtraDataMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class AddExtraDataToMessageUseCase {
    private let channel: OpenChannel
    
    init(channel: OpenChannel) {
        self.channel = channel
    }
    
    func addExtraDataToMessage(_ message: BaseMessage) {
        channel.createMessageMetaArrayKeys(message: message, keys: ["referees", "games"]) { [weak self] _, error in
            guard error == nil else { return }
            let valuesToAdd = [
                "referees": ["John"],
                "games": ["soccer"]
            ]
            self?.channel.addMessageMetaArrayValues(message: message, keyValues: valuesToAdd) { _, _ in
                // Update message
            }
        }
    }
}
