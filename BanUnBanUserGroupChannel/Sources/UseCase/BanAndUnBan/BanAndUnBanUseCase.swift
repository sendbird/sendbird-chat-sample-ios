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
    
    func ban(user: User, completion: @escaping(Result<Void, SBError>) -> Void) {
        channel.banUser(userId: user.userId, seconds: 120, description: nil, completionHandler: { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        })
    }
    
    func unBan(user: User, completion: @escaping(Result<Void, SBError>) -> Void) {
        channel.unbanUser(userId: user.userId, completionHandler: { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        })
    }

    func isBanned(user: User) -> Bool {
        if let member = user as? Member {
            return member.restrictionInfo?.restrictionType == .banned
        } else {
            return true
        }
    }
}
