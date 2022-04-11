//
//  GroupChannelOperatorListUseCase.swift
//  OperatorListGroupChannel
//
//  Created by Yogesh Veeraraj on 03.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol GroupChannelOperatorListUseCaseDelegate: AnyObject {
    func groupChannelOperatorListUseCase(_ useCase: GroupChannelOperatorListUseCase, didReceiveError error: SBError)
    func groupChannelOperatorListUseCase(_ useCase: GroupChannelOperatorListUseCase, didUpdateOperators operators: [User])
}

 class GroupChannelOperatorListUseCase {
    
    weak var delegate: GroupChannelOperatorListUseCaseDelegate?
    
    private(set) var operators: [User] = []
    
    private let channel: GroupChannel
    
    private lazy var operatorListQuery = channel.createOperatorListQuery()
     
    public init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func loadNextPage() {
        guard let operatorListQuery = operatorListQuery,
              operatorListQuery.isLoading == false,
              operatorListQuery.hasNext else { return }
        
        operatorListQuery.loadNextPage { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.groupChannelOperatorListUseCase(
                    self,
                    didReceiveError: error
                )
                return
            }
            
            self.operators.append(contentsOf: users ?? [])
            self.delegate?.groupChannelOperatorListUseCase(
                self,
                didUpdateOperators: self.operators
            )
        }
    }
        
}
