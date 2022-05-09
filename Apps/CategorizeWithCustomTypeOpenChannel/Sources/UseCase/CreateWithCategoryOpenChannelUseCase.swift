//
//  CreateWithCategoryOpenChannelUseCase.swift
//  CategorizeWithCustomTypeOpenChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class CreateWithCategoryOpenChannelUseCase {
    
    func createOpenChannel(channelName: String?, imageData: Data?, completion: @escaping (Result<OpenChannel, SBError>) -> Void) {
        let params = OpenChannelCreateParams()
        params.operatorUserIDs = [SendbirdChat.getCurrentUser()?.userID].compactMap { $0 }
        let random = Int.random(in: 0...3)
        let customTypes = ["School", "Music", "Contacts", "People"]
        params.customType = customTypes[random]
        params.coverImage = imageData
        params.name = channelName
        
        OpenChannel.createChannel(params: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
}
