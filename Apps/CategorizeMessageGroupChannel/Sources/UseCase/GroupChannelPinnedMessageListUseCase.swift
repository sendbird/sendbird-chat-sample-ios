//
//  GroupChannelPinnedMessageListUseCase.swift
//  CategorizeMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 17.08.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import CommonModule
import SendbirdChatSDK

class GroupChannelPinnedMessageListUseCase: GroupChannelMessageListUseCase {
    override func createMessageCollection() -> MessageCollection? {
        let params = MessageListParams()
        params.previousResultSize = 20
        params.nextResultSize = 20
        params.replyType = .all
        params.customType = "Pinned"
        params.includeThreadInfo = true
        params.includeParentMessageInfo = true

        let collection = SendbirdChat.createMessageCollection(
            channel: channel,
            startingPoint: 0,
            params: params
        )

        collection.delegate = self

        return collection
    }
}
