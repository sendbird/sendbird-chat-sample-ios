//
//  LoginViewModel.swift
//  Common
//
//  Created by Ernest Hong on 2022/01/27.
//

import Foundation
import SendBirdSDK

protocol LoginViewModelDelegate: AnyObject {
    func loginViewModelDidLoadSavedInfo(_ viewModel: LoginViewModel, userId: String?, nickname: String?, versionInfo: String?)
    func loginViewModelUpdateUIForNormal(_ viewModel: LoginViewModel)
    func loginViewModelUpdateUIForConnectiong(_ viewModel: LoginViewModel)
    func loginViewModel(_ viewModel: LoginViewModel, didConnect user: SBDUser)
    func loginViewModel(_ viewModel: LoginViewModel, didReceive error: SBDError)
    func loginViewModelShowAlert(_ viewModel: LoginViewModel, title: String, message: String)
}

final class LoginViewModel {
    
    weak var delegate: LoginViewModelDelegate?
    
    func loadSavedInfo() {
        delegate?.loginViewModelDidLoadSavedInfo(
            self,
            userId: SampleUserDefaults.userId,
            nickname: SampleUserDefaults.nickname,
            versionInfo: VersionInfo.description
        )
    }
    
    func loginIfNeeded() {
        guard
            SampleUserDefaults.isAutoLogin,
            let userId = SampleUserDefaults.userId,
            let nickname = SampleUserDefaults.nickname
        else { return }
        
        login(userId: userId, nickname: nickname)
    }
    
    func login(userId: String?, nickname: String?) {
        if SBDMain.getConnectState() == .open {
            SBDMain.disconnect { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.loginViewModelUpdateUIForNormal(self)
                }
            }
        } else {
            guard let userId = userId?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                  let nickname = nickname?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
                      delegate?.loginViewModelShowAlert(self, title: "Error", message: "User ID and Nickname are required.")
                return
            }
            
            SampleUserDefaults.userId = userId
            SampleUserDefaults.nickname = nickname
            
            delegate?.loginViewModelUpdateUIForConnectiong(self)
            
            ConnectionManager.login(userId: userId, nickname: nickname) { [weak self] user, error in
                if let error = error {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.delegate?.loginViewModelUpdateUIForNormal(self)
                    }
                    
                    guard let self = self else { return }
                    self.delegate?.loginViewModel(self, didReceive: error)
                    return
                }
                
                guard let user = user else { return }
                
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.delegate?.loginViewModelUpdateUIForNormal(self)
                    self.delegate?.loginViewModel(self, didConnect: user)
                }
            }
        }
    }
    
}
