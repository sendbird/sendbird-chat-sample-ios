//
//  UserLoginViewController.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import UIKit
import SendbirdChatSDK
import CommonModule

public final class UserLoginViewController: UIViewController {
    
    public typealias DidConnectUserHandler = (User) -> Void
    
    private let didConnectUser: DidConnectUserHandler
    
    private lazy var userIdLabel: UILabel = {
        let userIdLabel: UILabel = UILabel()
        userIdLabel.text = "USER ID"
        userIdLabel.font = .boldSystemFont(ofSize: 13)
        userIdLabel.textColor = .secondaryLabel
        return userIdLabel
    }()
    
    private lazy var userIdTextField: UITextField = {
        let userIdTextField = UITextField()
        userIdTextField.placeholder = "USER ID"
        userIdTextField.font = .systemFont(ofSize: 24)
        userIdTextField.textColor = .label
        userIdTextField.tintColor = .systemPurple
        userIdTextField.borderStyle = .roundedRect
        return userIdTextField
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
        view.addSubview(userIdLabel)
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIdLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            userIdLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userIdLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(userIdTextField)
        userIdTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userIdTextField.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: 5),
            userIdTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            userIdTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectButton.topAnchor.constraint(equalTo: userIdTextField.bottomAnchor, constant: 30),
            connectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            connectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            connectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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

extension UserLoginViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userIdTextField {
            connectUser()
            textField.resignFirstResponder()
        }
        
        return true
    }
    
}
