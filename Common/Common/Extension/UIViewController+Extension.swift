//
//  UIViewController+Extension.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/24.
//

import UIKit
import SendBirdSDK

enum AlertAction {
    case cancel, close
    
    func create(on viewController: UIViewController) -> UIAlertAction {
        switch self {
        case .cancel:
            let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            return action
        case .close:
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            return action
        }
    }
}

extension UIViewController {
    
    public func showAlertController(title: String?, message: String?, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionCancel = AlertAction.close.create(on: viewController)
        alert.addAction(actionCancel)
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showAlertController(error: SBDError) {
        let alert = UIAlertController(title: "Error", message: error.domain, preferredStyle: .alert)
        let actionCancel = AlertAction.cancel.create(on: self)
        alert.addAction(actionCancel)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }

}
