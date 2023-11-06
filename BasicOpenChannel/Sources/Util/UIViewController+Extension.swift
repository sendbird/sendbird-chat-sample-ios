//
//  UIViewController+Extension.swift
//  CommonModule
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
    
    public func presentAlert(title: String, message: String?, closeHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in closeHandler?() }))
        present(alert, animated: true)
    }
    
    public func presentTextFieldAlert(title: String, message: String?, defaultTextFieldMessage: String, didConfirm: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.text = defaultTextFieldMessage
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak alert] _ in
            guard let textFieldText = alert?.textFields?.first?.text else { return }
            
            didConfirm(textFieldText)
        })
        
        present(alert, animated: true)
    }
    
    public func presentAlert(error: Error) {
        presentAlert(title: "Error", message: error.localizedDescription)
    }
    
}
