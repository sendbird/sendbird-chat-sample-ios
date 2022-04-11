//
//  TimestampStorage.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/22.
//

import Foundation
import SendbirdChatSDK

public class TimestampStorage {
    
    public typealias Timestamp = Int64
    
    private var timestamps: [String: Timestamp] = [:]
    
    public init() { }
    
    public func update(timestamp: Timestamp, for channel: BaseChannel) {
        update(timestamp: timestamp, forChannelUrl: channel.channelURL)
    }
    
    public func lastTimestamp(for channel: BaseChannel) -> Timestamp? {
        lastTimestamp(forChannelUrl: channel.channelURL)
    }
    
    private func update(timestamp: Timestamp, forChannelUrl channelUrl: String) {
        guard timestamp > (lastTimestamp(forChannelUrl: channelUrl) ?? 0) else { return }
        
        timestamps[channelUrl] = timestamp
    }
    
    private func lastTimestamp(forChannelUrl channelUrl: String) -> Timestamp? {
        timestamps[channelUrl]
    }
    
}
