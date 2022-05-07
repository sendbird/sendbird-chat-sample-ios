//
//  CreateWithCategoryGroupChannelUseCase.swift
//  CategorizeWithCustomTypeGroupChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class CreateWithCategoryGroupChannelUseCase {
    
    private let users: [User]
    
    init(users: [User]) {
        self.users = users
    }
    
    func createGroupChannel(channelName: String?, imageData: Data?, completion: @escaping (Result<GroupChannel, SBError>) -> Void) {
        let params = GroupChannelCreateParams()
        let random = Int.random(in: 0...3)
        let customTypes = ["School", "Music", "Contacts", "People"]
        params.customType = customTypes[random]
        
        params.coverImage = imageData
        params.addUsers(users)
        params.name = channelName
        
        if let operatorUserId = SendbirdChat.getCurrentUser()?.userID {
            params.operatorUserIDs = [operatorUserId]
        }
        
        GroupChannel.createChannel(params: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
}
