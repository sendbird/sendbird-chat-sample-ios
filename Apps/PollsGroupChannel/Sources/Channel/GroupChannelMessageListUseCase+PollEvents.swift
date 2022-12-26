//
//  GroupChannelMessageListUseCase+PollEvents.swift
//  PollsGroupChannel
//
//  Created by Mihai Moisanu on 26.12.2022.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import CommonModule

class PollEventsDelegate : GroupChannelDelegate {
    
    init(channel:GroupChannel){
        SendbirdChat.addChannelDelegate(<#T##delegate: BaseChannelDelegate##BaseChannelDelegate#>, identifier: <#T##String#>)
    }
    
    func channel(_ channel: GroupChannel, didUpdatePoll event: PollUpdateEvent){
        
    }
    
    func channel(_ channel: GroupChannel del)
}
