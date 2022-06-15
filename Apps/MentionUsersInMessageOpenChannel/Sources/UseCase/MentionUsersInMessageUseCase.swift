//
//  MentionUsersInMessageUseCase.swift
//  MentionUsersInMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 02.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class MentionUsersInMessageUseCase {
    private let channel: OpenChannel
    
    public init(channel: OpenChannel) {
        self.channel = channel
    }

    func sendMessage(_ message: String, mentionedUsers: [User], completion: @escaping (Result<UserMessage, SBError>) -> Void) -> UserMessage? {
        let userParams = UserMessageCreateParams(message: message)
        userParams.mentionedUserIds = mentionedUsers.map({
            return $0.userId
        })
        userParams.mentionType = .users
        return channel.sendUserMessage(params: userParams, completionHandler: { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let message = message else { return }
            completion(.success(message))
        })
    }
}
