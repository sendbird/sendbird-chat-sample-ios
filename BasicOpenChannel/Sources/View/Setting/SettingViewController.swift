//
//  SettingViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit

public final class SettingViewController: UIViewController {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var editUserProfileButton: UIButton = {
        let editUserProfileButton = UIButton(frame: .zero)
        editUserProfileButton.addTarget(self, action: #selector(didTouchEditUserProfileButton(_:)), for: .touchUpInside)
        editUserProfileButton.setTitle("Edit User Profile", for: .normal)
        editUserProfileButton.setTitleColor(.systemBlue, for: .normal)
        return editUserProfileButton
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton(frame: .zero)
        logoutButton.addTarget(self, action: #selector(didTouchLogoutButton(_:)), for: .touchUpInside)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        return logoutButton
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Setting"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        stackView.addArrangedSubview(editUserProfileButton)
        stackView.addArrangedSubview(logoutButton)
    }
    
    @objc private func didTouchEditUserProfileButton(_ sender: Any) {
        let profileEditViewController = ProfileEditViewController()
        let navigation = UINavigationController(rootViewController: profileEditViewController)
        
        present(navigation, animated: true)
    }
    
    @objc private func didTouchLogoutButton(_ sender: UIButton) {
        UserConnectionUseCase.shared.logout { [weak self] in
            self?.dismiss(animated: true)
        }
    }
        
}
