//
//  CreateGroupChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import UIKit
import SendBirdSDK

open class CreateGroupChannelUseCase {
    
    private let users: [SBDUser]
    
    public init(users: [SBDUser]) {
        self.users = users
    }
    
    open func createGroupChannel(channelName: String?, imageData: Data?, completion: @escaping (Result<SBDGroupChannel, SBDError>) -> Void) {
        let params = SBDGroupChannelParams()
        params.coverImage = imageData
        params.add(users)
        params.name = channelName

        SBDGroupChannel.createChannel(with: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
}
