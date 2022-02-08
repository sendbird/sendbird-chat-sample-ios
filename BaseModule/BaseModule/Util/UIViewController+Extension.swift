//
//  UIViewController+Extension.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit

extension UIViewController {
    public static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        }

        return instantiateFromNib()
    }
}
