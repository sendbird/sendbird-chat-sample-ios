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
        SBDMain.initWithApplicationId(applicationId)
        SBDMain.setLogLevel([.error, .info])
    }
    
}
