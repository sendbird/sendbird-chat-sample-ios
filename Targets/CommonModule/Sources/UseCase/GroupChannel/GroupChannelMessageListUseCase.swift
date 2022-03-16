//
//  GroupChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChat

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
            if let lastTimestamp = messages.last?.createdAt {
                timestampStorage.update(timestamp: lastTimestamp, for: channel)
            }
            
            delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: messages)
        }
    }
    
    open var isLoading: Bool = false

    public private(set) var channel: GroupChannel

    private let timestampStorage: TimestampStorage
    
    private lazy var messageCollection: SBDMessageCollection = createMessageCollection()
    
    public init(channel: GroupChannel, timestampStorage: TimestampStorage) {
        self.channel = channel
        self.timestampStorage = timestampStorage
        super.init()
    }
    
    open func loadInitialMessages() {
        messageCollection.start(with: .cacheAndReplaceByApi, cacheResultHandler: { [weak self] messages, error in
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
        guard isLoading == false, messageCollection.hasPrevious else { return }
        
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
        guard isLoading == false, messageCollection.hasNext else { return }
        
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
    
    open func createMessageCollection() -> SBDMessageCollection {
        // You can use a SBDMessageListParams instance for the SBDMessageCollection.
        let params = SBDMessageListParams()
        let collection = SBDMessageCollection(
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
        messages.insert(contentsOf: newMessages, at: 0)
    }
    
    private func appendNextMessages(_ newMessages: [BaseMessage]) {
        guard validateNextMessages(newMessages) else { return }
        
        messages.append(contentsOf: newMessages)
    }
    
    private func validateNextMessages(_ newMessages: [BaseMessage]) -> Bool {
        guard let oldCreatedAt = messages.last?.createdAt else { return true }
        guard let newCreatedAt = newMessages.first?.createdAt else { return false }
        
        return oldCreatedAt <= newCreatedAt
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
    
}

// MARK: - SBDMessageCollectionDelegate

extension GroupChannelMessageListUseCase: SBDMessageCollectionDelegate {
    
    open func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: GroupChannel, addedMessages messages: [BaseMessage]) {
        appendNextMessages(messages)
    }

    open func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: GroupChannel, updatedMessages messages: [BaseMessage]) {
        replaceMessages(messages)
    }

    open func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: GroupChannel, deletedMessages messages: [BaseMessage]) {
        switch context.messageSendingStatus {
        case .succeeded:
            self.messages = self.messages.filter { oldMessage in
                messages.map { $0.messageId }.contains(oldMessage.messageId) == false
            }
        case .failed:
            // Remove the failed message from your data source.
            print("[GroupChannelMessageListUseCase] failed deletedMessages: \(messages)")
        default:
            print("[GroupChannelMessageListUseCase] default deletedMessages: \(messages)")
        }
    }

    open func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, updatedChannel channel: GroupChannel) {
        // Change the chat view with the updated channel information.
        self.channel = channel
        delegate?.groupChannelMessageListUseCase(self, didUpdateChannel: channel)
    }

    open func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, deletedChannel channelUrl: String) {
        // This is called when a channel was deleted. So the current chat view should be cleared.
        guard channel.channelUrl == channelUrl else { return }
        delegate?.groupChannelMessageListUseCase(self, didDeleteChannel: channel)
    }

    open func didDetectHugeGap(_ collection: SBDMessageCollection) {
        // The Chat SDK detects more than 300 messages missing.

        // Dispose of the current collection.
        messageCollection.dispose()

        // Create a new message collection object.
        messageCollection = createMessageCollection()

        // An additional implementation is required for initialization.
        loadInitialMessages()
    }

}
