//
//  PollUseCase.swift
//  PollsGroupChannel
//
//  Created by Mihai Moisanu on 22.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol PollUseCaseDelegate: AnyObject{
    func pollUseCase(_ pollUseCase:PollUseCase, didVotePoll event: PollVoteEvent)
    func pollUseCase(_ pollUseCase:PollUseCase, didUpdatePoll event: PollUpdateEvent)
    func pollUseCase(_ pollUseCase:PollUseCase, pollWasDeleted pollId: Int64)
    func pollUseCase(_ pollUseCase:PollUseCase, updatedPoll poll: Poll)
}

class PollUseCase : GroupChannelDelegate{
    
    public weak var delegate: PollUseCaseDelegate?
    
    private let channel:GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
        SendbirdChat.addChannelDelegate(self, identifier: String(describing: self))
    }
    
    func channel(_ channel: GroupChannel, didVotePoll event: PollVoteEvent) {
        delegate?.pollUseCase(self, didVotePoll: event)
    }
    
    func channel(_ channel: GroupChannel, didUpdatePoll event: PollUpdateEvent) {
        delegate?.pollUseCase(self, didUpdatePoll: event)
    }
    
    func channel(_ channel: GroupChannel, pollWasDeleted pollId: Int64) {
        delegate?.pollUseCase(self, pollWasDeleted: pollId)
    }
    
    func createPoll(pollTitle:String, pollOptions:[String], closeAt:Int64?, allowUserSuggestions:Bool, allowMultipleVotes:Bool, onPollCreated: @escaping (SBError?) -> Void){
        let params = PollCreateParams(builder: { builder in
            builder.title = pollTitle
            builder.optionTexts = pollOptions
            if let closeAt = closeAt{
                builder.closeAt = closeAt
            }
            builder.allowMultipleVotes = allowMultipleVotes
            builder.allowUserSuggestion = allowUserSuggestions
        })
        Poll.create(params: params, completionHandler: { [weak self] poll, error in
            if let error = error {
                DispatchQueue.main.async { onPollCreated(error) }
                return
            }
            guard let poll = poll else { return }
            let userMessageParams = UserMessageCreateParams(message: pollTitle)
            userMessageParams.pollId = poll.pollId
            self?.channel.sendUserMessage(params: userMessageParams, completionHandler: { message, error in
                if let error = error{
                    DispatchQueue.main.async { onPollCreated(error) }
                    return
                }
                onPollCreated(nil)
            })
        })
    }
    
    func closePoll(poll:Poll, onPollClosed: @escaping (SBError?) -> Void){
        channel.closePoll(pollId: poll.pollId, completionHandler: {[weak self] poll, error in
            if let error = error {
                DispatchQueue.main.async { onPollClosed(error) }
                return
            }
            guard let poll = poll, let self = self else { return }
            self.delegate?.pollUseCase(self, updatedPoll: poll)
        })
    }
    
    func votePollOptions(_ poll:Poll, _  pollOptionIds: [Int64], _ onOptionVoted: @escaping (SBError?) -> Void){
        channel.votePoll(pollId: poll.pollId, pollOptionIds: pollOptionIds, completionHandler: { [weak self] pollVoteEvent, error in
            if let error = error{
                DispatchQueue.main.async { onOptionVoted(error) }
                return
            }
            guard let pollVoteEvent = pollVoteEvent, let self = self else { return }
            self.delegate?.pollUseCase(self, didVotePoll: pollVoteEvent)
        })
    }
    
    func addPollOption(_ poll: Poll, _ optionText:String, onOptionAdded: @escaping(SBError) -> Void){
        channel.addPollOption(pollId: poll.pollId, optionText: optionText, completionHandler: { [weak self] poll, error in
            if let error = error {
                DispatchQueue.main.async { onOptionAdded(error) }
                return
            }
            guard let poll = poll, let self = self else { return }
            self.delegate?.pollUseCase(self, updatedPoll: poll)
        })
    }
}
