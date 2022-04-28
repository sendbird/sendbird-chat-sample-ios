//
//  ReportMessageUserUseCase.swift
//  ReportMessageUserOpenChannel
//
//  Created by Yogesh Veeraraj on 28.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

final class DeleteMessageUseCase {
    
    private let channel: OpenChannel
    
    init(channel: OpenChannel) {
        self.channel = channel
    }
}
