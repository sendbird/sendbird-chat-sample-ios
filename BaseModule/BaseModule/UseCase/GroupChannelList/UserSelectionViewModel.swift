//
//  UserSelectionViewModel.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/10.
//

import Foundation
import SendBirdSDK

public protocol UserSelectionViewModelDelegate: AnyObject {
    func userSelectionViewModel(_ userSelectionViewModel: UserSelectionViewModel, didReceiveError error: SBDError)
    func userSelectionViewModel(_ userSelectionViewModel: UserSelectionViewModel, didUpdateUsers users: [SBDUser])
    func userSelectionViewModel(_ userSelectionViewModel: UserSelectionViewModel, didUpdateSelectedUsers selectedUsers: [SBDUser])
}

// MARK: - UserSelectionViewModel

open class UserSelectionViewModel {
    
    public weak var delegate: UserSelectionViewModelDelegate?
    
    public private(set) var users: [SBDUser] = []
        
    public private(set) var selectedUsers: Set<SBDUser> = []
    
    private var userListQuery: SBDApplicationUserListQuery?
    
    public init() { }
        
    open func reloadUsers() {
        userListQuery = createApplicationUserListQuery()
        
        guard let userListQuery = userListQuery, userListQuery.hasNext else { return }
        
        userListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.userSelectionViewModel(self, didReceiveError: error)
                return
            }
            
            guard let users = users else { return }
            
            let currentUser = SBDMain.getCurrentUser()
            self.users = users.filter { $0.userId != currentUser?.userId }
            
            self.delegate?.userSelectionViewModel(self, didUpdateUsers: users)
        }
    }
    
    open func loadNextPage() {
        guard let userListQuery = userListQuery, userListQuery.hasNext else { return }
        
        userListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.userSelectionViewModel(self, didReceiveError: error)
                return
            }
            
            guard let users = users else { return }
            
            let currentUser = SBDMain.getCurrentUser()
            self.users.append(contentsOf: users.filter { $0.userId != currentUser?.userId })
            
            self.delegate?.userSelectionViewModel(self, didUpdateUsers: self.users)
        }
    }
    
    open func createApplicationUserListQuery() -> SBDApplicationUserListQuery? {
        let query = SBDMain.createApplicationUserListQuery()
        query?.limit = 20
        return query
    }
    
    public func toggleSelectUser(_ user: SBDUser) {
        if isSelectedUser(user) {
            selectedUsers.remove(user)
        } else {
            selectedUsers.insert(user)
        }
        
        delegate?.userSelectionViewModel(self, didUpdateSelectedUsers: Array(selectedUsers))
    }
    
    public func isSelectedUser(_ user: SBDUser) -> Bool {
        selectedUsers.contains(user)
    }
    
}
