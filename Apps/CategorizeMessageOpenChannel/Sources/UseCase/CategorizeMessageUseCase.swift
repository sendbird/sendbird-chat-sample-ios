//
//  CategorizeMessageUseCase.swift
//  CategorizeMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import CommonModule
import SendbirdChatSDK

class CategorizeMessageUseCase: OpenChannelUserMessageUseCase {
    open func pinMessage(_ message: BaseMessage, isEnablePin: Bool, completion: @escaping (Result<UserMessage, SBError>) -> Void) {
        let params = UserMessageUpdateParams()
        params.customType = isEnablePin ? "Pinned" : ""
        channel.updateUserMessage(messageId: message.messageId, params: params) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let message = message else { return }

            completion(.success(message))
        }
    }
}
