//
//  OpenChannelParticipantListUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/03/07.
//

import Foundation
import SendbirdChat

public protocol OpenChannelParticipantListUseCaseDelegate: AnyObject {
    func openChannelParticipantListUseCase(_ useCase: OpenChannelParticipantListUseCase, didReceiveError error: SBDError)
    func openChannelParticipantListUseCase(_ useCase: OpenChannelParticipantListUseCase, didUpdateParticipants participants: [SBDUser])
}

open class OpenChannelParticipantListUseCase {
    
    public weak var delegate: OpenChannelParticipantListUseCaseDelegate?
    
    public private(set) var participants: [SBDUser] = []
    
    private let channel: SBDOpenChannel
    
    private lazy var participantListQuery = channel.createParticipantListQuery()
    
    public init(channel: SBDOpenChannel) {
        self.channel = channel
        
        channel.createParticipantListQuery()
    }
    
    open func loadNextPage() {
        guard let participantListQuery = participantListQuery,
              participantListQuery.isLoading() == false,
              participantListQuery.hasNext else { return }
        
        participantListQuery.loadNextPage { [weak self] participants, error in
            guard let self = self else { return }
            
            if let error = error {
                self.delegate?.openChannelParticipantListUseCase(self, didReceiveError: error)
                return
            }
            
            self.participants.append(contentsOf: participants ?? [])
            self.delegate?.openChannelParticipantListUseCase(self, didUpdateParticipants: self.participants)
        }
    }
        
}
