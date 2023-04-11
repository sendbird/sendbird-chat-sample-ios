//
//  PushNotificationUseCase.swift
//  PushNotificationsGroupChannel
//
//  Created by Yogesh Veeraraj on 02.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class PushNotificationUseCase {
    func registerPushToken(deviceToken: Data) {
        SendbirdChat.registerDevicePushToken(deviceToken, unique: true) { status, error in
            if let error = error {
                print("APNS registration failed. \(error)")
                return
            }
            
            if status == .pending {
                // A token registration is pending.
                // If this status is returned, invoke the registerDevicePushToken:unique:completionHandler:
                // with [SBDMain getPendingPushToken] after connection.
            } else {
                print("APNS Token is registered.")
            }
        }

    }
    
    func setPushNotification(enable: Bool) {
        guard let pushToken = SendbirdChat.getPendingPushToken() else {
            return
        }

        if enable {
            SendbirdChat.registerDevicePushToken(pushToken, unique: true, completionHandler: { (status, error) in
                guard error == nil else {
                    // Handle error.
                    return
                }
            })
        }
        else {
            SendbirdChat.unregisterPushToken(pushToken, completionHandler: { error in
                guard error == nil else {
                    // Handle error.
                    return
                }
            })
        }
    }
    
    func unRegisterAllDevices() {
        SendbirdChat.unregisterAllPushToken(completionHandler: { error in
            guard error == nil else {
                // Handle error.
                return
            }
        })
    }

}
