//
//  PollUseCase.swift
//  PollsGroupChannel
//
//  Created by Mihai Moisanu on 22.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class PollUseCase{
    
    private let channel:GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
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
                onPollCreated(error)
                return
            }
            guard let poll = poll else { return }
            let userMessageParams = UserMessageCreateParams(message: pollTitle)
            userMessageParams.pollId = poll.pollId
            self?.channel.sendUserMessage(params: userMessageParams, completionHandler: { message, error in
                if let error = error{
                    onPollCreated(error)
                    return
                }
                onPollCreated(nil)
            })
        })
    }
}
