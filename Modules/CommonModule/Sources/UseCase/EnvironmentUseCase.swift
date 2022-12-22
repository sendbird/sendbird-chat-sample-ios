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
                return "DE295D7F-DCE0-4D86-8F22-D551FD00ADCC"
            case .custom(let value):
                return value
            }
        }
    }
    
    public static func initializeSendbirdSDK(applicationId: ApplicationId) {
        let initParams = InitParams(
            applicationId: applicationId.rawValue,
            isLocalCachingEnabled: false,
            logLevel: .error,
            appVersion: "1.0.0"
        )
        SendbirdChat.initialize(params: initParams)
    }
    
}
