//
//  ConnectionManager.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by sendbird-young on 2018. 4. 11..
//  Copyright © 2018년 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

public protocol ConnectionManagerDelegate: AnyObject {
    func didConnect(isReconnection: Bool)
    func didDisconnect()
}

public class ConnectionManager: NSObject, SBDConnectionDelegate {
    
    private enum Constant {
        static let errorDomainConnection = "com.sendbird.sample.connection"
    }
    
    static let shared = ConnectionManager()
    static var stopConnectionRetry: Bool = false
    
    private var observers: NSMapTable<NSString, AnyObject> = NSMapTable(keyOptions: .copyIn, valueOptions: .weakMemory)
    
    private override init() {
        super.init()
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
    }
    
    deinit {
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    static public func startLogin(){
        login { (user, error) in
            if stopConnectionRetry {
                return
            }
            if error != nil {
                return self.showAlert()
            }
            let alert = UIAlertController(title: "Login Success", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            let topVC = UIApplication.shared.keyWindow?.rootViewController
            if topVC?.presentedViewController == nil {
                topVC?.present(alert, animated: true, completion: nil)
            } else {
                topVC?.presentedViewController?.present(alert, animated: true, completion: nil)
            }
            return
        }
    }
    
    static public func showAlert() {
        let alert = UIAlertController(title: "Login Failure", message: "Login Again?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action) in
            self.startLogin()
        }))
        alert.addAction(UIAlertAction(title: "Retry in 5 sec", style: .default, handler: { (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.startLogin()
            })
        }))
        
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        if topVC?.presentedViewController == nil {
            topVC?.present(alert, animated: true, completion: nil)
        } else {
            topVC?.presentedViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    static public func login(completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        let userDefault = UserDefaults.standard
        let userId: String? = userDefault.value(forKey: "sendbird_user_id") as? String
        let userNickname: String? = userDefault.value(forKey: "sendbird_user_nickname") as? String
        
        guard let theUserId: String = userId, let theNickname: String = userNickname else {
            if let handler: ((_ :SBDUser?, _ :NSError?) -> ()) = completionHandler {
                let error: NSError = NSError(domain: Constant.errorDomainConnection, code: -1, userInfo: [NSLocalizedDescriptionKey:"User id or user nickname is nil.",NSLocalizedFailureReasonErrorKey:"Saved user data does not exist."])
                handler(nil, error)
            }
            return
        }
        
        self.login(userId: theUserId, nickname: theNickname, completionHandler: completionHandler)
    }
    
    static public func login(userId: String, nickname: String, completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        self.shared.login(userId: userId, nickname: nickname, completionHandler: completionHandler)
    }
    
    private func login(userId: String, nickname: String, completionHandler: ((_ user: SBDUser?, _ error: NSError?) -> Void)?) {
        SBDMain.connect(withUserId: userId) { (user, error) in
            let userDefault = UserDefaults.standard
            
            if let theError: NSError = error {
                if let handler = completionHandler {
                    var userInfo: [String: Any] = Dictionary()
                    if let reason: String = theError.localizedFailureReason {
                        userInfo[NSLocalizedFailureReasonErrorKey] = reason
                    }
                    userInfo[NSLocalizedDescriptionKey] = theError.localizedDescription
                    userInfo[NSUnderlyingErrorKey] = theError
                    let connectionError: NSError = NSError.init(domain: Constant.errorDomainConnection, code: theError.code, userInfo: userInfo)
                    handler(nil, connectionError)
                }
                return
            }
            
            if let pushToken: Data = SBDMain.getPendingPushToken() {
                SBDMain.registerDevicePushToken(pushToken, unique: true, completionHandler: { (status, error) in
                    guard let _: SBDError = error else {
                        print("APNS registration failed.")
                        return
                    }
                    
                    if status == .pending {
                        print("Push registration is pending.")
                    }
                    else {
                        print("APNS Token is registered.")
                    }
                })
            }
            
            self.broadcastConnection(isReconnection: false)
            
            SBDMain.getDoNotDisturb { (isDoNotDisturbOn, startHour, startMin, endHour, endMin, timezone, error) in
                UserDefaults.standard.set(startHour, forKey: "sendbird_dnd_start_hour")
                UserDefaults.standard.set(startMin, forKey: "sendbird_dnd_start_min")
                UserDefaults.standard.set(endHour, forKey: "sendbird_dnd_end_hour")
                UserDefaults.standard.set(endMin, forKey: "sendbird_dnd_end_min")
                UserDefaults.standard.set(isDoNotDisturbOn, forKey: "sendbird_dnd_on")
                UserDefaults.standard.synchronize()
            }
            
            if nickname != SBDMain.getCurrentUser()?.nickname {
                SBDMain.updateCurrentUserInfo(withNickname: nickname, profileUrl: nil, completionHandler: { (error) in
                    completionHandler?(user, nil)
                })
            } else {
                completionHandler?(user, nil)
            }
            
            userDefault.setValue(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
            userDefault.setValue(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_user_nickname")
            userDefault.setValue(true, forKey: "sendbird_auto_login")
        }
    }
    
    static public func logout(completionHandler: (() -> Void)? = nil) {
        self.shared.logout(completionHandler: completionHandler)
    }
    
    private func logout(completionHandler: (() -> Void)?) {
        SBDMain.disconnect {
            self.broadcastDisconnection()
            let userDefault = UserDefaults.standard
            userDefault.setValue(false, forKey: "sendbird_auto_login")
            userDefault.removeObject(forKey: "sendbird_dnd_start_hour")
            userDefault.removeObject(forKey: "sendbird_dnd_start_min")
            userDefault.removeObject(forKey: "sendbird_dnd_end_hour")
            userDefault.removeObject(forKey: "sendbird_dnd_end_min")
            userDefault.removeObject(forKey: "sendbird_dnd_on")
            userDefault.synchronize()
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            if let handler: () -> Void = completionHandler {
                handler()
            }
        }
    }
    
    static public func add(connectionObserver: ConnectionManagerDelegate) {
        self.shared.observers.setObject(connectionObserver as AnyObject, forKey:self.instanceIdentifier(instance: connectionObserver))
        if SBDMain.getConnectState() == .open {
            connectionObserver.didConnect(isReconnection: false)
        }
        else if SBDMain.getConnectState() == .closed {
            self.login(completionHandler: nil)
        }
    }
    
    static public func remove(connectionObserver: ConnectionManagerDelegate) {
        let observerIdentifier: NSString = self.instanceIdentifier(instance: connectionObserver)
        self.shared.observers.removeObject(forKey: observerIdentifier)
    }
    
    private func broadcastConnection(isReconnection: Bool) {
        let enumerator: NSEnumerator? = self.observers.objectEnumerator()
        while let observer = enumerator?.nextObject() as! ConnectionManagerDelegate? {
            observer.didConnect(isReconnection: isReconnection)
        }
    }
    
    private func broadcastDisconnection() {
        let enumerator: NSEnumerator? = self.observers.objectEnumerator()
        while let observer = enumerator?.nextObject() as! ConnectionManagerDelegate? {
            observer.didDisconnect()
        }
    }
    
    static private func instanceIdentifier(instance: Any) -> NSString {
        return NSString(format: "%zd", self.hash())
    }
    
    public func didStartReconnection() {
        self.broadcastDisconnection()
    }
    
    public func didSucceedReconnection() {
        self.broadcastConnection(isReconnection: true)
    }
    
    public func didFailReconnection() {
        //
    }
    
    public func didCancelReconnection() {
        //
    }
}
