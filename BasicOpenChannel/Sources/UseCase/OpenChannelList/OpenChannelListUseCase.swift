//
//  OpenChannelListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import Foundation
import SendbirdChatSDK

public protocol OpenChannelListUseCaseDelegate: AnyObject {
    func openChannelListUseCase(_ openChannelListUseCase: OpenChannelListUseCase, didUpdateChannels channels: [OpenChannel])
    func openChannelListUseCase(_ openChannelListUseCase: OpenChannelListUseCase, didReceiveError error: SBError)
}

// MARK: - GroupChannelListUseCase

open class OpenChannelListUseCase: NSObject {
    
    public weak var delegate: OpenChannelListUseCaseDelegate?
    
    public var channels: [OpenChannel] = []
    
    private lazy var channelListQuery: OpenChannelListQuery = createOpenChannelListQuery()
    
    public override init() {
        super.init()
        
        SendbirdChat.addChannelDelegate(self, identifier: self.description)
    }
    
    open func reloadChannels() {
        guard channelListQuery.isLoading == false else { return }
        
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
        guard channelListQuery.isLoading == false, channelListQuery.hasNext else { return }
        
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
        
    open func createOpenChannelListQuery() -> OpenChannelListQuery {
        let channelListQuery = OpenChannel.createOpenChannelListQuery {
            $0.limit = 20
        }
        return channelListQuery
    }
    
    open func enterChannel(_ channel: OpenChannel, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.enter { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    open func exitChannel(_ channel: OpenChannel, completion: @escaping (Result<Void, SBError>) -> Void) {
        channel.exit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}

// MARK: - BaseChannelDelegate

extension OpenChannelListUseCase: BaseChannelDelegate {
    
    open func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        guard channelType == .open else { return }
        
        self.channels = self.channels.filter {
            $0.channelURL != channelURL
        }
        
        self.delegate?.openChannelListUseCase(self, didUpdateChannels: self.channels)
    }
    
    open func channelWasChanged(_ sender: BaseChannel) {
        guard let changedOpenChannel = sender as? OpenChannel else { return }
        
        self.channels = self.channels.map { channel in
            channel.channelURL == changedOpenChannel.channelURL ? changedOpenChannel : channel
        }
        
        self.delegate?.openChannelListUseCase(self, didUpdateChannels: self.channels)
    }
        
}
