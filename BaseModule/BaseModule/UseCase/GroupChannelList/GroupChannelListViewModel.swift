//
//  GroupChannelList.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import Foundation
import SendBirdSDK

public protocol GroupChannelListViewModelDelegate: AnyObject {
    func groupChannelListViewModel(_ groupChannelListViewModel: GroupChannelListViewModel, didUpdateChannels channels: [SBDGroupChannel])
    func groupChannelListViewModel(_ groupChannelListViewModel: GroupChannelListViewModel, didReceiveError error: SBDError)
}

// MARK: - GroupChannelListViewModel

open class GroupChannelListViewModel: NSObject {
    
    public weak var delegate: GroupChannelListViewModelDelegate?
    
    public var channels: [SBDGroupChannel] = []
    
    private lazy var channelListCollection: SBDGroupChannelCollection = createGroupChannelListCollection()
    
    public override init() {
        super.init()
    }
    
    open func reloadChannels() {
        channelListCollection.dispose()
        channelListCollection = createGroupChannelListCollection()
        channelListCollection.loadMore { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelListViewModel(self, didReceiveError: error)
                return
            }
            
            guard let channels = channels else { return }
            self.channels = channels
            self.delegate?.groupChannelListViewModel(self, didUpdateChannels: self.channels)
        }
    }
    
    open func loadNextPage() {
        guard channelListCollection.hasMore else { return }
        
        channelListCollection.loadMore { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelListViewModel(self, didReceiveError: error)
                return
            }

            guard let channels = channels else { return }
            self.channels.append(contentsOf: channels)
            self.delegate?.groupChannelListViewModel(self, didUpdateChannels: self.channels)
        }
    }
        
    open func createGroupChannelListCollection() -> SBDGroupChannelCollection {
        let channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery() ?? SBDGroupChannelListQuery.init(dictionary: [:])
        channelListQuery.order = .latestLastMessage
        channelListQuery.limit = 20
        channelListQuery.includeEmptyChannel = true
        
        let collection = SBDGroupChannelCollection(query: channelListQuery)
        collection.delegate = self

        return collection
    }
    
    open func leaveChannel(_ channel: SBDGroupChannel, completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.leave { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}

// MARK: - SBDGroupChannelCollectionDelegate

extension GroupChannelListViewModel: SBDGroupChannelCollectionDelegate {
    
    public func channelCollection(_ collection: SBDGroupChannelCollection, context: SBDChannelContext, addedChannels channels: [SBDGroupChannel]) {
        self.channels.insert(contentsOf: channels, at: 0)
        self.delegate?.groupChannelListViewModel(self, didUpdateChannels: self.channels)
    }
    
    public func channelCollection(_ collection: SBDGroupChannelCollection, context: SBDChannelContext, updatedChannels channels: [SBDGroupChannel]) {
        let updatedChannels = channels
        
        self.channels = self.channels.map { channel in
            updatedChannels.first(where: { $0.channelUrl == channel.channelUrl }) ?? channel
        }
        
        self.delegate?.groupChannelListViewModel(self, didUpdateChannels: self.channels)
    }
    
    public func channelCollection(_ collection: SBDGroupChannelCollection, context: SBDChannelContext, deletedChannelUrls: [String]) {
        self.channels = self.channels.filter {
            deletedChannelUrls.contains($0.channelUrl) == false
        }
        
        self.delegate?.groupChannelListViewModel(self, didUpdateChannels: self.channels)
    }
    
}