//
//  GroupChannelUserSelectionUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendbirdChat

public protocol GroupChannelUserSelectionUseCaseDelegate: AnyObject {
    func userSelectionUseCase(_ userSelectionUseCase: GroupChannelUserSelectionUseCase, didReceiveError error: SBError)
    func userSelectionUseCase(_ userSelectionUseCase: GroupChannelUserSelectionUseCase, didUpdateUsers users: [User])
    func userSelectionUseCase(_ userSelectionUseCase: GroupChannelUserSelectionUseCase, didUpdateSelectedUsers selectedUsers: [User])
}

// MARK: - UserSelectionUseCase

open class GroupChannelUserSelectionUseCase {
    
    public weak var delegate: GroupChannelUserSelectionUseCaseDelegate?
    
    public private(set) var users: [User] = []
    
    public private(set) var selectedUsers: Set<User> = []
    
    private let channel: GroupChannel?
    
    private var userListQuery: SBDApplicationUserListQuery?
    
    public init(channel: GroupChannel?) {
        self.channel = channel
    }
        
    open func reloadUsers() {
        userListQuery = createApplicationUserListQuery()
        
        guard let userListQuery = userListQuery, userListQuery.hasNext else { return }
        
        userListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.userSelectionUseCase(self, didReceiveError: error)
                return
            }
            
            guard let users = users else { return }
            
            self.users = self.filterUsers(users)
            self.delegate?.userSelectionUseCase(self, didUpdateUsers: users)
        }
    }
    
    open func loadNextPage() {
        guard let userListQuery = userListQuery, userListQuery.hasNext else { return }
        
        userListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.userSelectionUseCase(self, didReceiveError: error)
                return
            }
            
            guard let users = users else { return }
            
            self.users.append(contentsOf: self.filterUsers(users))
            self.delegate?.userSelectionUseCase(self, didUpdateUsers: self.users)
        }
    }
    
    open func createApplicationUserListQuery() -> SBDApplicationUserListQuery? {
        let query = SBDMain.createApplicationUserListQuery()
        query?.limit = 20
        return query
    }
    
    public func toggleSelectUser(_ user: User) {
        if isSelectedUser(user) {
            selectedUsers.remove(user)
        } else {
            selectedUsers.insert(user)
        }
        
        delegate?.userSelectionUseCase(self, didUpdateSelectedUsers: Array(selectedUsers))
    }
    
    public func isSelectedUser(_ user: User) -> Bool {
        selectedUsers.contains(user)
    }
    
    private func filterUsers(_ users: [User]) -> [User] {
        let currentUser = SBDMain.getCurrentUser()

        return users.filter {
            $0.userId != currentUser?.userId
            && hasMember(ofUserId: $0.userId) == false
        }
    }
    
    private func hasMember(ofUserId userId: String) -> Bool {
        guard let channel = channel else {
            return false
        }

        return channel.hasMember(userId)
    }
    
}
