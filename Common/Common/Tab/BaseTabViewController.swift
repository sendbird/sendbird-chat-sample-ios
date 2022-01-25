//
//  BaseTabViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import UIKit

open class BaseTabViewController: UITabBarController {
    
    public init(viewControllers: [UIViewController] = [
        UINavigationController(rootViewController: BaseGroupChannelViewController()),
        UINavigationController(rootViewController: BaseOpenChannelViewController()),
        UINavigationController(rootViewController: LogoutViewController())
    ]) {
        
        super.init(nibName: nil, bundle: nil)
        setViewControllers(viewControllers, animated: false)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
}
