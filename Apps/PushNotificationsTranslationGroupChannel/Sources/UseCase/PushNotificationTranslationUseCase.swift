//
//  PushNotificationTranslationUseCase.swift
//  PushNotificationsTranslationGroupChannel
//
//  Created by Yogesh Veeraraj on 02.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class PushNotificationTranslationUseCase {
    
    func updatePreferredLanguages(for user: User, completion: @escaping(Result<Void, SBError>) -> Void) {
        let preferredLanguages = ["fr", "de", "es"]
        
        SendbirdChat.updateCurrentUserInfo(preferredLanguages: preferredLanguages, completionHandler: { error in
            guard error == nil, let languages = user.preferredLanguages else {
                completion(.failure(error!))
                return
            }

            var isUpdatedSuccessfully = true

            for language in languages {
                if !preferredLanguages.contains(language) {
                    isUpdatedSuccessfully = false
                    break
                }
            }

            if isUpdatedSuccessfully == true {
                completion(.success(()))
            }
        })

    }
}
