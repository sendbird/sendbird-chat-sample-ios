//
//  OpenChannelListUseCase.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import Foundation
import SendBirdSDK

public protocol OpenChannelListUseCaseDelegate: AnyObject {
    func openChannelListUseCase(_ openChannelListUseCase: OpenChannelListUseCase, didUpdateChannels channels: [SBDOpenChannel])
    func openChannelListUseCase(_ openChannelListUseCase: OpenChannelListUseCase, didReceiveError error: SBDError)
}

// MARK: - GroupChannelListUseCase

open class OpenChannelListUseCase: NSObject {
    
    public weak var delegate: OpenChannelListUseCaseDelegate?
    
    public var channels: [SBDOpenChannel] = []
    
    private lazy var channelListQuery: SBDOpenChannelListQuery = createOpenChannelListQuery()
    
    public override init() {
        super.init()
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }
    
    open func reloadChannels() {
        guard channelListQuery.isLoading() == false else { return }
        
        channelListQuery = createOpenChannelListQuery()
        channelListQuery.loadNextPage { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelListUseCase(self, didReceiveError: error)
                return
            }
            
            guard let channels = channels else { return }
            self.channels = channels
            self.delegate?.openChannelListUseCase(self, didUpdateChannels: self.channels)
        }
    }
    
    open func loadNextPage() {
        guard channelListQuery.isLoading() == false, channelListQuery.hasNext else { return }
        
        channelListQuery.loadNextPage { [weak self] channels, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelListUseCase(self, didReceiveError: error)
                return
            }

            guard let channels = channels else { return }
            self.channels.append(contentsOf: channels)
            self.delegate?.openChannelListUseCase(self, didUpdateChannels: self.channels)
        }
    }
        
    open func createOpenChannelListQuery() -> SBDOpenChannelListQuery {
        let channelListQuery = SBDOpenChannel.createOpenChannelListQuery() ?? SBDOpenChannelListQuery()
        channelListQuery.limit = 20
        return channelListQuery
    }
    
    open func leaveChannel(_ channel: SBDOpenChannel, completion: @escaping (Result<Void, SBDError>) -> Void) {
        channel.exitChannel { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}

// MARK: - SBDChannelDelegate

extension OpenChannelListUseCase: SBDChannelDelegate {
    
    public func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        guard channelType == .open else { return }
        
        self.channels = self.channels.filter {
            $0.channelUrl != channelUrl
        }
        
        self.delegate?.openChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
    public func channelWasChanged(_ sender: SBDBaseChannel) {
        guard let changedOpenChannel = sender as? SBDOpenChannel else { return }
        
        self.channels = self.channels.map { channel in
            channel.channelUrl == changedOpenChannel.channelUrl ? changedOpenChannel : channel
        }
        
        self.delegate?.openChannelListUseCase(self, didUpdateChannels: self.channels)
    }
        
}
