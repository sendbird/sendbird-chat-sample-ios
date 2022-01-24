//
//  AppDelegate.swift
//  AFeatureSample
//
//  Created by Ernest Hong on 2022/01/24.
//

import UIKit
import Common

@main
class AppDelegate: BaseAppDelegate {

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: UISceneSession Lifecycle

    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return super.application(application, configurationForConnecting: connectingSceneSession, options: options)
    }

    override func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        super.application(application, didDiscardSceneSessions: sceneSessions)
    }

}

