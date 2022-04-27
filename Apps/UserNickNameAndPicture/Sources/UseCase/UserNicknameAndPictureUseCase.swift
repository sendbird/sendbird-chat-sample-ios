//
//  UserNicknameAndPictureUseCase.swift
//  UserNickName
//
//  Created by Yogesh Veeraraj on 27.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class UserNicknameAndPictureUseCase {
    
    var currentUser: User? {
        SendbirdChat.getCurrentUser()
    }
        
    init() { }
    
    func updateUserInfo(nickname: String?, profileImage: Data?, completion: @escaping (Result<Void, SBError>) -> Void) {
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
}
