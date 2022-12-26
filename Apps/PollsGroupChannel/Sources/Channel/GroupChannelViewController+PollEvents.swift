//
//  GroupChannelViewController+PollEvents.swift
//  PollsGroupChannel
//
//  Created by Mihai Moisanu on 26.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import CommonModule

extension GroupChannelViewController: PollUseCaseDelegate{
    
    func pollUseCase(_ pollUseCase: PollUseCase, updatedPoll poll: SendbirdChatSDK.Poll) {
        guard let message = messageListUseCase.messages.first(where: {$0.messageId == poll.messageId}) as? UserMessage else { return }
        message.apply(poll: poll)
    }
    
    func pollUseCase(_ pollUseCase: PollUseCase, didVotePoll event: SendbirdChatSDK.PollVoteEvent) {
        guard let message = messageListUseCase.messages.first(where: {$0.messageId == event.messageId}) as? UserMessage else { return }
        message.apply(pollVoteEvent: event)
    }
    
    func pollUseCase(_ pollUseCase: PollUseCase,  didUpdatePoll event: SendbirdChatSDK.PollUpdateEvent) {
        
    }
    
    func pollUseCase(_ pollUseCase: PollUseCase, pollWasDeleted pollId: Int64) {
    
    }
}
