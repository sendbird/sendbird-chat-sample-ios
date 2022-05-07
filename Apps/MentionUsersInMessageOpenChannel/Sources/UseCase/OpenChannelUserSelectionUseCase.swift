//
//  OpenChannelUserSelectionUseCase.swift
//  MentionUsersInMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 05.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import CommonModule

class OpenChannelUserSelectionUseCase: OpenChannelParticipantListUseCase {
    
    public private(set) var selectedUsers: Set<User> = []

    public func toggleSelectUser(_ user: User) {
        if isSelectedUser(user) {
            selectedUsers.remove(user)
        } else {
            selectedUsers.insert(user)
        }
    }
    
    public func isSelectedUser(_ user: User) -> Bool {
        selectedUsers.contains(user)
    }
}
