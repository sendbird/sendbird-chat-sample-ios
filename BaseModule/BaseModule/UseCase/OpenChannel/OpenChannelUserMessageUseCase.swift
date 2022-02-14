//
//  OpenChannelUserMessageUseCase.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendBirdSDK

public class OpenChannelUserMessageUseCase {
    
    private let channel: SBDOpenChannel
    
    public init(channel: SBDOpenChannel) {
        self.channel = channel
    }
    
    public func sendMessage(_ message: String, completion: @escaping (Result<SBDBaseMessage, SBDError>) -> Void) {
        channel.sendUserMessage(message) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }
    
    public func updateMessage(_ message: SBDUserMessage, to newMessage: String, completion: @escaping (Result<SBDUserMessage, SBDError>) -> Void) {
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
    
    public func deleteMessage(_ message: SBDBaseMessage, completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.delete(message) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
}
