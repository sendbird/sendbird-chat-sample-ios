//
//  GroupChannelSettingUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChat

open class GroupChannelSettingUseCase {
    
    public var members: [SBDUser] {
        (channel.members as? [SBDUser]) ?? []
    }
    
    private let channel: SBDGroupChannel
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    open func invite(users: [SBDUser], completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.invite(users) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    open func updateChannelName(_ channelName: String, completion: @escaping (Result<SBDGroupChannel, Error>) -> Void) {
        let params = SBDGroupChannelParams()
        params.name = channelName
        channel.update(with: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
    open func leaveChannel(completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.leave { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    open func deleteChannel(completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }

}
