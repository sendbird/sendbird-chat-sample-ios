//
//  AddRemoveOperatorUseCase.swift
//  AddRemoveOperatorsGroupChannel
//
//  Created by Yogesh Veeraraj on 07.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class AddRemoveOperatorUseCase {
    private let channel: GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func addOperators(users: [Member], completion: @escaping(Result<Void, SBError>) -> Void) {
        let userIDs = users.map {
            $0.userID
        }
        channel.addOperators(userIDs: userIDs) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
    
    func removeOperator(users: [Member], completion: @escaping(Result<Void, SBError>) -> Void) {
        let userIDs = users.map {
            $0.userID
        }
        channel.removeOperators(userIDs: userIDs) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
    
    func isOperator(member: Member) -> Bool {
        return member.role == .operator
    }
}
