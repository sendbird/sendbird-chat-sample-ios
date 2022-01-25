//
//  LoginModel.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import Foundation
import SendBirdSDK

final class LoginModel {
    var isAutoLogin: Bool {
        get { UserDefaults.standard.bool(forKey: "sendbird_auto_login") }
        set { UserDefaults.standard.setValue(newValue, forKey: "sendbird_auto_login") }
    }

    var userId: String? {
        get { UserDefaults.standard.string(forKey: "sendbird_user_id") }
        set { UserDefaults.standard.setValue(newValue, forKey: "sendbird_user_id") }
    }
    
    var nickname: String? {
        get { UserDefaults.standard.string(forKey: "sendbird_user_nickname") }
        set { UserDefaults.standard.setValue(newValue, forKey: "sendbird_user_nickname") }
    }
    
    var versionInfo: String? {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let infoDict = NSDictionary.init(contentsOfFile: path),
              let sampleUIVersion = infoDict["CFBundleShortVersionString"] as? String
        else { return nil }
        return "Sample UI v\(sampleUIVersion) / SDK v\(SBDMain.getSDKVersion())"
    }
}
