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
    
    private enum Constant {
        static let previousResultSize: Int = 30
        static let nextResultSize: Int = 30
    }
    
    public weak var delegate: OpenChannelMessageListUseCaseDelegate?
    
    public private(set) var messages: [SBDBaseMessage] = []

    private let channel: SBDOpenChannel

    private let isReversed: Bool
    
    private var hasPreviousMessages: Bool = true
    
    private var hasNextMessages: Bool = false
    
    private var isLoading: Bool = false
        
    public init(channel: SBDOpenChannel, isReversed: Bool) {
        self.channel = channel
        self.isReversed = isReversed
        super.init()
        SBDMain.add(self as SBDConnectionDelegate, identifier: description)
    }
    
    deinit {
        SBDMain.removeConnectionDelegate(forIdentifier: description)
    }
    
    public func addEventObserver() {
        SBDMain.add(self as SBDChannelDelegate, identifier: description)
    }
    
    public func removeEventObserver() {
        SBDMain.removeChannelDelegate(forIdentifier: description)
    }
        
    open func loadInitialMessages() {
        let params = SBDMessageListParams()
        params.isInclusive = true
        params.reverse = isReversed
        params.previousResultSize = Constant.previousResultSize
        params.nextResultSize = Constant.nextResultSize

        isLoading = true
        
        channel.getMessagesByTimestamp(.max, params: params) { [weak self] messages, error in
            defer { self?.isLoading = false }
            
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.hasPreviousMessages = messages.isEmpty == false
            self.messages = messages
            self.delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
    open func loadPreviousMessages() {
        guard hasPreviousMessages, isLoading == false, let timestamp = isReversed ? messages.last?.createdAt : messages.first?.createdAt else { return }
        
        let params = SBDMessageListParams()
        params.isInclusive = false
        params.reverse = isReversed
        params.previousResultSize = Constant.previousResultSize
        params.nextResultSize = 0

        isLoading = true

        channel.getMessagesByTimestamp(timestamp, params: params) { [weak self] messages, error in
            defer { self?.isLoading = false }
            
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.hasPreviousMessages = messages.count >= Constant.previousResultSize
            
            if self.isReversed {
                self.messages.append(contentsOf: messages)
            } else {
                self.messages.insert(contentsOf: messages, at: 0)
            }
            self.delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
    open func loadNextMessages() {
        guard hasNextMessages,
              isLoading == false,
              let timestamp = isReversed ? messages.first?.createdAt : messages.last?.createdAt else { return }
        
        let params = SBDMessageListParams()
        params.isInclusive = false
        params.reverse = isReversed
        params.previousResultSize = 0
        params.nextResultSize = Constant.nextResultSize

        isLoading = true
        
        channel.getMessagesByTimestamp(timestamp, params: params) { [weak self] messages, error in
            defer { self?.isLoading = false }
            
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.hasNextMessages = messages.count >= Constant.nextResultSize
            
            if self.isReversed {
                self.messages.insert(contentsOf: messages, at: 0)
            } else {
                self.messages.append(contentsOf: messages)
            }
            
            self.delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
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
        guard sender.channelUrl == channel.channelUrl, hasNextMessages == false else { return }
        
        appendNewMessage(message)
    }
    
    public func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard sender.channelUrl == channel.channelUrl else { return }

        self.messages = self.messages.map { oldMessage in
            oldMessage.messageId == message.messageId ? message : oldMessage
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

// MARK: - SBDConnectionDelegate

extension OpenChannelMessageListUseCase: SBDConnectionDelegate {
    
    public func didSucceedReconnection() {
        hasNextMessages = true
        
        guard let timestamp = isReversed ? messages.first?.createdAt : messages.last?.createdAt else {
            return
        }
        
        let params = SBDMessageChangeLogsParams()
        
        channel.getMessageChangeLogs(sinceTimestamp: timestamp, params: params) { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
            guard let self = self, error == nil else { return }
            
            self.messages = self.messages.map { oldMessage in
                (updatedMessages ?? []).first { $0.messageId == oldMessage.messageId } ?? oldMessage
            }
            
            self.messages = self.messages.filter {
                (deletedMessageIds ?? []).map(\.int64Value).contains($0.messageId) == false
            }
        }
    }
    
}
