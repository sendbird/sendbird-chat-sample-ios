//
//  SceneDelegate.swift
//  ReactToMessage
//
//  Created by Ernest Hong on 2022/02/03.
//

import UIKit
import Common

class SceneDelegate: BaseSceneDelegate {
    
    override func createMainViewController() -> UIViewController {
        UINavigationController(
            rootViewController: BaseGroupChannelListViewController<ReactToMessageViewController, ReactToMessageViewModel>()
        )
    }
    
}
