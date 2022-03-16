//
//  GroupChannelInputUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChat

open class GroupChannelUserMessageUseCase {
    
    private let channel: SBDGroupChannel
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    open func sendMessage(_ message: String, completion: @escaping (Result<SBDUserMessage, SBDError>) -> Void) -> SBDUserMessage? {
        return channel.sendUserMessage(message) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    open func resendMessage(_ message: SBDUserMessage, completion: @escaping (Result<BaseMessage, SBDError>) -> Void) {
        channel.resendUserMessage(with: message) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    open func updateMessage(_ message: SBDUserMessage, to newMessage: String, completion: @escaping (Result<SBDUserMessage, SBDError>) -> Void) {
        guard let params = SBDUserMessageParams(message: newMessage) else { return }

        channel.updateUserMessage(withMessageId: message.messageId, userMessageParams: params) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    open func deleteMessage(_ message: BaseMessage, completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.delete(message) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
}
