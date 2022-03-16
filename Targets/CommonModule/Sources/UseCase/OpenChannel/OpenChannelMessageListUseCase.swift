//
//  OpenChannelMessageListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChat

public protocol OpenChannelMessageListUseCaseDelegate: AnyObject {
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didReceiveError error: SBError)
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateMessages messages: [BaseMessage])
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didUpdateChannel channel: OpenChannel)
    func openChannelMessageListUseCase(_ useCase: OpenChannelMessageListUseCase, didDeleteChannel channel: OpenChannel)
}

open class OpenChannelMessageListUseCase: NSObject {
    
    private enum Constant {
        static let previousResultSize: Int = 30
        static let nextResultSize: Int = 30
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
        SBDMain.add(self as SBDConnectionDelegate, identifier: description)
    }
    
    deinit {
        SBDMain.removeConnectionDelegate(forIdentifier: description)
    }
    
    open func addEventObserver() {
        SBDMain.add(self as SBDChannelDelegate, identifier: description)
    }
    
    open func removeEventObserver() {
        SBDMain.removeChannelDelegate(forIdentifier: description)
    }
        
    open func loadInitialMessages() {
        let params = SBDMessageListParams()
        params.isInclusive = true
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
        }
    }
    
    open func loadPreviousMessages() {
        guard hasPreviousMessages, isLoading == false, let timestamp = messages.first?.createdAt else { return }
        
        let params = SBDMessageListParams()
        params.isInclusive = false
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
            self.messages.insert(contentsOf: messages, at: 0)
        }
    }
    
    open func loadNextMessages() {
        guard hasNextMessages,
              isLoading == false,
              let timestamp = messages.last?.createdAt else { return }
        
        let params = SBDMessageListParams()
        params.isInclusive = false
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

// MARK: - SBDChannelDelegate

extension OpenChannelMessageListUseCase: SBDChannelDelegate {
    
    open func channelWasChanged(_ sender: SBDBaseChannel) {
        guard sender.channelUrl == channel.channelUrl,
              let channel = sender as? OpenChannel else { return }
        
        self.channel = channel
        
        delegate?.openChannelMessageListUseCase(self, didUpdateChannel: channel)
    }
    
    open func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        guard channelUrl == channel.channelUrl else { return }
        
        delegate?.openChannelMessageListUseCase(self, didDeleteChannel: channel)
    }
    
    open func channel(_ sender: SBDBaseChannel, didReceive message: BaseMessage) {
        guard sender.channelUrl == channel.channelUrl, hasNextMessages == false else { return }
        
        appendNewMessage(message)
    }
    
    open func channel(_ sender: SBDBaseChannel, didUpdate message: BaseMessage) {
        guard sender.channelUrl == channel.channelUrl else { return }

        replaceMessages([message])
    }
    
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard sender.channelUrl == channel.channelUrl else { return }
        
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

// MARK: - SBDConnectionDelegate

extension OpenChannelMessageListUseCase: SBDConnectionDelegate {
    
    open func didSucceedReconnection() {
        hasNextMessages = true
        
        guard let timestamp = messages.last?.createdAt else {
            return
        }
        
        fetchChangeLogs(sinceTimestamp: timestamp)
    }
    
    private func fetchChangeLogs(sinceTimestamp timestamp: Int64) {
        let params = SBDMessageChangeLogsParams()
        
        channel.getMessageChangeLogs(sinceTimestamp: timestamp, params: params) { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
            guard error == nil else { return }
            
            self?.handleChangeLogs(updatedMessages: updatedMessages, deletedMessageIds: deletedMessageIds, hasMore: hasMore, token: token)
        }
    }
    
    private func fetchChangeLogs(sinceToken token: String) {
        let params = SBDMessageChangeLogsParams()
        
        channel.getMessageChangeLogs(sinceToken: token, params: params) { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
            guard error == nil else { return }
            
            self?.handleChangeLogs(updatedMessages: updatedMessages, deletedMessageIds: deletedMessageIds, hasMore: hasMore, token: token)
        }
    }
    
    private func handleChangeLogs(updatedMessages: [BaseMessage]?, deletedMessageIds: [NSNumber]?, hasMore: Bool, token: String?) {
        if let updatedMessages = updatedMessages {
            replaceMessages(updatedMessages)
        }
        
        if let deletedMessageIds = deletedMessageIds?.map(\.int64Value) {
            deleteMessages(byMessageIds: deletedMessageIds)
        }
        
        if hasMore, let token = token {
            fetchChangeLogs(sinceToken: token)
        }
    }
    
}
