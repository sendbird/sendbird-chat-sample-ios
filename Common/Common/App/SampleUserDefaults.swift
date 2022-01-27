//
//  SampleUserDefaults.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import Foundation
import SendBirdSDK

final class SampleUserDefaults {
    
    @UserDefault(key: "sendbird_auto_login", defaultValue: false)
    static var isAutoLogin: Bool

    @UserDefault(key: "sendbird_user_id", defaultValue: nil)
    static var userId: String?

    @UserDefault(key: "sendbird_user_nickname", defaultValue: nil)
    static var nickname: String?
    
}
