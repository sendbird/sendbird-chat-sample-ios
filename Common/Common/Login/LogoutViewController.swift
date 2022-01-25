//
//  LogoutViewController.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/25.
//

import UIKit

public final class LogoutViewController: UIViewController {
    
    private lazy var logoutButton: UIButton = {
        let logoutButton: UIButton = UIButton()
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.label, for: .normal)
        logoutButton.addTarget(self, action: #selector(didTouchLogoutButton), for: .touchUpInside)
        return logoutButton
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc private func didTouchLogoutButton() {
        ConnectionManager.logout { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
}
