//
//  ReplyToMessageUseCase.swift
//  MessageThreadingGroupChannel
//
//  Created by Yogesh Veeraraj on 09.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class ReplyToMessageUseCase {
    let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func replyToMessage(_ message: BaseMessage, reply: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) {
        let params = UserMessageCreateParams(message: reply)
        params.parentMessageId = message.messageId
        
        channel.sendUserMessage(params: params) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
}
