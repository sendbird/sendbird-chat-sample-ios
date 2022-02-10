//
//  SettingViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit

public final class SettingViewController: UIViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        title = "Setting"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        title = "Setting"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTouchLogoutButton(_ sender: UIButton) {
        UserConnection.shared.logout { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
}
