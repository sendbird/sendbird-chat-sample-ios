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
    
    public func presentAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }
    
    public func presentAlert(error: Error) {
        presentAlert(title: "Error", message: error.localizedDescription)
    }
    
}
