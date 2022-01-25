//
//  BaseSettingViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import UIKit

open class BaseSettingViewController: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Setting"
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }

}
