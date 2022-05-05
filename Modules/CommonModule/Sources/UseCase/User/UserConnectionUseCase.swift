//
//  UserConnection.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import Foundation
import SendbirdChatSDK

public class UserConnectionUseCase {
    
    public static let shared = UserConnectionUseCase()
    
    @UserDefault(key: "sendbird_auto_login", defaultValue: false)
    public private(set) var isAutoLogin: Bool
    
    @UserDefault(key: "sendbird_user_id", defaultValue: nil)
    public private(set) var userID: String?
    
    public var currentUser: User? {
        SendbirdChat.getCurrentUser()
    }
        
    private init() { }
    
    public func login(userID: String,
                      completion: @escaping (Result<User, SBError>) -> Void) {
        SendbirdChat.connect(userID: userID) { [weak self] user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = user else { return }
            
            self?.registerPushTokenIfNeeded()
            self?.storeUserInfo(user)
            completion(.success(user))
        }
    }
    
    public func logout(completion: @escaping () -> Void) {
        SendbirdChat.disconnect { [weak self] in
            self?.isAutoLogin = false
            completion()
        }
    }
    
    public func updateUserInfo(nickname: String?, profileImage: Data?, completion: @escaping (Result<Void, SBError>) -> Void) {
        let params = UserUpdateParams()
        
        params.nickname = nickname
        params.profileImageData = profileImage
        
        SendbirdChat.updateCurrentUserInfo(params: params, completionHandler:  { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        })
    }
    
    private func registerPushTokenIfNeeded() {
        guard let pushToken = SendbirdChat.getPendingPushToken() else {
            return
        }
        
        SendbirdChat.registerDevicePushToken(pushToken, unique: true) { status, error in
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
        
    private func storeUserInfo(_ user: User) {
        userID = user.userID
        isAutoLogin = true
    }
            
}
