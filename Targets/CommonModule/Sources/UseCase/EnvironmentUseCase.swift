//
//  EnvironmentUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChat

public class EnvironmentUseCase {
    
    private static let applicationId: String = "A74A3E6C-ECE4-410C-AA5D-69D397B1EA73"
    
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
