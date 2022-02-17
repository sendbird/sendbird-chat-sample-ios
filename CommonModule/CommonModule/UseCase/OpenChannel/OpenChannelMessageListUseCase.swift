//
//  OpenChannelMessageListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendBirdSDK

public protocol OpenChannelMessageListUseCaseDelegate: AnyObject {
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didReceiveError error: SBDError)
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateMessages messages: [SBDBaseMessage])
}

open class OpenChannelMessageListUseCase: NSObject {
    
    public weak var delegate: OpenChannelMessageListUseCaseDelegate?
    
    public private(set) var messages: [SBDBaseMessage] = []

    private let channel: SBDOpenChannel

    private let isReversed: Bool
    
    private var hasPreviousMessage: Bool = true
    
    private var messageListQuery: SBDPreviousMessageListQuery?
    
    public init(channel: SBDOpenChannel, isReversed: Bool) {
        self.channel = channel
        self.isReversed = isReversed
        super.init()
    }
    
    public func addEventObserver() {
        SBDMain.add(self as SBDChannelDelegate, identifier: description)
    }
    
    public func removeEventObserver() {
        SBDMain.removeChannelDelegate(forIdentifier: description)
    }
        
    open func loadInitialMessages() {
        guard let messageListQuery = createMessageQuery() else { return }
        self.messageListQuery = messageListQuery
        
        messageListQuery.loadPreviousMessages(withLimit: 30, reverse: isReversed) { [weak self] messages, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.hasPreviousMessage = messages.isEmpty == false
            self.messages = messages
            self.delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
    open func loadPreviousMessages() {
        guard hasPreviousMessage, let messageListQuery = messageListQuery, messageListQuery.isLoading() == false else { return }
        
        messageListQuery.loadPreviousMessages(withLimit: 30, reverse: isReversed) { [weak self] messages, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.hasPreviousMessage = messages.isEmpty == false
            if self.isReversed {
                self.messages.append(contentsOf: messages)
            } else {
                self.messages.insert(contentsOf: messages, at: 0)
            }
            self.delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
    open func createMessageQuery() -> SBDPreviousMessageListQuery? {
        // There should be only one single instance per channel.
        let listQuery = channel.createPreviousMessageListQuery()
        
        return listQuery
    }
    
    open func didSendMessage(_ message: SBDBaseMessage) {
        appendNewMessage(message)
    }
    
    private func appendNewMessage(_ message: SBDBaseMessage) {
        guard messages.contains(where: { $0.messageId == message.messageId }) == false else { return }
        
        if self.isReversed {
            self.messages.insert(message, at: 0)
        } else {
            self.messages.append(message)
        }
        
        delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
    }
    
}

// MARK: - SBDChannelDelegate

extension OpenChannelMessageListUseCase: SBDChannelDelegate {
    
    public func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard sender.channelUrl == channel.channelUrl else { return }
        
        appendNewMessage(message)
    }
    
    public func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard sender.channelUrl == channel.channelUrl else { return }

        self.messages = self.messages.map { oldMessage in
            messages.first { $0.messageId == oldMessage.messageId } ?? oldMessage
        }
        
        delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
    }
    
    public func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard sender.channelUrl == channel.channelUrl else { return }
        
        self.messages = self.messages.filter { oldMessage in
            oldMessage.messageId != messageId
        }
        
        delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
    }
    
}
