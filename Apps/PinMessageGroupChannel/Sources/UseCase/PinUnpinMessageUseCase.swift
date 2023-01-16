//
//  PinUnpinMessageUseCase.swift
//  PinMessageGroupChannel
//
//  Copyright © 2023 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

class PinUnpinMessageUseCase{
    private let channel:GroupChannel
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func pinMessage(messageId:Int64){
        channel.pinMessage(messageId: messageId, completionHandler: {error in
            
        })
    }
}
