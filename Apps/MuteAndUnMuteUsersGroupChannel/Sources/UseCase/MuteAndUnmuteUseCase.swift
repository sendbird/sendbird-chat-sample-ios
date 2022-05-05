//
//  MuteAndUnmuteUseCase.swift
//  MuteAndUnMuteUsersGroupChannel
//
//  Created by Yogesh Veeraraj on 07.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class MuteAndUnmuteUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func mute(user: Member, completion: @escaping(Result<Void, SBError>) -> Void) {
        channel.muteUser(userID: user.userID, seconds: 120, description: nil, completionHandler: { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        })
    }
    
    func Unmute(user: Member, completion: @escaping(Result<Void, SBError>) -> Void) {
        channel.unmuteUser(userID: user.userID, completionHandler: { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        })
    }
    
    func isMuted(user: Member) -> Bool {
        return user.isMuted
    }
}
