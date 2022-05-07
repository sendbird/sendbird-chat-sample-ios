//
//  CreateGroupChannelWithTypeUseCase.swift
//  ChannelTypesGroupChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class CreateGroupChannelWithTypeUseCase {
    
    private let users: [User]
    
    init(users: [User]) {
        self.users = users
    }
    
    func createGroupChannel(channelName: String?, channelType: ChannelType, imageData: Data?, completion: @escaping (Result<GroupChannel, SBError>) -> Void) {
        let params = GroupChannelCreateParams()
        
        params.coverImage = imageData
        params.addUsers(users)
        params.name = channelName
        
        switch channelType {
        case .publicGroup:
            params.isPublic = true
        case .privateGroup:
            params.isPublic = false
        case .superGroup:
            params.isSuper = true
        }
        
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
