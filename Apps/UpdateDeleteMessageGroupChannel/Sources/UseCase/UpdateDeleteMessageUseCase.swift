//
//  UpdateDeleteMessageUseCase.swift
//  UpdateDeleteMessageGroupChannel
//
//  Created by Yogesh Veeraraj on 22.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class UpdateDeleteMessageUseCase {
    
    private let channel: GroupChannel
    
    public init(channel: GroupChannel) {
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
    
    func deleteMessage(_ message: BaseMessage, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.deleteMessage(message) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    func canEdit(message: BaseMessage) -> Bool {
        let currentUserId = SendbirdChat.getCurrentUser()?.userId
        return message.sender?.userId == currentUserId
                || channel.myRole == .operator
    }
    
}
