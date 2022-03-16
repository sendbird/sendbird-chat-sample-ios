//
//  TimestampStorage.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/22.
//

import Foundation
import SendbirdChat

public class TimestampStorage {
    
    public typealias Timestamp = Int64
    
    private var timestamps: [String: Timestamp] = [:]
    
    public init() { }
    
    public func update(timestamp: Timestamp, for channel: SBDBaseChannel) {
        update(timestamp: timestamp, forChannelUrl: channel.channelUrl)
    }
    
    public func lastTimestamp(for channel: SBDBaseChannel) -> Timestamp? {
        lastTimestamp(forChannelUrl: channel.channelUrl)
    }
    
    private func update(timestamp: Timestamp, forChannelUrl channelUrl: String) {
        guard timestamp > (lastTimestamp(forChannelUrl: channelUrl) ?? 0) else { return }
        
        timestamps[channelUrl] = timestamp
    }
    
    private func lastTimestamp(forChannelUrl channelUrl: String) -> Timestamp? {
        timestamps[channelUrl]
    }
    
}
