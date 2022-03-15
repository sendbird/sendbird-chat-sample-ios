//
//  SettingViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import CommonModule

public final class SettingViewController: UIViewController {
    
    public init() {
        super.init(nibName: "SettingViewController", bundle: Bundle(for: Self.self))
        title = "Setting"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func didTouchEditUserProfileButton(_ sender: Any) {
        let profileEditViewController = ProfileEditViewController()
        let navigation = UINavigationController(rootViewController: profileEditViewController)
        
        present(navigation, animated: true)
    }
    
    @IBAction private func didTouchLogoutButton(_ sender: UIButton) {
        UserConnectionUseCase.shared.logout { [weak self] in
            self?.dismiss(animated: true)
        }
    }
        
}
