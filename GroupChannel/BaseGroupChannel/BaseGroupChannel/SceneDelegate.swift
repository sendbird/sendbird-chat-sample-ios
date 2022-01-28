//
//  SceneDelegate.swift
//  BaseGroupChannel
//
//  Created by Ernest Hong on 2022/01/27.
//

import UIKit
import Common

class SceneDelegate: BaseSceneDelegate {
    
    override func createMainViewController() -> UIViewController {
        UINavigationController(
            rootViewController: BaseGroupChannelListViewController()
        )
    }
    
}
