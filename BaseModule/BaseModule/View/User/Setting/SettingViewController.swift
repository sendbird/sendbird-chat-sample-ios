//
//  SettingViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit

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
    
    @IBAction func didTouchLogoutButton(_ sender: UIButton) {
        UserConnectionUseCase.shared.logout { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
}
