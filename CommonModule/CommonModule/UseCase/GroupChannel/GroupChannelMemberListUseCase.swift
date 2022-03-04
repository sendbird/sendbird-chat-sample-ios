//
//  GroupChannelMemberListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/04.
//

import Foundation
import SendBirdSDK

public protocol GroupChannelMemberListUseCaseDelegate: AnyObject {
    func groupChannelMemberListUseCase(_ useCase: GroupChannelMemberListUseCase, didReceiveError error: SBDError)
    func groupChannelMemberListUseCase(_ useCase: GroupChannelMemberListUseCase, didUpdateMembers members: [SBDMember])
}

open class GroupChannelMemberListUseCase {
    
    public weak var delegate: GroupChannelMemberListUseCaseDelegate?
    
    public private(set) var members: [SBDMember] = []
    
    private let channel: SBDGroupChannel
    
    private lazy var memberListQuery = channel.createMemberListQuery()
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }
    
    open func loadNextPage() {
        guard let memberListQuery = memberListQuery,
              memberListQuery.isLoading == false,
              memberListQuery.hasNext else { return }
        
        memberListQuery.loadNextPage { [weak self] members, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelMemberListUseCase(self, didReceiveError: error)
                return
            }
            
            self.members.append(contentsOf: members ?? [])
            self.delegate?.groupChannelMemberListUseCase(self, didUpdateMembers: self.members)
        }
    }
        
}
