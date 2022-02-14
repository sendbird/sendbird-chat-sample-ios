//
//  GroupChannelInviteMemberUseCase.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendBirdSDK

public class GroupChannelInviteMemberUseCase {
    
    public var members: [SBDUser] {
        (channel.members as? [SBDUser]) ?? []
    }
    
    private let channel: SBDGroupChannel
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    public func invite(users: [SBDUser], completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.invite(users) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
}
