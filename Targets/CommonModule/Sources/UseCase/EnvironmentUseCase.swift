//
//  EnvironmentUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChat

public class EnvironmentUseCase {
    
    private static let applicationId: String = "9880C4C1-E6C8-46E8-A8F1-D5890D598C08"
    
    public static func initializeSendbirdSDK() {
        let initParams = InitParams(
            applicationId: applicationId,
            isLocalCachingEnabled: false,
            logLevel: .error,
            appVersion: "1.0.0"
        )
        SendbirdChat.initialize(params: initParams)
    }
    
}
