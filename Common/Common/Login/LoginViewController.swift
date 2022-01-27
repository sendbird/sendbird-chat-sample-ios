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
    
    // MARK: - Property
    
    private let didConnectUser: DidConnectUserHandler
    
    private lazy var viewModel: LoginViewModel = {
        let viewModel = LoginViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    private lazy var loginView = LoginView(onRequestConnect: { [weak self] in
        self?.connect()
    })
    
    private var loginViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Life Cycle
    
    init(didConnectUser: @escaping DidConnectUserHandler) {
        self.didConnectUser = didConnectUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        viewModel.loadSavedInfo()
        viewModel.loginIfNeeded()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardNotification()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardNotification()
    }
    
    private func setupUI() {
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
    }
    
    private func connect() {
        view.endEditing(true)
        
        viewModel.login(
            userId: loginView.userId,
            nickname: loginView.nickname
        )
    }
    
}


// MARK: - LoginViewModelDelegate

extension LoginViewController: LoginViewModelDelegate {
    
    func loginViewModelDidLoadSavedInfo(_ viewModel: LoginViewModel, userId: String?, nickname: String?, versionInfo: String?) {
        loginView.userId = userId
        loginView.nickname = nickname
        loginView.versionInfo = versionInfo
    }
    
    func loginViewModelUpdateUIForNormal(_ viewModel: LoginViewModel) {
        loginView.updateUIForConnectiong(isConnecting: false)
    }
    
    func loginViewModelUpdateUIForConnectiong(_ viewModel: LoginViewModel) {
        loginView.updateUIForConnectiong(isConnecting: true)
    }
    
    func loginViewModel(_ viewModel: LoginViewModel, didConnect user: SBDUser) {
        didConnectUser(user)
    }
    
    func loginViewModel(_ viewModel: LoginViewModel, didReceive error: SBDError) {
        showAlertController(error: error)
    }
    
    func loginViewModelShowAlert(_ viewModel: LoginViewModel, title: String, message: String) {
        showAlertController(title: title, message: message)
    }
    
}

// MARK: - Keyboard

extension LoginViewController {
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
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
