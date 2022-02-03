//
//  BaseGroupChannelViewModel.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/28.
//

import Foundation
import SendBirdSDK

public protocol BaseGroupChannelViewModelModelDelegate: AnyObject {
    func baseGroupChannelViewModelDidUpdateMessages(_ viewModel: BaseGroupChannelViewModel)
}

open class BaseGroupChannelViewModel: NSObject,
                                                                                        GroupChannelViewModelInitializable {
    
    open weak var delegate: BaseGroupChannelViewModelModelDelegate?
    
    private var messages: [SBDBaseMessage] = []
    
    private let channel: SBDGroupChannel
    
    private let identifier = UUID().uuidString
        
    private lazy var collection: SBDMessageCollection = createMessageCollection()
    
    required public init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init()
    }
    
    public func reloadData() {
        collection.dispose()
        collection = createMessageCollection()
        collection.start(
            with: .cacheAndReplaceByApi,
            cacheResultHandler: { [weak self] messages, error in
                guard let self = self, error == nil, let messages = messages else { return }
                self.messages = messages
                self.delegate?.baseGroupChannelViewModelDidUpdateMessages(self)
            },
            apiResultHandler: { [weak self] messages, error in
                guard let self = self, error == nil, let messages = messages else { return }
                self.messages = messages
                self.delegate?.baseGroupChannelViewModelDidUpdateMessages(self)
            }
        )
    }
    
    public func loadPrevMessages() {
        guard collection.hasPrevious else { return }
        
        collection.loadPrevious { [weak self] messages, error in
            guard let self = self, error == nil, let messages = messages else { return }
            self.messages.insert(contentsOf: messages, at: 0)
            self.delegate?.baseGroupChannelViewModelDidUpdateMessages(self)
        }
    }
    
    public func loadNextMessages() {
        collection.loadNext { [weak self] messages, error in
            guard let self = self, error == nil, let messages = messages else { return }
            self.messages.append(contentsOf: messages)
            self.delegate?.baseGroupChannelViewModelDidUpdateMessages(self)
        }
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
    
    private func createMessageCollection() -> SBDMessageCollection {
        let params = SBDMessageListParams()
        params.reverse = false
        
        let collection = SBDMessageCollection(channel: channel, startingPoint: Int64(Date().timeIntervalSince1970), params: params)
        collection.delegate = self
        return collection
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
        self.collection = createMessageCollection()
    }
    
}
