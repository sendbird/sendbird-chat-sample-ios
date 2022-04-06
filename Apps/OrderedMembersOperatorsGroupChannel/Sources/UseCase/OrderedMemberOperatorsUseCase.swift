//
//  OrderedMemberOperatorsUseCase.swift
//  OrderedMemberOperatorsGroupChannel
//
//  Created by Yogesh Veeraraj on 06.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChat

protocol OrderedMemberOperatorsUseCaseDelegate: AnyObject {
    func groupChannelOrderedMemberOperatorsUseCase(_ useCase: OrderedMemberOperatorsUseCase, didReceiveError error: SBError)
    func groupChannelOrderedMemberOperatorsUseCase(_ useCase: OrderedMemberOperatorsUseCase, didUpdateMembers members: [Member])
}

class OrderedMemberOperatorsUseCase {
    
    weak var delegate: OrderedMemberOperatorsUseCaseDelegate?
    
    private(set) var members: [Member] = []
    
    private let channel: GroupChannel
    
    private lazy var membersListQuery: GroupChannelMemberListQuery? = {
        let query = channel.createMemberListQuery()
        query?.limit = 10
        query?.order = .operatorThenMemberNicknameAlphabetical
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
                self.delegate?.groupChannelOrderedMemberOperatorsUseCase(
                    self,
                    didReceiveError: error
                )
                return
            }
            
            self.members.append(contentsOf: users ?? [])
            self.delegate?.groupChannelOrderedMemberOperatorsUseCase(
                self,
                didUpdateMembers: self.members
            )
        }
    }
    
}
