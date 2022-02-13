//
//  VersionInfo.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/13.
//

import Foundation
import SendBirdSDK

struct VersionInfo {
    
    var description: String? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let infoDict = NSDictionary(contentsOfFile: path),
              let sampleUIVersion = infoDict["CFBundleShortVersionString"] as? String else { return nil }
        return "Sample UI v\(sampleUIVersion) / SDK v\(SBDMain.getSDKVersion())"
    }
    
}
