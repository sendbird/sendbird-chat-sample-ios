//
//  OpenChannelPinnedMessageListUseCase.swift
//  CategorizeMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 17.08.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import CommonModule
import SendbirdChatSDK

class OpenChannelPinnedMessageListUseCase: OpenChannelMessageListUseCase {
    override func createMessageListParams() -> MessageListParams {
        let params = MessageListParams()
        params.isInclusive = true
        params.previousResultSize = 100
        params.nextResultSize = 100
        params.includeParentMessageInfo = true
        params.replyType = .all
        params.customType = "Pinned"
        params.includeThreadInfo = true
        params.includeMetaArray = true
        return params
    }
}
