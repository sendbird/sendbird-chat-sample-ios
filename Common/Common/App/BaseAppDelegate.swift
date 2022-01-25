//
//  BaseAppDelegate.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/24.
//

import UIKit
import SendBirdSDK

@main
open class BaseAppDelegate: UIResponder, UIApplicationDelegate, SBDChannelDelegate {
    
    private let applicationId: String = "9880C4C1-E6C8-46E8-A8F1-D5890D598C08"
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("[Sendbird] applicationId: \(applicationId)")
        SBDMain.initWithApplicationId(applicationId)
        SBDMain.add(self as SBDChannelDelegate, identifier: description)
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    open func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    open func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}

