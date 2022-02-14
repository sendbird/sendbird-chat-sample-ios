//
//  BaseAppearance.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/13.
//

import UIKit

public struct BaseAppearance {
    
    public static func apply() {
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = .secondarySystemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
}
