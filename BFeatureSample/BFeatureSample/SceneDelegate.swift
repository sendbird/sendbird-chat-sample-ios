//
//  SceneDelegate.swift
//  BFeatureSample
//
//  Created by Ernest Hong on 2022/01/24.
//

import UIKit
import Common

class SceneDelegate: BaseSceneDelegate {
    
    @available(iOS 13.0, *)
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func createMainViewController() -> UIViewController {
        let mainViewController = LogoutViewController()
        mainViewController.view.backgroundColor = .systemGreen
        return mainViewController
    }
    
}
