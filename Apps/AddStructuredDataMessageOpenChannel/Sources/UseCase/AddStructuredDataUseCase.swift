//
//  AddStructuredDataUseCase.swift
//  CategorizeMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import CommonModule
import SendbirdChatSDK
import UIKit

class AddStructuredDataUseCase: OpenChannelUserMessageUseCase {
    override func sendMessage(_ message: String, completion: @escaping (Result<UserMessage, SBError>) -> Void) -> UserMessage? {
        
        let dictionary: [String: String] = ["color": "#6a0dad", "fontSize": "14", "description": "Json data added with customized UI for message"]
        let encoder = JSONEncoder()
        guard let jsonData = try? encoder.encode(dictionary),
             let jsonString = String(data: jsonData, encoding: .utf8) else {
                 return nil
            }
        let params = UserMessageCreateParams(message: message)
        params.data = jsonString
        
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
