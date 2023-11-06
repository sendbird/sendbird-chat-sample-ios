//
//  GroupChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChatSDK

public protocol GroupChannelMessageListUseCaseDelegate: AnyObject {
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didReceiveError error: SBError)
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateMessages messages: [BaseMessage])
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateChannel channel: GroupChannel)
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didDeleteChannel channel: GroupChannel)
}

open class GroupChannelMessageListUseCase: NSObject {
    
    public weak var delegate: GroupChannelMessageListUseCaseDelegate?
    
    open var messages: [BaseMessage] = [] {
        didSet {
            notifyChangeMessages()
        }
    }
    
    open var isLoading: Bool = false

    public private(set) var channel: GroupChannel

    private let timestampStorage: TimestampStorage
    
    private var messageCollection: MessageCollection?
    
    public init(channel: GroupChannel, timestampStorage: TimestampStorage) {
        self.channel = channel
        self.timestampStorage = timestampStorage
        super.init()
    }
    
    deinit {
        messageCollection?.dispose()
    }
    
    open func loadInitialMessages() {
        messageCollection = createMessageCollection()

        messageCollection?.startCollection(initPolicy: .cacheAndReplaceByApi, cacheResultHandler: { [weak self] messages, error in
            // Messages will be retrieved from the local cache.
            // They might be too outdated compared to the startingPoint.
            self?.handleInitialMessages(messages: messages, error: error)
        }, apiResultHandler: { [weak self] messages, error in
            // Messages will be retrieved from the Sendbird server through API.
            // According to the SBDMessageCollectionInitPolicy.cacheAndReplaceByApi,
            // the existing data source needs to be cleared
            // before adding retrieved messages to the local cache.
            self?.handleInitialMessages(messages: messages, error: error)
        })
    }
    
    private func handleInitialMessages(messages: [BaseMessage]?, error: SBError?) {
        if let error = error {
            delegate?.groupChannelMessageListUseCase(self, didReceiveError: error)
            return
        }
        
        guard let messages = messages else { return }
        self.messages = messages
    }
        
    open func loadPreviousMessages() {
        guard isLoading == false,
              let messageCollection = messageCollection,
              messageCollection.hasPrevious else { return }
        
        isLoading = true
        messageCollection.loadPrevious { [weak self] messages, error in
            defer { self?.isLoading = false }
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.appendPreviousMessages(messages)
        }
    }
    
    open func loadNextMessages() {
        guard isLoading == false,
              let messageCollection = messageCollection,
              messageCollection.hasNext else { return }
        
        isLoading = true
        messageCollection.loadNext { [weak self] messages, error in
            defer { self?.isLoading = false }
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            self.appendNextMessages(messages)
        }
    }
    
    open func createMessageCollection() -> MessageCollection? {
        // You can use a SBDMessageListParams instance for the SBDMessageCollection.
        let params = MessageListParams()
        params.previousResultSize = 20
        params.nextResultSize = 20
        params.replyType = .all
        params.includeThreadInfo = true
        params.includeParentMessageInfo = true
        
        let collection = SendbirdChat.createMessageCollection(
            channel: channel,
            startingPoint: timestampStorage.lastTimestamp(for: channel) ?? .max,
            params: params
        )
        
        collection.delegate = self
        
        return collection
    }
    
    open func markAsRead() {
        channel.markAsRead { error in
            if let error = error {
                print("[GroupChannelMessageListUseCase] markAsRead error: \(error)")
            }
        }
    }
    
    private func appendPreviousMessages(_ newMessages: [BaseMessage]) {
        guard newMessages.isEmpty == false else { return }
        
        messages.insert(contentsOf: newMessages, at: 0)
    }
    
    private func appendNextMessages(_ newMessages: [BaseMessage]) {
        guard newMessages.isEmpty == false else { return }
        
        messages.append(contentsOf: newMessages)
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
    
    private func notifyChangeMessages() {
        if let lastTimestamp = messages.last?.createdAt {
            timestampStorage.update(timestamp: lastTimestamp, for: channel)
        }
        delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: messages)
    }
}

// MARK: - MessageCollectionDelegate

extension GroupChannelMessageListUseCase: MessageCollectionDelegate {
    
    open func messageCollection(_ collection: MessageCollection, context: MessageContext, channel: GroupChannel, addedMessages: [BaseMessage]) {
        appendNextMessages(addedMessages)
    }
    
    open func messageCollection(_ collection: MessageCollection, context: MessageContext, channel: GroupChannel, updatedMessages: [BaseMessage]) {
        replaceMessages(updatedMessages)
    }
   
    open func messageCollection(_ collection: MessageCollection, context: MessageContext, channel: GroupChannel, deletedMessages: [BaseMessage]) {
        switch context.sendingStatus {
        case .succeeded:
            self.messages = self.messages.filter { oldMessage in
                deletedMessages.map { $0.messageId }.contains(oldMessage.messageId) == false
            }
        case .failed:
            // Remove the failed message from your data source.
            print("[GroupChannelMessageListUseCase] failed deletedMessages: \(deletedMessages)")
        default:
            print("[GroupChannelMessageListUseCase] default deletedMessages: \(deletedMessages)")
        }
    }

    open func messageCollection(_ collection: MessageCollection, context: MessageContext, updatedChannel channel: GroupChannel) {
        // Change the chat view with the updated channel information.
        self.channel = channel
        delegate?.groupChannelMessageListUseCase(self, didUpdateChannel: channel)
    }

    open func messageCollection(_ collection: MessageCollection, context: MessageContext, deletedChannel channelURL: String) {
        // This is called when a channel was deleted. So the current chat view should be cleared.
        guard channel.channelURL == channelURL else { return }
        delegate?.groupChannelMessageListUseCase(self, didDeleteChannel: channel)
    }

    open func didDetectHugeGap(_ collection: MessageCollection) {
        // The Chat SDK detects more than 300 messages missing.
        messageCollection?.dispose()
        loadInitialMessages()
    }

}
