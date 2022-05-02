//
//  UserDNDSnoozeUseCase.swift
//  UserDoNotDisturbSnooze
//
//  Created by Yogesh Veeraraj on 02.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import CommonModule

class UserDNDSnoozeUseCase {
    
    func setDND(enable: Bool, completion:  @escaping(Result<Void, SBError>) -> Void) {
        SendbirdChat.setDoNotDisturb(enable: enable, startHour: 12, startMin: 15, endHour: 13, endMin: 30, timezone: "EST") { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
    
    func setSnooze(enable: Bool, completion:  @escaping(Result<Void, SBError>) -> Void) {
        let startTimeStamp = Date().timeIntervalSince1970 * 1000
        guard let endTimeStamp = Date().nextDay()?.timeIntervalSince1970 else {
            return
        }
        SendbirdChat.setSnoozePeriod(enabled: enable, startTimestamp: Int64(startTimeStamp), endTimestamp: Int64(endTimeStamp*1000)) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
}
