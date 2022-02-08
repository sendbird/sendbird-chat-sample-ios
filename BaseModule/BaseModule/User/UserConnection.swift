//
//  UserConnection.swift
//  BaseModule
//
//  Created by Ernest Hong on 2022/02/08.
//

import Foundation
import SendBirdSDK

public class UserConnection {
    
    @UserDefault(key: "sendbird_auto_login", defaultValue: false)
    public private(set) var isAutoLogin: Bool
    
    @UserDefault(key: "sendbird_user_id", defaultValue: nil)
    public private(set) var userId: String?
    
    @UserDefault(key: "sendbird_user_nickname", defaultValue: nil)
    public private(set) var userNickname: String?
    
    public private(set) var doNotDisturbInfo: DoNotDisturbInfo? {
        get {
            doNotDistrubData.flatMap {
                try? JSONDecoder().decode(DoNotDisturbInfo.self, from: $0)
            }
        }
        set {
            doNotDistrubData = newValue.flatMap {
                try? JSONEncoder().encode($0)
            }
        }
    }
    
    @UserDefault(key: "sendbird_do_not_distrub", defaultValue: nil)
    private var doNotDistrubData: Data?
    
    public init() { }
    
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
            self?.storeDoNotDistrubInfo()
            self?.updateNicknameIfNeeded(nickname: nickname, user: user, completion: completion)
        }
    }
    
    public func logout(completion: @escaping () -> Void) {
        SBDMain.disconnect { [weak self] in
            self?.isAutoLogin = false
            self?.doNotDisturbInfo = nil
            completion()
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
            SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil) { [weak self] _ in
                self?.storeUserInfo(user)
                completion(.success(user))
            }
        }
    }
    
    private func storeUserInfo(_ user: SBDUser) {
        userId = user.userId
        userNickname = user.nickname
        isAutoLogin = true
    }
    
    private func storeDoNotDistrubInfo() {
        SBDMain.getDoNotDisturb { [weak self] isDoNotDisturbOn, startHour, startMin, endHour, endMin, timezone, error in
            guard error == nil else {
                self?.doNotDisturbInfo = nil
                return
            }
            
            self?.doNotDisturbInfo = .init(
                startHour: Int(startHour),
                startMin: Int(startMin),
                endHour: Int(endHour),
                endMin: Int(endMin),
                isDoNotDisturbOn: isDoNotDisturbOn
            )
        }
    }
        
}
