//
//  ReactToMessageUseCase.swift
//  ReactToMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import MapKit

class ReactToMessageUseCase {
    
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func reactToMessage(_ message: BaseMessage, reaction: String) {
        channel.addReaction(with: message, key: reaction) { event, error in
            // Update and listen to event
        }
    }
}
