//
//  OpenChannelSettingUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import Foundation
import SendBirdSDK

open class OpenChannelSettingUseCase {
    
    public var operators: [SBDUser] {
        (channel.operators as? [SBDUser]) ?? []
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

}
