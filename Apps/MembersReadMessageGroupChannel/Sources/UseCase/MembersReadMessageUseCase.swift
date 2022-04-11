//
//  MembersReadMessageUseCase.swift
//  MembersReadMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class MembersReadMessageUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func getReadMembers(for message: BaseMessage) -> [Member] {
       return channel.getReadMembers(message: message, includeAllMembers: false)
    }
}
