//
//  iOSTrueUseCase.swift
//  iOSTrueGroupChannel
//
//  Created by Yogesh Veeraraj on 25.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol iOSTrueUseCaseDelegate: AnyObject {
    func userConnection(_ useCase: iOSTrueUseCase, didUpdateUserStatus isOnline: Bool)
}

// MARK: - UserSelectionUseCase

class iOSTrueUseCase: NSObject {
    
    weak var delegate: iOSTrueUseCaseDelegate?
    
    private let channel: GroupChannel?
    
    private var userListQuery: ApplicationUserListQuery?
    
    init(channel: GroupChannel?) {
        self.channel = channel
        super.init()
        SendbirdChat.add(self as ConnectionDelegate, identifier: "[CONNECTION_DELEGATE]")
    }
        
    func checkUserConnectionStatus() {
        userListQuery = createApplicationUserListQuery()
        
        guard let userListQuery = userListQuery, userListQuery.hasNext else { return }
        
        userListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if error == nil {
                self.delegate?.userConnection(self, didUpdateUserStatus: users?[0].connectionStatus == .online)
            }
        }
    }
        
    private func createApplicationUserListQuery() -> ApplicationUserListQuery {
        let currentUserId = SendbirdChat.getCurrentUser()!.userID
        let query = SendbirdChat.createApplicationUserListQuery()
        query.userIDsFilter = [currentUserId]
        return query
    }
}

extension iOSTrueUseCase: ConnectionDelegate {
    
    func didConnect(userID: String) {
        let currentUserId = SendbirdChat.getCurrentUser()!.userID
        if userID == currentUserId {
            self.delegate?.userConnection(self, didUpdateUserStatus: true)
        }
    }
    
    func didDisconnect(userID: String) {
        let currentUserId = SendbirdChat.getCurrentUser()!.userID
        if userID == currentUserId {
            self.delegate?.userConnection(self, didUpdateUserStatus: false)
        }
    }
}
