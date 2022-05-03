//
//  HideArchiveChannelUsecase.swift
//  HideOrArchiveGroupChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class HideArchiveChannelUsecase {
    
    func hideChannel(_ channel: GroupChannel, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.hide(hidePreviousMessages: true) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }
    
    func archiveChannel(_ channel: GroupChannel, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.hide(hidePreviousMessages: true, allowAutoUnhide: false) { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }

    func unHideChannel(_ channel: GroupChannel, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.unhide { error in
            guard let error = error else {
                completion(.success(()))
                return
            }
            completion(.failure(error))
        }
    }

}
