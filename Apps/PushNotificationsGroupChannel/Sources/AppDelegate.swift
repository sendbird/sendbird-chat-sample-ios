//
//  AppDelegate.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit
import SendbirdChatSDK
import CommonModule
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        EnvironmentUseCase.initializeSendbirdSDK(applicationId: .sample)
        BaseAppearance.apply()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .systemBackground
        window?.rootViewController = createLoginViewController()
        window?.makeKeyAndVisible()
        
        registerForPushNotifications()
        
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
            UINavigationController(rootViewController: GroupChannelListViewController()),
            UINavigationController(rootViewController: SettingViewController())
        ], animated: false)
        tabBarController.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(tabBarController, animated: true)
    }
    
    private func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationUseCase().registerPushToken(deviceToken: deviceToken)
    }

}

