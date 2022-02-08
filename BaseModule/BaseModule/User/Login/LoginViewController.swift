//
//  LoginViewController.swift
//  BaseModule
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
    
    public typealias DidConnectUserHandler = (SBDUser) -> Void
    
    private let didConnectUser: DidConnectUserHandler
    
    private lazy var userConnection = UserConnection()
    
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
    }
    
    private func loadCachedUser() {
        if let userId = userConnection.userId {
            userIdTextField.text = userId
        }
        
        if let nickname = userConnection.userNickname {
            nicknameTextField.text = nickname
        }
        
        if userConnection.isAutoLogin {
            connectUser()
        }
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
        
        userConnection.login(userId: userId, nickname: nickname) { [weak self] result in
            switch result {
            case .success(let user):
                self?.didConnectUser(user)
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.localizedDescription)
            }
            
            self?.updateUIForDefault()
        }
    }
    
    private func validateText(userId: String, nickname: String) -> Bool {
        userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    private func presentAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
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
