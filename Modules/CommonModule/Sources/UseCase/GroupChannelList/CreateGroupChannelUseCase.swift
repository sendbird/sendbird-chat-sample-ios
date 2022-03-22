//
//  CreateGroupChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import SendbirdChat

open class CreateGroupChannelUseCase {
    
    private let users: [User]
    
    public init(users: [User]) {
        self.users = users
    }
    
    open func createGroupChannel(channelName: String?, imageData: Data?, completion: @escaping (Result<GroupChannel, SBError>) -> Void) {
        let params = GroupChannelCreateParams()
        
        params.coverImage = imageData
        params.addUsers(users)
        params.name = channelName
        
        if let operatorUserId = SendbirdChat.getCurrentUser()?.userId {
            params.operatorUserIds = [operatorUserId]
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
