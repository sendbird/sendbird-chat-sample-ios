//
//  SendGroupChannelUseCase.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendBirdSDK

public protocol SendGroupChannelUseCaseDelegate: AnyObject {
    func sendGroupChannelUseCase(_ sendGroupChannelUseCase: SendGroupChannelUseCase, didReceiveError error: SBDError)
}

public class SendGroupChannelUseCase {
    
    public weak var delegate: SendGroupChannelUseCaseDelegate?
    
    private let channel: SBDGroupChannel
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    public func sendMessage(_ message: String) {
        channel.sendUserMessage(message) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.sendGroupChannelUseCase(self, didReceiveError: error)
                return
            }
        }
    }
    
}
