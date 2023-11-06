//
//  OpenChannelSettingUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import Foundation
import SendbirdChatSDK

open class OpenChannelSettingUseCase {
    
    public var isCurrentOperator: Bool {
        guard let currentUser = SendbirdChat.getCurrentUser() else {
            return false
        }
        
        return channel.isOperator(user: currentUser)
    }
    
    private let channel: OpenChannel
    
    public init(channel: OpenChannel) {
        self.channel = channel
    }
    
    open func updateChannelName(_ channelName: String, completion: @escaping (Result<OpenChannel, Error>) -> Void) {
        let params = OpenChannelUpdateParams()
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
    
    open func exitChannel(completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.exit { error in
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
