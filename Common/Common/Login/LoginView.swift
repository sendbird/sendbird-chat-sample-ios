//
//  LoginView.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import UIKit

final class LoginView: UIView {
    
    typealias EventHandler = () -> Void
    
    var isLogoHidden: Bool {
        get { logoImageView.isHidden }
        set { logoImageView.isHidden = newValue }
    }
    
    var userId: String? {
        get { userIdTextField.text }
        set { userIdTextField.text = newValue }
    }
    
    var nickname: String? {
        get { nicknameTextField.text }
        set { nicknameTextField.text = newValue }
    }
    
    var versionInfo: String? {
        get { versionInfoLabel.text }
        set { versionInfoLabel.text = newValue }
    }
        
    private let onRequestConnect: EventHandler
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView(image: .named("logoSendbird"))
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }()
    
    private lazy var userIdTextField: UnderlineTextField = {
        let userIdTextField = UnderlineTextField()
        userIdTextField.font = .systemFont(ofSize: 24)
        userIdTextField.placeholder = "User ID"
        userIdTextField.minimumFontSize = 17
        userIdTextField.bottomBorderWidth = 1
        userIdTextField.returnKeyType = .next
        return userIdTextField
    }()
    
    private lazy var nicknameTextField: UnderlineTextField = {
        let nicknameTextField = UnderlineTextField()
        nicknameTextField.font = .systemFont(ofSize: 24)
        nicknameTextField.placeholder = "Nickname"
        nicknameTextField.minimumFontSize = 17
        nicknameTextField.bottomBorderWidth = 1
        nicknameTextField.returnKeyType = .done
        return nicknameTextField
    }()
    
    private lazy var connectButton: UIButton = {
        let connectButton = UIButton(type: .custom)
        connectButton.setTitle("Connect", for: .normal)
        connectButton.setTitleColor(.label, for: .normal)
        connectButton.addTarget(self, action: #selector(didTapConnectButton), for: .touchUpInside)
        return connectButton
    }()
    
    private lazy var versionInfoLabel: UILabel = {
        let versionInfoLabel = UILabel()
        versionInfoLabel.text = "Version Info"
        versionInfoLabel.font = .systemFont(ofSize: 13)
        versionInfoLabel.textAlignment = .center
        return versionInfoLabel
    }()
        
    // MARK: - Override
    init(onRequestConnect: @escaping EventHandler) {
        self.onRequestConnect = onRequestConnect
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupUI() {
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        stackView.addArrangedSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 62),
            logoImageView.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        stackView.addArrangedSubview(userIdTextField)
        stackView.addArrangedSubview(nicknameTextField)
        stackView.addArrangedSubview(connectButton)
        stackView.addArrangedSubview(versionInfoLabel)
        
        userIdTextField.delegate = self
        nicknameTextField.delegate = self
        
        let contentViewTapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapContentView))
        isUserInteractionEnabled = true
        addGestureRecognizer(contentViewTapRecognizer)
    }
        
    func updateUIForConnectiong(isConnecting: Bool) {
        if isConnecting {
            self.userIdTextField.isEnabled = false
            self.nicknameTextField.isEnabled = false
            self.connectButton.isEnabled = false
            self.connectButton.setTitle("Connecting...", for: .normal)
        } else {
            self.userIdTextField.isEnabled = true
            self.nicknameTextField.isEnabled = true
            self.connectButton.isEnabled = true
            self.connectButton.setTitle("Connect", for: .normal)
        }
    }
    
    @objc private func didTapConnectButton() {
        onRequestConnect()
    }
    
    @objc private func didTapContentView() {
        endEditing(true)
    }
    
}

// MARK: - UITextFieldDelegate

extension LoginView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.userIdTextField {
            textField.resignFirstResponder()
            self.nicknameTextField.becomeFirstResponder()
        } else {
            self.onRequestConnect()
        }
        
        return true
    }
    
}
