//
//  MutedMembersListGroupChannel.swift
//  MutedAndBannedUsersListGroupChannel
//
//  Created by Yogesh Veeraraj on 19.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol MutedMembersListUseCaseDelegate: AnyObject {
    func groupChannelMutedMembersListUseCase(_ useCase: MutedMembersListUseCase, didReceiveError error: SBError)
    func groupChannelMutedMembersListUseCase(_ useCase: MutedMembersListUseCase, didUpdateMembers members: [User])
}

class MutedMembersListUseCase {
    
    weak var delegate: MutedMembersListUseCaseDelegate?
    
    private(set) var members: [User] = []
    
    private let channel: GroupChannel
    
    private lazy var membersListQuery: MutedUserListQuery? = {
        let query = channel.createMutedUserListQuery()
        query?.limit = 10
        return query
    }()
    
    public init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func loadNextPage() {
        guard let membersListQuery = membersListQuery,
              membersListQuery.isLoading == false,
              membersListQuery.hasNext else { return }
        
        membersListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelMutedMembersListUseCase(
                    self,
                    didReceiveError: error
                )
                return
            }
            
            self.members.append(contentsOf: users ?? [])
            self.delegate?.groupChannelMutedMembersListUseCase(
                self,
                didUpdateMembers: self.members
            )
        }
    }
    
}

