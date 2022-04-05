//
//  UndeliveredMessageMembersCountUseCase.swift
//  MessageUndeliveredCountGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import SendbirdChat
import UIKit

final class MessageUndeliveredMembersCountUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    private func getMessageUndeliveredMembersCount(for message: BaseMessage) -> Int {
        return channel.getUndeliveredMemberCount(message)
    }
    
    func getUndeliveredMessageStatus(for message: BaseMessage) -> String {
        let count = getMessageUndeliveredMembersCount(for: message)
        return count > 0 ? "✓" : "✓✓"
    }
}
