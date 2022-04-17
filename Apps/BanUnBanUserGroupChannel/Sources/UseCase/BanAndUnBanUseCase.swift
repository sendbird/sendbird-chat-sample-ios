//
//  MuteAndUnmuteUseCase.swift
//  MuteAndUnMuteUsersGroupChannel
//
//  Created by Yogesh Veeraraj on 07.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class BanAndUnBanUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func mute(user: Member, completion: @escaping(Result<Void, SBError>) -> Void) {
        channel.banUser(userId: user.userId, seconds: 120, description: nil, completionHandler: { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        })
    }
    
    func Unmute(user: Member, completion: @escaping(Result<Void, SBError>) -> Void) {
        channel.unbanUser(userId: user.userId, completionHandler: { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        })
    }
    
    func isBanned(user: Member) -> Bool {
        return user.restrictionInfo?.restrictionType == .banned
    }
}
