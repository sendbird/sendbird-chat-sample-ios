//
//  OpenChannelOperatorListUseCase.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/14.
//

import Foundation
import SendBirdSDK

public class OpenChannelOperatorListUseCase {
    
    public var operators: [SBDUser] {
        (channel.operators as? [SBDUser]) ?? []
    }
    
    private let channel: SBDOpenChannel
    
    public init(channel: SBDOpenChannel) {
        self.channel = channel
    }

}
