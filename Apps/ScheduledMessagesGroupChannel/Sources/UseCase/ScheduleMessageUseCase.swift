//
//  ScheduleMessageUseCase.swift
//  ScheduledMessagesGroupChannel
//
//  Created by Mihai Moisanu on 20.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class ScheduleMesssageUseCase{
    
    private let channel:GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func scheduleUserMessage(_ scheduletAt:Int64,_ message:String, completion: @escaping (SBError) -> Void){
        let params = ScheduledUserMessageCreateParams(scheduledAt: scheduletAt, message: message)
        channel.createScheduledUserMessage(params: params, completionHandler: { message, error in
            if let error = error {
                completion(error)
            }
        })
    }
    
    func scheduleFileMessage(_ scheduleAt: Int64, _ file: Data, completion: @escaping (SBError) -> Void){
        let params = ScheduledFileMessageCreateParams(scheduledAt: scheduleAt, file: file)
        channel.createScheduledFileMessage(params: params, completionHandler: {_, error in
            if let error = error{
                completion(error)
            }
        })
    }
    
    func rescheduleUserMessage(_ scheduleAt: Int64, _ scheduledMessageId:Int64, completion: @escaping (SBError?) -> Void){
        let params = ScheduledUserMessageUpdateParams()
        params.scheduledAt = scheduleAt
        channel.updateScheduledUserMessage(scheduledMessageId: scheduledMessageId, params: params, completionHandler: { _, error in
            completion(error)
        })
    }
    
    func rescheduleFileMessage(_ scheduleAt: Int64, _ scheduledMessageId:Int64, completion: @escaping (SBError?) -> Void){
        let params = ScheduledFileMessageUpdateParams()
        params.scheduledAt = scheduleAt
        channel.updateScheduledFileMessage(scheduledMessageId: scheduledMessageId, params: params, completionHandler: { _, error in
            completion(error)
        })
    }
    
    func getScheduledMessages(onMessageRetrieved: @escaping(Result<[BaseMessage],SBError>) -> Void){
        let params = ScheduledMessageListQueryParams{ builder in
            builder.scheduledStatusOptions = .pending
        }
        let query = SendbirdChat.createScheduledMessageListQuery(channelURL: channel.channelURL, params: params)
        let messsages = [BaseMessage]()
        loadMessages(query: query, messages: messsages, onMessageRetrieved: onMessageRetrieved)
    }
    
    private func loadMessages(query:ScheduledMessageListQuery, messages: [BaseMessage], onMessageRetrieved: @escaping(Result<[BaseMessage],SBError>) -> Void){
        if(query.hasNext){
            query.loadNextPage{ [weak self] retrievedMessages, error in
                if let error = error{
                    onMessageRetrieved(Result.failure(error))
                    return
                }
                if let retrievedMessages = retrievedMessages{
                    let newList = messages + retrievedMessages
                    self?.loadMessages(query: query, messages: newList, onMessageRetrieved: onMessageRetrieved)
                    return
                }
                onMessageRetrieved(Result.success(messages))
            }
            return
        }
        onMessageRetrieved(Result.success(messages))
    }
    
}
