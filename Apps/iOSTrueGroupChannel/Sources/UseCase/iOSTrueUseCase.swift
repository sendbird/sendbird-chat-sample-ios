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
        SendbirdChat.addConnectionDelegate(self as ConnectionDelegate, identifier: "[CONNECTION_DELEGATE]")
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
        let currentUserId = SendbirdChat.getCurrentUser()!.userId
        let query = SendbirdChat.createApplicationUserListQuery {
            $0.userIdsFilter = [currentUserId]
        }
        return query
    }
}

extension iOSTrueUseCase: ConnectionDelegate {
    
    func didConnect(userId: String) {
        let currentUserId = SendbirdChat.getCurrentUser()!.userId
        if userId == currentUserId {
            self.delegate?.userConnection(self, didUpdateUserStatus: true)
        }
    }
    
    func didDisconnect(userId: String) {
        let currentUserId = SendbirdChat.getCurrentUser()!.userId
        if userId == currentUserId {
            self.delegate?.userConnection(self, didUpdateUserStatus: false)
        }
    }
}
