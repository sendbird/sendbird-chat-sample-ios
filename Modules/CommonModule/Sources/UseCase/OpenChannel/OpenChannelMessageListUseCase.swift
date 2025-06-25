//
//  OpenChannelMessageListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChatSDK

public protocol OpenChannelMessageListUseCaseDelegate: AnyObject {
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didReceiveError error: SBError)
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateMessages messages: [BaseMessage])
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateChannel channel: OpenChannel)
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didDeleteChannel channel: OpenChannel)
}

open class OpenChannelMessageListUseCase: NSObject {
    
    private enum Constant {
        static let previousResultSize: Int = 20
        static let nextResultSize: Int = 20
    }
    
    public weak var delegate: OpenChannelMessageListUseCaseDelegate?
    
    public private(set) var messages: [BaseMessage] = [] {
        didSet {
            delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }

    private var channel: OpenChannel

    private var hasPreviousMessages: Bool = true
    
    private var hasNextMessages: Bool = false
    
    private var isLoading: Bool = false
        
    public init(channel: OpenChannel) {
        self.channel = channel
        super.init()
        SendbirdChat.addConnectionDelegate(self, identifier: description)
    }
    
    deinit {
        SendbirdChat.removeConnectionDelegate(forIdentifier: description)
    }
    
    open func addEventObserver() {
        SendbirdChat.addChannelDelegate(self, identifier: description)
    }
    
    open func removeEventObserver() {
        SendbirdChat.removeChannelDelegate(forIdentifier: description)
    }
    
    open func createMessageListParams() -> MessageListParams {
        let params = MessageListParams()
        params.isInclusive = true
        params.previousResultSize = Constant.previousResultSize
        params.nextResultSize = Constant.nextResultSize
        params.includeParentMessageInfo = true
        params.replyType = .all
        params.includeThreadInfo = true
        params.includeMetaArray = true
        return params
    }
        
    open func loadInitialMessages() {
        let params = createMessageListParams()
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
        }
    }
    
    open func loadPreviousMessages() {
        guard hasPreviousMessages, isLoading == false, let timestamp = messages.first?.createdAt else { return }
        
        let params = MessageListParams()
        params.isInclusive = false
        params.previousResultSize = Constant.previousResultSize
        params.nextResultSize = 0
        params.includeParentMessageInfo = true
        params.replyType = .all
        params.includeThreadInfo = true
        params.includeMetaArray = true
      
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
            self.messages.insert(contentsOf: messages, at: 0)
        }
    }
    
    open func loadNextMessages() {
        guard hasNextMessages,
              isLoading == false,
              let timestamp = messages.last?.createdAt else { return }
        
        let params = MessageListParams()
        params.isInclusive = false
        params.includeReactions = true
        params.previousResultSize = 0
        params.nextResultSize = Constant.nextResultSize
        params.includeParentMessageInfo = true
        params.replyType = .all
        params.includeThreadInfo = true
        params.includeMetaArray = true
      
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
            self.messages.append(contentsOf: messages)
        }
    }
    
    open func didStartSendMessage(_ message: BaseMessage?) {
        guard let message = message else { return }
        appendNewMessage(message)
    }
    
    open func didSuccessSendMessage(_ message: BaseMessage) {
        replaceMessages([message])
    }
    
    open func didFailSendMessage(_ message: BaseMessage?) {
        guard let message = message else { return }
        replaceMessages([message])
    }

}

// MARK: - BaseChannelDelegate

extension OpenChannelMessageListUseCase: BaseChannelDelegate, OpenChannelDelegate {
    
    open func channelWasChanged(_ sender: BaseChannel) {
        guard sender.channelURL == channel.channelURL,
              let channel = sender as? OpenChannel else { return }
        
        self.channel = channel
        
        delegate?.openChannelMessageListUseCase(self, didUpdateChannel: channel)
    }
    
    public func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        guard channelURL == channel.channelURL else { return }
        
        delegate?.openChannelMessageListUseCase(self, didDeleteChannel: channel)
    }
    
    open func channel(_ sender: BaseChannel, didReceive message: BaseMessage) {
        guard sender.channelURL == channel.channelURL, hasNextMessages == false else { return }
        
        appendNewMessage(message)
    }
    
    open func channel(_ sender: BaseChannel, didUpdate message: BaseMessage) {
        guard sender.channelURL == channel.channelURL else { return }

        replaceMessages([message])
    }
    
    open func channel(_ sender: BaseChannel, messageWasDeleted messageId: Int64) {
        guard sender.channelURL == channel.channelURL else { return }
        
        deleteMessages(byMessageIds: [messageId])
    }
    
    private func appendNewMessage(_ message: BaseMessage) {
        guard messages.contains(where: { $0.messageId == message.messageId }) == false else { return }
        
        self.messages.append(message)
    }
    
    private func replaceMessages(_ newMessages: [BaseMessage]) {
        newMessages.forEach { newMessage in
            if let index = messages.firstIndex(where: {
                $0.messageId == newMessage.messageId
                || $0.requestId == newMessage.requestId
            }) {
                messages[index] = newMessage
            }
        }
    }
    
    private func deleteMessages(byMessageIds messageIds: [Int64]) {
        self.messages = self.messages.filter {
            messageIds.contains($0.messageId) == false
        }
    }
        
    private func deleteMessage(_ message: BaseMessage) {
        self.messages = self.messages.filter {
            $0.requestId != message.requestId
            && $0.messageId != message.messageId
        }
    }
    
}

// MARK: - ConnectionDelegate

extension OpenChannelMessageListUseCase: ConnectionDelegate {
    open func didSucceedReconnection() {
        hasNextMessages = true
        fetchMessagesOnReconnect(sinceTimestamp: .max)
    }
    
    private func fetchMessagesOnReconnect(sinceTimestamp timestamp: Int64) {
        let params = MessageListParams()
        params.isInclusive = true
        params.previousResultSize = Constant.previousResultSize
        
        channel.getMessagesByTimestamp(timestamp, params: params) { [weak self] messages, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.hasPreviousMessages = messages.count >= Constant.previousResultSize
            self.messages = messages
            self.delegate?.openChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
}

