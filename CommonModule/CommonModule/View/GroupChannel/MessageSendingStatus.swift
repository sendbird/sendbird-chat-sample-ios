//
//  MessageSendingStatus.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/27.
//

import Foundation
import SendBirdSDK

struct MessageSendingStatus {
    
    let description: String
    
    init(_ rawValue: SBDBaseMessage) {
        switch rawValue.sendingStatus {
        case .pending:
            description = "(pending)"
        case .failed:
            description = "(failed)"
        case .succeeded:
            description = ""
        case .canceled:
            description = "(canceled)"
        default:
            description = ""
        }
    }
    
}
