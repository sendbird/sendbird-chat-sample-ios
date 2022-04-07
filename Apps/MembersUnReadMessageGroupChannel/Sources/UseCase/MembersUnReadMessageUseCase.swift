//
//  MembersUnReadMessageUseCase.swift
//  MembersUnReadMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class MembersUnReadMessageUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func getUnReadMembers(for message: BaseMessage) -> [Member] {
       return channel.getUnreadMembers(message: message, includeAllMembers: false)
    }
}
