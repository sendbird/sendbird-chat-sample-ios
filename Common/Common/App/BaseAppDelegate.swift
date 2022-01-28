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
    
    private let applicationId: String = "A74A3E6C-ECE4-410C-AA5D-69D397B1EA73"
    
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

