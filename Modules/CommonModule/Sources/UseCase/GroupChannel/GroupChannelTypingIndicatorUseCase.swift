//
//  GroupChannelTypingIndicatorUseCase.swift
//  CommonModule
//
//  Created by Yogesh Veeraraj on 30.03.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChat
import UIKit

public protocol GroupChannelTypingIndicatorUseCaseDelegate: AnyObject {
    func groupChannelTypingIndicatorUseCase(
        _ useCase: GroupChannelTypingIndicatorUseCase,
        didReceiveTypingStatus status: String
    )
}

public final class GroupChannelTypingIndicatorUseCase: GroupChannelDelegate {
    private let channel: GroupChannel
    
    public weak var delegate: GroupChannelTypingIndicatorUseCaseDelegate?

    public init(channel: GroupChannel) {
        self.channel = channel
        subscribeToTypingIndicatorDelegate()
    }
    
    private func subscribeToTypingIndicatorDelegate() {
        SendbirdChat.add(self, identifier: "[TYPING_INDICATOR_DELEGATE]")
    }
    
    public func startTyping() {
        channel.startTyping()
    }
    
    public func endTyping() {
        channel.endTyping()
    }
    
    public func channelDidUpdateTypingStatus(_ channel: GroupChannel) {
        if channel.channelURL == self.channel.channelURL {
            let status = getTypingStatusString(for: channel.getTypingUsers())
            delegate?.groupChannelTypingIndicatorUseCase(
                self,
                didReceiveTypingStatus: status
            )
        }
    }
    
    private func getTypingStatusString(for users: [User]?) -> String {
        guard let typingUsers = users, !typingUsers.isEmpty else {
            return ""
        }
        
        if typingUsers.count == 1 {
            let userNickName = getUsername(user: typingUsers[0])
            return String(format: "%@ is typing..", userNickName)
        } else if typingUsers.count == 2 {
            let firstUserName = getUsername(user: typingUsers[0])
            let secondUserName = getUsername(user: typingUsers[1])
            return String(format: "%@ and %@ are typing..", firstUserName, secondUserName)
        } else if typingUsers.count > 2 {
            let firstUserName = getUsername(user: typingUsers[0])
            let secondUserName = getUsername(user: typingUsers[1])
            let remainingCount = typingUsers.count - 2
            return String(format: "%@, %@ and %d others are typing..", firstUserName, secondUserName, remainingCount)
        } else {
            return ""
        }
    }
    
    private func getUsername(user: User) -> String {
        return user.nickname ?? user.userId
    }
}
