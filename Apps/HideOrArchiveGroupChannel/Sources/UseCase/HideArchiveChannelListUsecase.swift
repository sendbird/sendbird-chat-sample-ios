//
//  HideArchiveChannelListUsecase.swift
//  HideOrArchiveGroupChannel
//
//  Created by Yogesh Veeraraj on 03.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol HideArchiveChannelListUsecaseDelegate: AnyObject {
    func groupChannelListUseCase(_ groupChannelListUseCase: HideArchiveChannelListUsecase, didUpdateChannels channels: [GroupChannel])
    func groupChannelListUseCase(_ groupChannelListUseCase: HideArchiveChannelListUsecase, didReceiveError error: SBError)
}

// MARK: - HideArchiveChannelListUsecase

class HideArchiveChannelListUsecase: NSObject {
    
    weak var delegate: HideArchiveChannelListUsecaseDelegate?
    
    var channels: [GroupChannel] = []
    
    private var channelListCollection: GroupChannelCollection?
    
    override init() {
        super.init()
    }
    
    func reloadChannels() {
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
    
    func loadNextPage() {
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
        
    func createGroupChannelListCollection() -> GroupChannelCollection? {
        let channelListQuery = GroupChannel.createMyGroupChannelListQuery {
            $0.order = .latestLastMessage
            $0.limit = 20
            $0.channelHiddenStateFilter = .hiddenOnly
        }
        
        let collection = SendbirdChat.createGroupChannelCollection(query: channelListQuery)
        collection?.delegate = self

        return collection
    }
}

// MARK: - BaseChannelDelegate

extension HideArchiveChannelListUsecase:  GroupChannelCollectionDelegate {
    
    func channelCollection(_ collection: GroupChannelCollection, context: ChannelContext, addedChannels channels: [GroupChannel]) {
        self.channels.insert(contentsOf: channels, at: 0)
        self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
    func channelCollection(_ collection: GroupChannelCollection, context: ChannelContext, updatedChannels channels: [GroupChannel]) {
        let updatedChannels = channels
        
        self.channels = self.channels.map { channel in
            updatedChannels.first(where: { $0.channelURL == channel.channelURL }) ?? channel
        }
        
        self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
    func channelCollection(_ collection: GroupChannelCollection, context: ChannelContext, deletedChannelURLs: [String]) {
        self.channels = self.channels.filter {
            deletedChannelURLs.contains($0.channelURL) == false
        }

        self.delegate?.groupChannelListUseCase(self, didUpdateChannels: self.channels)
    }
}
    
