//
//  DeleteMessageUseCase.swift
//  DeleteMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 22.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class DeleteMessageUseCase {
    
    private let channel: OpenChannel
    
    init(channel: OpenChannel) {
        self.channel = channel
        subscribeToDeleteMessageDelegate()
    }
    
    private func subscribeToDeleteMessageDelegate() {
        SendbirdChat.add(self, identifier: "[DELETE_MESSAGE_DELEGATE]")
    }

    func deleteMessage(_ message: BaseMessage, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.deleteMessage(message) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
}

extension DeleteMessageUseCase: OpenChannelDelegate {
    func channel(_ channel: BaseChannel, messageWasDeleted messageID: Int64) {
        // Refresh or show indicator that message been deleted
    }
}
