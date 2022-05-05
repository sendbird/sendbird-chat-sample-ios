//
//  EnvironmentUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChatSDK

public class EnvironmentUseCase {
    
    public enum ApplicationId {
        case sample
        case custom(String)
        
        var rawValue: String {
            switch self {
            case .sample:
                return "9880C4C1-E6C8-46E8-A8F1-D5890D598C08"
            case .custom(let value):
                return value
            }
        }
    }
    
    public static func initializeSendbirdSDK(applicationID: ApplicationId) {
        let initParams = InitParams(
            applicationID: applicationID.rawValue,
            isLocalCachingEnabled: false,
            logLevel: .error,
            appVersion: "1.0.0"
        )
        SendbirdChat.initialize(params: initParams)
    }
    
}
