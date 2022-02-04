//
//  BaseGroupChannelViewModel.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/28.
//

import Foundation
import SendBirdSDK

public protocol BaseGroupChannelViewModelModelDelegate: AnyObject {
    func groupChannelViewModelDidUpdateMessages(_ viewModel: BaseGroupChannelViewModel)
    func groupChannelViewModel(_ viewModel: BaseGroupChannelViewModel, didReceiveError error: SBDError)
}

open class BaseGroupChannelViewModel: NSObject {
    
    open weak var delegate: BaseGroupChannelViewModelModelDelegate?
    
    public let channel: SBDGroupChannel
    
    private var messages: [SBDBaseMessage] = []
    
    private lazy var collection: SBDMessageCollection = createMessageCollection()
    
    required public init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init()
    }
    
    open func createMessageListParams() -> SBDMessageListParams {
        let params = SBDMessageListParams()
        params.reverse = false
        return params
    }
    
    open func createMessageCollection() -> SBDMessageCollection {
        let params = createMessageListParams()
        let collection = SBDMessageCollection(channel: channel, startingPoint: Int64(Date().timeIntervalSince1970), params: params)
        collection.delegate = self
        return collection
    }
    
    open func cellText(for message: SBDBaseMessage) -> String? {
        "\(message.sender?.nickname ?? "Unknown"): \(message.message)"
    }
    
    public func reloadData() {
        collection.dispose()
        collection = createMessageCollection()
        collection.start(
            with: .cacheAndReplaceByApi,
            cacheResultHandler: { [weak self] messages, error in
                if let error = error {
                    self?.notify(error)
                    return
                }
                guard let self = self, let messages = messages else { return }
                self.messages = messages
                self.delegate?.groupChannelViewModelDidUpdateMessages(self)
            },
            apiResultHandler: { [weak self] messages, error in
                if let error = error {
                    self?.notify(error)
                    return
                }
                guard let self = self, let messages = messages else { return }
                self.messages = messages
                self.delegate?.groupChannelViewModelDidUpdateMessages(self)
            }
        )
    }
    
    public func loadPrevMessages() {
        guard collection.hasPrevious else { return }
        
        collection.loadPrevious { [weak self] messages, error in
            if let error = error {
                self?.notify(error)
                return
            }
            guard let self = self, let messages = messages else { return }
            self.messages.insert(contentsOf: messages, at: 0)
            self.delegate?.groupChannelViewModelDidUpdateMessages(self)
        }
    }
    
    public func loadNextMessages() {
        collection.loadNext { [weak self] messages, error in
            if let error = error {
                self?.notify(error)
                return
            }
            guard let self = self, let messages = messages else { return }
            self.messages.append(contentsOf: messages)
            self.delegate?.groupChannelViewModelDidUpdateMessages(self)
        }
    }
    
    public func message(byMessageId messageId: Int64) -> SBDBaseMessage? {
        messages.first { $0.messageId == messageId }
    }
    
    public func message(at indexPath: IndexPath) -> SBDBaseMessage? {
        guard messages.count > indexPath.row else {
            return nil
        }
        
        return messages[indexPath.row]
    }
    
    public func numberOfMessages() -> Int {
        messages.count
    }
    
    public func notify(_ error: SBDError) {
        delegate?.groupChannelViewModel(self, didReceiveError: error)
    }
    
}

// MARK: - SBDMessageCollectionDelegate

extension BaseGroupChannelViewModel: SBDMessageCollectionDelegate {
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, addedMessages messages: [SBDBaseMessage]) {
        
    }
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, updatedMessages messages: [SBDBaseMessage]) {
        
    }
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, channel: SBDGroupChannel, deletedMessages messages: [SBDBaseMessage]) {
        
    }
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, updatedChannel channel: SBDGroupChannel) {
        
    }
    
    public func messageCollection(_ collection: SBDMessageCollection, context: SBDMessageContext, deletedChannel channelUrl: String) {
        
    }
    
    public func didDetectHugeGap(_ collection: SBDMessageCollection) {
        collection.dispose()
        reloadData()
    }
    
}
