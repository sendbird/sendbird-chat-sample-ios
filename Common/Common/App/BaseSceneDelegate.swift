//
//  BaseSceneDelegate.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/24.
//

import UIKit

open class BaseSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    public var window: UIWindow?
    
    open func createMainViewController() -> UIViewController {
        UIViewController()
    }
    
    @available(iOS 13.0, *)
    open func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        if let window = self.window {
            let viewController = LoginViewController(didConnectUser: { [weak self] _ in
                guard let self = self else { return }
                
                let mainViewController = self.createMainViewController()
                mainViewController.modalPresentationStyle = .fullScreen
                self.window?.rootViewController?.present(mainViewController, animated: true)
            })
            window.backgroundColor = .systemBackground
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }

    @available(iOS 13.0, *)
    open func sceneDidEnterBackground(_ scene: UIScene) { }
    
    @available(iOS 13.0, *)
    open func sceneWillEnterForeground(_ scene: UIScene) { }
    
    @available(iOS 13.0, *)
    open func sceneDidBecomeActive(_ scene: UIScene) { }
    
    @available(iOS 13.0, *)
    open func sceneWillResignActive(_ scene: UIScene) { }
    
}
