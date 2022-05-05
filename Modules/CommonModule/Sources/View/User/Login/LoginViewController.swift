//
//  LoginViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit
import SendbirdChatSDK

public final class LoginViewController: UIViewController {
    
    public typealias DidConnectUserHandler = (User) -> Void
    
    private let didConnectUser: DidConnectUserHandler
    
    private lazy var userIDLabel: UILabel = {
        let userIDLabel: UILabel = UILabel()
        userIDLabel.text = "USER ID"
        userIDLabel.font = .boldSystemFont(ofSize: 13)
        userIDLabel.textColor = .secondaryLabel
        return userIDLabel
    }()
    
    private lazy var userIDTextField: UITextField = {
        let userIDTextField = UITextField()
        userIDTextField.placeholder = "USER ID"
        userIDTextField.font = .systemFont(ofSize: 24)
        userIDTextField.textColor = .label
        userIDTextField.tintColor = .systemPurple
        userIDTextField.borderStyle = .roundedRect
        return userIDTextField
    }()
    
    private lazy var connectButton: UIButton = {
        let connectButton: UIButton = UIButton()
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(didTouchConnectButton), for: .touchUpInside)
        connectButton.backgroundColor = .systemPurple
        connectButton.layer.cornerRadius = 22
        connectButton.clipsToBounds = true
        return connectButton
    }()
    
    public init(didConnectUser: @escaping DidConnectUserHandler) {
        self.didConnectUser = didConnectUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        loadCachedUser()
    }
    
    private func setupSubviews() {
        view.addSubview(userIDLabel)
        userIDLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIDLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            userIDLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userIDLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(userIDTextField)
        userIDTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIDTextField.topAnchor.constraint(equalTo: userIDLabel.bottomAnchor, constant: 5),
            userIDTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userIDTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectButton.topAnchor.constraint(equalTo: userIDTextField.bottomAnchor, constant: 30),
            connectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            connectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            connectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadCachedUser() {
        if let userID = UserConnectionUseCase.shared.userID {
            userIDTextField.text = userID
        }
        
        if UserConnectionUseCase.shared.isAutoLogin {
            connectUser()
        }
    }
        
    private func connectUser() {
        view.endEditing(true)
        
        guard
            let userID = userIDTextField.text,
            validateText(userID: userID)
        else {
            presentAlert(title: "Error", message: "User ID and Nickname are required.")
            return
        }
        
        updateUIForConnecting()
        
        UserConnectionUseCase.shared.login(userID: userID) { [weak self] result in
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
    
    private func validateText(userID: String) -> Bool {
        userID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    private func updateUIForDefault() {
        userIDTextField.isEnabled = true
        connectButton.isEnabled = true
        connectButton.setTitle("Connect", for: .normal)
    }

    private func updateUIForConnecting() {
        userIDTextField.isEnabled = false
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
        if textField == userIDTextField {
            connectUser()
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
