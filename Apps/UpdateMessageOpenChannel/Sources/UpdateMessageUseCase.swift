//
//  UpdateMessageUseCase.swift
//  UpdateMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 22.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class UpdateMessageUseCase {
    
    private let channel: OpenChannel
    
    init(channel: OpenChannel) {
        self.channel = channel
    }
    
    func updateMessage(_ message: UserMessage, to newMessage: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) {
        let params = UserMessageUpdateParams(message: newMessage)
        
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
