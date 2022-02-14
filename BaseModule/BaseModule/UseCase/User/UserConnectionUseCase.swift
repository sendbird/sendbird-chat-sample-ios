//
//  UserConnection.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import Foundation
import SendBirdSDK

public class UserConnectionUseCase {
    
    public static let shared = UserConnectionUseCase()
    
    @UserDefault(key: "sendbird_auto_login", defaultValue: false)
    public private(set) var isAutoLogin: Bool
    
    @UserDefault(key: "sendbird_user_id", defaultValue: nil)
    public private(set) var userId: String?
    
    @UserDefault(key: "sendbird_user_nickname", defaultValue: nil)
    public private(set) var userNickname: String?
    
    public var currentUser: SBDUser? {
        SBDMain.getCurrentUser()
    }
        
    private init() { }
    
    public func login(userId: String,
                      nickname: String,
                      completion: @escaping (Result<SBDUser, SBDError>) -> Void) {
        SBDMain.connect(withUserId: userId) { [weak self] user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = user else { return }
            
            self?.registerPushTokenIfNeeded()
            self?.updateNicknameIfNeeded(nickname: nickname, user: user, completion: completion)
        }
    }
    
    public func logout(completion: @escaping () -> Void) {
        SBDMain.disconnect { [weak self] in
            self?.isAutoLogin = false
            completion()
        }
    }
    
    public func updateUserInfo(nickname: String?, profileImage: Data?, completion: @escaping (Result<Void, SBDError>) -> Void){
        SBDMain.updateCurrentUserInfo(withNickname: nickname, profileImage: profileImage) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    private func registerPushTokenIfNeeded() {
        guard let pushToken = SBDMain.getPendingPushToken() else {
            return
        }
        
        SBDMain.registerDevicePushToken(pushToken, unique: true) { status, error in
            if let error = error {
                print("APNS registration failed. \(error)")
                return
            }
            
            if status == .pending {
                print("Push registration is pending.")
            } else {
                print("APNS Token is registered.")
            }
        }
    }
    
    private func updateNicknameIfNeeded(nickname: String,
                                        user: SBDUser,
                                        completion: @escaping (Result<SBDUser, SBDError>) -> Void) {
        if nickname == user.nickname {
            storeUserInfo(user)
            completion(.success(user))
        } else {
            updateUserInfo(nickname: nickname, profileImage: nil) { [weak self] result in
                self?.storeUserInfo(user)
                completion(result.map { _ in user })
            }
        }
    }
    
    private func storeUserInfo(_ user: SBDUser) {
        userId = user.userId
        userNickname = user.nickname
        isAutoLogin = true
    }
            
}
