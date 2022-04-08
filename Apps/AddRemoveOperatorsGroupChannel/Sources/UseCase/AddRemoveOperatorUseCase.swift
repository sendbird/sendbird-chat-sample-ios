//
//  AddRemoveOperatorUseCase.swift
//  AddRemoveOperatorsGroupChannel
//
//  Created by Yogesh Veeraraj on 07.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChat

final class AddRemoveOperatorUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func addOperators(users: [User], completion: @escaping(Result<Void, SBError>) -> Void) {
        let userIds = users.map {
            $0.userId
        }
        channel.addOperators(userIds: userIds) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
    
    func removeOperator(users: [User], completion: @escaping(Result<Void, SBError>) -> Void) {
        let userIds = users.map {
            $0.userId
        }
        channel.removeOperators(userIds: userIds) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
    
    func isOperator(user: User) -> Bool {
        return channel
    }
    
}
