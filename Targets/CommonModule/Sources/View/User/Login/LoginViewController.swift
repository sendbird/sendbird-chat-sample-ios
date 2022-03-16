//
//  LoginViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit
import SendbirdChat

public final class LoginViewController: UIViewController {

    @IBOutlet private weak var connectButton: UIButton!
    @IBOutlet private weak var userIdTextField: UITextField!
    
    public typealias DidConnectUserHandler = (User) -> Void
    
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
    }
        
    private func loadCachedUser() {
        if let userId = UserConnectionUseCase.shared.userId {
            userIdTextField.text = userId
        }
        
        if UserConnectionUseCase.shared.isAutoLogin {
            connectUser()
        }
    }
        
    private func connectUser() {
        view.endEditing(true)
        
        guard
            let userId = userIdTextField.text,
            validateText(userId: userId)
        else {
            presentAlert(title: "Error", message: "User ID and Nickname are required.")
            return
        }
        
        updateUIForConnecting()
        
        UserConnectionUseCase.shared.login(userId: userId) { [weak self] result in
            self?.updateUIForDefault()
            
            switch result {
            case .success(let user):
                if user.nickname?.isEmpty ?? true {
                    self?.presentEditViewController(user: user)
                } else {
                    self?.didConnectUser(user)
                }
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    private func presentEditViewController(user: User) {
        let profileEditViewController = ProfileEditViewController(completion: { [weak self] in
            self?.didConnectUser(user)
        })
        let navigation = UINavigationController(rootViewController: profileEditViewController)
        navigation.modalPresentationStyle = .fullScreen
        
        present(navigation, animated: true)
    }
    
    private func validateText(userId: String) -> Bool {
        userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    private func updateUIForDefault() {
        userIdTextField.isEnabled = true
        connectButton.isEnabled = true
        connectButton.setTitle("Connect", for: .normal)
    }

    private func updateUIForConnecting() {
        userIdTextField.isEnabled = false
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
            connectUser()
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
