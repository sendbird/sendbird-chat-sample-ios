//
//  KeyboardObserver.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/22.
//

import UIKit

public struct KeyboardInfo {
    public let height: CGFloat
    public let animationDuration: TimeInterval
    public let animationCurve: UInt
    
    public func animate(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: animationDuration, delay: 0, options: .init(rawValue: animationCurve), animations: animations, completion: completion)
    }
}

public protocol KeyboardObserverDelegate: AnyObject {
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willShowKeyboardWith keyboardInfo: KeyboardInfo)
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willHideKeyboardWith keyboardInfo: KeyboardInfo)
}

public class KeyboardObserver {
    
    public weak var delegate: KeyboardObserverDelegate?
    
    public init() { }
    
    public func add() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    public func remove() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification , object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification?) {
        guard let notification = notification,
                let keyboardFrame = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue,
                let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let height = keyboardFrame.cgRectValue.height
        let keyboardInfo = KeyboardInfo(height: height, animationDuration: animationDuration, animationCurve: animationCurve)
        
        delegate?.keyboardObserver(self, willShowKeyboardWith: keyboardInfo)
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification?) {
        guard let notification = notification,
                let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let keyboardInfo = KeyboardInfo(height: 0, animationDuration: animationDuration, animationCurve: animationCurve)
        
        delegate?.keyboardObserver(self, willHideKeyboardWith: keyboardInfo)
    }
    
}
