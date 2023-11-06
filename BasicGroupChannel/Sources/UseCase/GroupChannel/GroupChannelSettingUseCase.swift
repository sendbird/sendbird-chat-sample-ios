//
//  GroupChannelSettingUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChatSDK

open class GroupChannelSettingUseCase {
        
    private let channel: GroupChannel
    
    public init(channel: GroupChannel) {
        self.channel = channel
    }
    
    open func invite(users: [User], completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.inviteUsers(users) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    open func updateChannelName(_ channelName: String, completion: @escaping (Result<GroupChannel, Error>) -> Void) {
        let params = GroupChannelUpdateParams()
        params.name = channelName
        channel.update(params: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
    open func leaveChannel(completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.leave { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    open func deleteChannel(completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }

}
