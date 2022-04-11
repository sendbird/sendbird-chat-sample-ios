//
//  GroupChannelList.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/09.
//

import Foundation
import SendbirdChatSDK

public protocol GroupChannelListUseCaseDelegate: AnyObject {
    func groupChannelListUseCase(_ groupChannelListUseCase: GroupChannelListUseCase, didUpdateChannels channels: [GroupChannel])
    func groupChannelListUseCase(_ groupChannelListUseCase: GroupChannelListUseCase, didReceiveError error: SBError)
}

// MARK: - GroupChannelListUseCase

open class GroupChannelListUseCase: NSObject {
    
    public weak var delegate: GroupChannelListUseCaseDelegate?
    
    public var channels: [GroupChannel] = []
    
    private var channelListCollection: GroupChannelCollection?
    
    public override init() {
        super.init()
    }
    
    open func reloadChannels() {
        channelListCollection?.dispose()
        channelListCollection = createGroupChannelListCollection()
        channelListCollection?.loadMore { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let channels = channels else { return }
            self.channels = channels
            self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
        }
    }
    
    open func loadNextPage() {
        guard let channelListCollection = channelListCollection,
              channelListCollection.hasNext else { return }
        
        channelListCollection.loadMore { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelListUseCase(self, didReceiveError: error)
                return
            }

            guard let channels = channels else { return }
            self.channels.append(contentsOf: channels)
            self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
        }
    }
        
    open func createGroupChannelListCollection() -> GroupChannelCollection? {
        let channelListQuery = GroupChannel.createMyGroupChannelListQuery()
        channelListQuery.order = .latestLastMessage
        channelListQuery.limit = 20
        channelListQuery.includeEmptyChannel = true
        
        let collection = SendbirdChat.createGroupChannelCollection(query: channelListQuery)
        collection?.delegate = self

        return collection
    }
    
    open func leaveChannel(_ channel: GroupChannel, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.leave { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}

// MARK: - GroupChannelCollectionDelegate

extension GroupChannelListUseCase: GroupChannelCollectionDelegate {
    
    open func channelCollection(_ collection: GroupChannelCollection, context: ChannelContext, addedChannels channels: [GroupChannel]) {
        self.channels.insert(contentsOf: channels, at: 0)
        self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
    open func channelCollection(_ collection: GroupChannelCollection, context: ChannelContext, updatedChannels channels: [GroupChannel]) {
        let updatedChannels = channels
        
        self.channels = self.channels.map { channel in
            updatedChannels.first(where: { $0.channelURL == channel.channelURL }) ?? channel
        }
        
        self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
    public func channelCollection(_ collection: GroupChannelCollection, context: ChannelContext, deletedChannelURLs: [String]) {
        self.channels = self.channels.filter {
            deletedChannelURLs.contains($0.channelURL) == false
        }

        self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
}
