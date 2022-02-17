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
    
    public private(set) var messages: [SBDBaseMessage] = []

    private let channel: SBDGroupChannel

    private let isReversed: Bool
    
    private lazy var messageCollection: SBDMessageCollection = createMessageCollection()
    
    private var startingPoint: Int64?
    
    public init(channel: SBDGroupChannel, isReversed: Bool, startingPoint: Int64? = nil) {
        self.channel = channel
        self.isReversed = isReversed
        self.startingPoint = startingPoint
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
        delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: messages)
    }
    
    open func loadPreviousMessages() {
        guard messageCollection.hasPrevious else { return }
        
        messageCollection.loadPrevious { [weak self] messages, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            if self.isReversed {
                self.messages.append(contentsOf: messages)
            } else {
                self.messages.insert(contentsOf: messages, at: 0)
            }
            self.delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
    open func loadNextMessages() {
        guard messageCollection.hasNext else { return }
        
        messageCollection.loadNext { [weak self] messages, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelMessageListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let messages = messages else { return }
            
            if self.isReversed {
                self.messages.insert(contentsOf: messages, at: 0)
            } else {
                self.messages.append(contentsOf: messages)
            }
            self.delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: self.messages)
        }
    }
    
    open func createMessageCollection() -> SBDMessageCollection {
        // You can use a SBDMessageListParams instance for the SBDMessageCollection.
        let params = SBDMessageListParams()
        params.reverse = isReversed
        
        let collection = SBDMessageCollection(channel: channel, startingPoint: startingPoint ?? .max, params: params)
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
    
}

// MARK: - SBDMessageCollectionDelegate

extension GroupChannelMessageListUseCase: SBDMessageCollectionDelegate {
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, addedMessages messages: [SBDBaseMessage]) {
        if self.isReversed {
            self.messages.insert(contentsOf: messages, at: 0)
        } else {
            self.messages.append(contentsOf: messages)
        }
        
        delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: self.messages)
    }

    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, updatedMessages messages: [SBDBaseMessage]) {
        switch context.messageSendingStatus {
        case .succeeded:
            // Update the messages status of sent messages.
            print("[GroupChannelMessageListUseCase] succeeded updatedMessages: \(messages)")
            self.messages = self.messages.map { oldMessage in
                messages.first { $0.messageId == oldMessage.messageId } ?? oldMessage
            }
        case .pending: // (failed -> pending)
            // Update the message status from failed to pending in your data source.
            // Remove the failed message from the data source.
            print("[GroupChannelMessageListUseCase] pending updatedMessages: \(messages)")
        case .failed: // (pending -> failed)
            // Update the message status from pending to failed in your data source.
            // Remove the pending message from the data source.
            print("[GroupChannelMessageListUseCase] failed updatedMessages: \(messages)")
        case .canceled: // (pending -> canceled)
            // Remove the pending message from the data source.
            // Implement codes to process canceled messages on your end. The Chat SDK doesn't store canceled messages.
            print("[GroupChannelMessageListUseCase] canceled updatedMessages: \(messages)")
        default:
            print("[GroupChannelMessageListUseCase] default updatedMessages: \(messages)")
        }
        
        delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: self.messages)
    }

    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, deletedMessages messages: [SBDBaseMessage]) {
        switch context.messageSendingStatus {
        case .succeeded:
            // Remove the sent message from your data source.
            print("[GroupChannelMessageListUseCase] succeeded deletedMessages: \(messages)")
            self.messages = self.messages.filter { oldMessage in
                messages.map { $0.messageId }.contains(oldMessage.messageId) == false
            }
        case .failed:
            // Remove the failed message from your data source.
            print("[GroupChannelMessageListUseCase] failed deletedMessages: \(messages)")
        default:
            print("[GroupChannelMessageListUseCase] default deletedMessages: \(messages)")
        }
        
        delegate?.groupChannelMessageListUseCase(self, didUpdateMessages: self.messages)
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
    }

}
