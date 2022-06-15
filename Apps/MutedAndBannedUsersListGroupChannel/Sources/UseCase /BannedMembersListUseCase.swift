//
//  BannedMembersListUseCase.swift
//  MutedAndBannedUsersListGroupChannel
//
//  Created by Yogesh Veeraraj on 19.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol BannedMembersListUseCaseDelegate: AnyObject {
    func groupChannelBannedMembersListUseCase(_ useCase: BannedMembersListUseCase, didReceiveError error: SBError)
    func groupChannelBannedMembersListUseCase(_ useCase: BannedMembersListUseCase, didUpdateMembers members: [User])
}

class BannedMembersListUseCase {
    
    weak var delegate: BannedMembersListUseCaseDelegate?
    
    private(set) var members: [User] = []
    
    private let channel: GroupChannel
    
    private lazy var membersListQuery: BannedUserListQuery? = {
        let params = BannedUserListQueryParams()
        params.limit = 10
        let query = channel.createBannedUserListQuery(params: params)
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
                self.delegate?.groupChannelBannedMembersListUseCase(
                    self,
                    didReceiveError: error
                )
                return
            }
            
            self.members.append(contentsOf: users ?? [])
            self.delegate?.groupChannelBannedMembersListUseCase(
                self,
                didUpdateMembers: self.members
            )
        }
    }
    
}

