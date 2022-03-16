//
//  CreateOpenChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import UIKit
import SendbirdChat

open class CreateOpenChannelUseCase {
    
    public init() { }
    
    open func createOpenChannel(channelName: String?, imageData: Data?, completion: @escaping (Result<SBDOpenChannel, SBDError>) -> Void) {
        let params = SBDOpenChannelParams()
        params.operatorUserIds = [SBDMain.getCurrentUser()?.userId].compactMap { $0 }
        params.coverImage = imageData
        params.name = channelName

        SBDOpenChannel.createChannel(with: params) { channel, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let channel = channel else { return }
            
            completion(.success(channel))
        }
    }
    
}
