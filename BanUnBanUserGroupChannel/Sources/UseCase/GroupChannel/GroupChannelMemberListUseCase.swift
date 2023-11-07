//
//  GroupChannelMemberListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/04.
//

import Foundation
import SendbirdChatSDK

public protocol GroupChannelMemberListUseCaseDelegate: AnyObject {
    func groupChannelMemberListUseCase(_ useCase: GroupChannelMemberListUseCase, didReceiveError error: SBError)
    func groupChannelMemberListUseCase(_ useCase: GroupChannelMemberListUseCase, didUpdateMembers members: [User])
}

open class GroupChannelMemberListUseCase {
    
    public weak var delegate: GroupChannelMemberListUseCaseDelegate?
    
    public private(set) var members: [User] = []
    
    private let channel: GroupChannel
    private lazy var memberListQuery: MemberListQuery? = self.isBannedListQuery ? nil : self.channel.createMemberListQuery()
    private lazy var bannedUserListQuery: BannedUserListQuery? = self.isBannedListQuery ? self.channel.createBannedUserListQuery() : nil
    private var isBannedListQuery: Bool
    
    public init(channel: GroupChannel, isBannedListQuery: Bool) {
        self.channel = channel
        self.isBannedListQuery = isBannedListQuery
    }
    
    open func loadNextPage() {
        if isBannedListQuery {
            loadBannedUsers()
        } else {
            loadMembers()
        }
    }
  
    open func resetAndLoad() {
        members = []
        memberListQuery = channel.createMemberListQuery()
        bannedUserListQuery = channel.createBannedUserListQuery()
        loadNextPage()
    }
    
    private func loadMembers() {
        guard let query = memberListQuery, !query.isLoading, query.hasNext else { return }
        
        query.loadNextPage { [weak self] members, error in
            self?.handleQueryResult(members, error: error)
        }
    }
    
    private func loadBannedUsers() {
        guard let query = bannedUserListQuery, !query.isLoading, query.hasNext else { return }
        
        query.loadNextPage { [weak self] members, error in
            self?.handleQueryResult(members, error: error)
        }
    }
    
    private func handleQueryResult(_ members: [User]?, error: SBError?) {
        if let error = error {
            delegate?.groupChannelMemberListUseCase(self, didReceiveError: error)
            return
        }
        
        if let members = members {
            self.members.append(contentsOf: members)
            delegate?.groupChannelMemberListUseCase(self, didUpdateMembers: self.members)
        }
    }
}
