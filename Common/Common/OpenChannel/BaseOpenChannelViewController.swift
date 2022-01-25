//
//  BaseOpenChannelViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import UIKit

open class BaseOpenChannelViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Open"
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }

}
