//
//  LoginViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit
import SendBirdSDK

public final class LoginViewController: UIViewController {

    @IBOutlet private weak var connectButton: UIButton!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var userIdTextField: UITextField!
    @IBOutlet private weak var nicknameTextField: UITextField!
    @IBOutlet private weak var versionInfoLabel: UILabel!
    @IBOutlet private weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    public typealias DidConnectUserHandler = (SBDUser) -> Void
    
    private let didConnectUser: DidConnectUserHandler
        
    public init(didConnectUser: @escaping DidConnectUserHandler) {
        self.didConnectUser = didConnectUser
        super.init(nibName: "LoginViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCachedUser()
        loadVersion()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardNotifications()
    }
    
    private func loadCachedUser() {
        if let userId = UserConnectionUseCase.shared.userId {
            userIdTextField.text = userId
        }
        
        if let nickname = UserConnectionUseCase.shared.userNickname {
            nicknameTextField.text = nickname
        }
        
        if UserConnectionUseCase.shared.isAutoLogin {
            connectUser()
        }
    }
    
    private func loadVersion() {
        versionInfoLabel.text = VersionInfo().description
    }
    
    private func connectUser() {
        view.endEditing(true)
        
        guard
            let userId = userIdTextField.text,
            let nickname = nicknameTextField.text,
            validateText(userId: userId, nickname: nickname)
        else {
            presentAlert(title: "Error", message: "User ID and Nickname are required.")
            return
        }
        
        updateUIForConnecting()
        
        UserConnectionUseCase.shared.login(userId: userId, nickname: nickname) { [weak self] result in
            switch result {
            case .success(let user):
                self?.didConnectUser(user)
            case .failure(let error):
                self?.presentAlert(error: error)
            }
            
            self?.updateUIForDefault()
        }
    }
    
    private func validateText(userId: String, nickname: String) -> Bool {
        userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    private func updateUIForDefault() {
        userIdTextField.isEnabled = true
        nicknameTextField.isEnabled = true
        connectButton.isEnabled = true
        connectButton.setTitle("Connect", for: .normal)
    }

    private func updateUIForConnecting() {
        userIdTextField.isEnabled = false
        nicknameTextField.isEnabled = false
        connectButton.isEnabled = false
        connectButton.setTitle("Connecting...", for: .normal)
    }
    
    @IBAction private func didTouchConnectButton(_ sender: UIButton) {
        connectUser()
    }
    
}


// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userIdTextField {
            nicknameTextField.becomeFirstResponder()
        } else {
            connectUser()
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}

// MARK: - Keyboard

extension LoginViewController {
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.keyboardWillHideNotification , object: nil)
    }
    
    @objc
    private func keyboardWillAppear(notification: NSNotification?) {
        guard let notification = notification,
                let keyboardFrame = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue,
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        scrollViewBottomConstraint.constant = keyboardHeight
        
        UIView.animate(withDuration: duration, delay: 0, options: .init(rawValue: curve)) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillDisappear(notification: NSNotification?) {
        guard let notification = notification,
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        scrollViewBottomConstraint.constant = 0.0
        
        UIView.animate(withDuration: duration, delay: 0, options: .init(rawValue: curve)) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
}