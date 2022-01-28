//
//  SceneDelegate.swift
//  UpdateCopyDeleteMessage
//
//  Created by Ernest Hong on 2022/01/28.
//

import UIKit
import Common

class SceneDelegate: BaseSceneDelegate {
    
    override func createMainViewController() -> UIViewController {
        UINavigationController(
            rootViewController: BaseGroupChannelListViewController(
                groupChannelViewControllerType: EditMessageViewController.self
            )
        )
    }
    
}
