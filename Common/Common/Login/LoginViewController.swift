//
//  LoginViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/24.
//

import UIKit
import SendBirdSDK

public final class LoginViewController: UIViewController, UITextFieldDelegate {
    
    typealias DidConnectUserHandler = (SBDUser) -> Void
    
    private let loginModel = LoginModel()
    
    private let didConnectUser: DidConnectUserHandler
    
    private lazy var loginView = LoginView(
        onRequestConnect: { [weak self] in
            self?.connect()
        }
    )
    
    private var loginViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Override
    init(didConnectUser: @escaping DidConnectUserHandler) {
        self.didConnectUser = didConnectUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        
        let loginViewBottomConstraint = loginView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        self.loginViewBottomConstraint = loginViewBottomConstraint
        
        NSLayoutConstraint.activate([
            loginViewBottomConstraint,
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            loginView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            loginView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
        loadData()
    }
    
    private func loadData() {
        loginView.userId = loginModel.userId
        loginView.nickname = loginModel.nickname
        loginView.versionInfo = loginModel.versionInfo
        
        if loginModel.isAutoLogin {
            connect()
        }
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrameBegin = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else  { return }
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        let keyboardHeight = keyboardFrameBeginRect.size.height
        
        adjustBottomConstraint(keyboardHeight)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustBottomConstraint(0)
    }
    
    private func adjustBottomConstraint(_ keyboardHeight: CGFloat) {
        view.layoutIfNeeded()
        
        loginViewBottomConstraint?.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
            self?.loginView.isLogoHidden = keyboardHeight > 0
        }
    }
    
    func connect() {
        view.endEditing(true)
        
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect { [weak self] in
                DispatchQueue.main.async {
                    self?.loginView.updateUIForConnectiong(isConnecting: false)
                }
            }
        } else {
            let userId = loginView.userId?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let nickname = loginView.nickname?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            guard let userId = userId, let nickname = nickname else {
                showAlertController(title: "Error", message: "User ID and Nickname are required.", viewController: self)
                return
            }
            
            loginModel.userId = userId
            loginModel.nickname = nickname
            loginView.updateUIForConnectiong(isConnecting: true)
            
            ConnectionManager.login(userId: userId, nickname: nickname) { [weak self] user, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.loginView.updateUIForConnectiong(isConnecting: false)
                    }
                    self?.showAlertController(error: SBDError.init(nsError: error))
                    return
                }
                
                guard let user = user else { return }
                
                DispatchQueue.main.async {
                    self?.loginView.updateUIForConnectiong(isConnecting: false)
                    self?.didConnectUser(user)
                }
            }
        }
    }
    
}

//    // MARK: - NotificationDelegate
//
//    func openChat(_ channelUrl: String) {
//        self.navigationController?.popViewController(animated: false)
//        let tabBarVC = MainTabBarController.init(nibName: "MainTabBarController", bundle: nil)
//        self.present(tabBarVC, animated: false) {
//            let vc = UIViewController.currentViewController()
//            if vc is GroupChannelsViewController {
//                (vc as! GroupChannelsViewController).openChat(channelUrl)
//            }
//        }
//    }
