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

class CategorizeMessageUseCase: GroupChannelUserMessageUseCase {
    override func sendMessage(_ message: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) -> UserMessage? {
        
        let params = UserMessageCreateParams(message: message)
        let random = Int.random(in: 0...3)
        let customTypes = ["School", "Music", "Contacts", "People"]
        params.customType = customTypes[random]
        
        return channel.sendUserMessage(params: params) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let message = message else { return }
            completion(.success(message))
        }
    }
}
