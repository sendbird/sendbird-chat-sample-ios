//
//  MarkAsReadUseCase.swift
//  MarkAsReadGroupChannel
//
//  Created by Yogesh Veeraraj on 18.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol MarkAsReadUseCaseDelegate: AnyObject {
    func markAsReadUseCaseUseCase(
        _ useCase: MarkAsReadUseCase,
        didDidUpdateReadStatus channel: GroupChannel
    )
    
    func markAsReadUseCaseUseCase(
        _ useCase: MarkAsReadUseCase,
        didUpdateFailed error: SBError
    )
}

class MarkAsReadUseCase: GroupChannelDelegate {
    private let channel: GroupChannel
    
    weak var delegate: MarkAsReadUseCaseDelegate?

    init(channel: GroupChannel) {
        self.channel = channel
        subscribeToGroupChannelDelegate()
    }
    
    private func subscribeToGroupChannelDelegate() {
        SendbirdChat.add(self, identifier: String(describing: self))
    }

    func markAsRead() {
        return channel.markAsRead { [weak self] error in
            guard let error = error, let self = self else {
                return
            }
            self.delegate?.markAsReadUseCaseUseCase(self, didUpdateFailed: error)
        }
    }
    
    func channelDidUpdateReadStatus(_ channel: GroupChannel) {
        if self.channel.channelURL == channel.channelURL {
            delegate?.markAsReadUseCaseUseCase(self, didDidUpdateReadStatus: channel)
        }
    }
}
