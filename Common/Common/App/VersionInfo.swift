//
//  VersionInfo.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/27.
//

import Foundation
import SendBirdSDK

struct VersionInfo {

    static var description: String? {
        // TO DO: 하나의 Bundle에 있는 Version 가져오도록 수정
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let infoDict = NSDictionary.init(contentsOfFile: path),
              let sampleUIVersion = infoDict["CFBundleShortVersionString"] as? String
        else { return nil }
        return "Sample UI v\(sampleUIVersion) / SDK v\(SBDMain.getSDKVersion())"
    }
    
}
