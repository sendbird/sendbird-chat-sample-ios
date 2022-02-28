//
//  GroupChannelUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendBirdSDK

public protocol GroupChannelMessageListUseCaseDelegate: AnyObject {
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didReceiveError error: SBDError)
    func groupChannelMessageListUseCase(_ useCase: GroupChannelMessageListUseCase, didUpdateMessages messages: [SBDBaseMessage])
}

open class GroupChannelMessageListUseCase: NSObject {
    
    public weak var delegate: GroupChannelMessageListUseCaseDelegate?
    
    public private(set) var messages: [SBDBaseMessage] = [] {
        didSet {
            if let lastTimestamp = messages.last?.createdAt {
                timestampStorage.update(timestamp: lastTimestamp, for: channel)
            }
            
            delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: messages)
        }
    }
    
    public private(set) var isLoading: Bool = false

    private let channel: SBDGroupChannel

    private let timestampStorage: TimestampStorage
    
    private lazy var messageCollection: SBDMessageCollection = createMessageCollection()
    
    public init(channel: SBDGroupChannel, timestampStorage: TimestampStorage) {
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
    
    private func handleInitialMessages(messages: [SBDBaseMessage]?, error: SBDError?) {
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
    
    public func isOutgoingMessage(_ message: SBDBaseMessage) -> Bool {
        message.sender?.userId == SBDMain.getCurrentUser()?.userId
    }
    
    private func appendPreviousMessages(_ newMessages: [SBDBaseMessage]) {
        messages.insert(contentsOf: newMessages, at: 0)
    }
    
    private func appendNextMessages(_ newMessages: [SBDBaseMessage]) {
        guard validateNextMessages(newMessages) else { return }
        
        messages.append(contentsOf: newMessages)
    }
    
    private func validateNextMessages(_ newMessages: [SBDBaseMessage]) -> Bool {
        guard let oldCreatedAt = messages.last?.createdAt else { return true }
        guard let newCreatedAt = newMessages.first?.createdAt else { return false }
        
        return oldCreatedAt <= newCreatedAt
    }
            
    private func replaceMessages(_ newMessages: [SBDBaseMessage]) {
        messages = messages.map { oldMessage in
            newMessages.first { $0.messageId == oldMessage.messageId || $0.requestId == oldMessage.requestId } ?? oldMessage
        }
        
        // 전체 순회 하지 않고 더 나은 방법 생각해보기
        // Hint: dict - messageId, requestId
    }
    
}

// MARK: - SBDMessageCollectionDelegate

extension GroupChannelMessageListUseCase: SBDMessageCollectionDelegate {
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, addedMessages messages: [SBDBaseMessage]) {
        appendNextMessages(messages)
    }

    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, updatedMessages messages: [SBDBaseMessage]) {
        replaceMessages(messages)
    }

    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, deletedMessages messages: [SBDBaseMessage]) {
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

    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, updatedChannel channel: SBDGroupChannel) {
        // Change the chat view with the updated channel information.
        
    }

    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, deletedChannel channelUrl: String) {
        // This is called when a channel was deleted. So the current chat view should be cleared.
        
    }

    public func didDetectHugeGap(_ collection: SBDMessageCollection) {
        // The Chat SDK detects more than 300 messages missing.

        // Dispose of the current collection.
        messageCollection.dispose()

        // Create a new message collection object.
        messageCollection = createMessageCollection()

        // An additional implementation is required for initialization.
        loadInitialMessages()
    }

}
