//
//  OpenChannelSettingUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import Foundation
import SendbirdChat

open class OpenChannelSettingUseCase {
    
    // FIX ME: Query로 불러오는 Use Case 따로 분리하기
    public var operators: [User] {
        (channel.operators as? [User]) ?? []
    }
    
    public var isCurrentOperator: Bool {
        guard let currentUser = SBDMain.getCurrentUser() else {
            return false
        }
        
        return channel.isOperator(with: currentUser)
    }
    
    private let channel: SBDOpenChannel
    
    public init(channel: SBDOpenChannel) {
        self.channel = channel
    }
    
    open func updateChannelName(_ channelName: String, completion: @escaping (Result<SBDOpenChannel, Error>) -> Void) {
        let params = SBDOpenChannelParams()
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
    
    open func exitChannel(completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.exitChannel { error in
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
