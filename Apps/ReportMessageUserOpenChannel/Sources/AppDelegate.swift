//
//  AppDelegate.swift
//  BasicOpenChannel
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit
import SendbirdChatSDK
import CommonModule

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        EnvironmentUseCase.initializeSendbirdSDK(applicationID: .sample)
        BaseAppearance.apply()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
        window?.rootViewController = createLoginViewController()
        window?.makeKeyAndVisible()
        
        return true
    }

    private func createLoginViewController() -> LoginViewController {
        return LoginViewController(didConnectUser: { [weak self] _ in
            self?.presentMainViewController()
        })
    }
    
    private func presentMainViewController() {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([
            UINavigationController(rootViewController: OpenChannelListViewController()),
            UINavigationController(rootViewController: SettingViewController())
        ], animated: false)
        tabBarController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(tabBarController, animated: true)
    }

}

