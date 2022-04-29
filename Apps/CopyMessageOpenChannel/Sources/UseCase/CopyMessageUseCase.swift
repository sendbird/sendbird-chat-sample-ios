//
//  CopyMessageUseCase.swift
//  CopyMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 28.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol CopyMessageUseCaseDelegate: AnyObject {
    func copyMessageUseCase(
        _ useCase: CopyMessageUseCase,
        didCopySuccessfully message: BaseMessage?
    )
    
    func copyMessageUseCase(
        _ useCase: CopyMessageUseCase,
        didCopyFailed error: SBError
    )
}


class CopyMessageUseCase {
    
    private let channel: OpenChannel
    
    weak var delegate: CopyMessageUseCaseDelegate?
    
    init(channel: OpenChannel) {
        self.channel = channel
    }

    func copyUserMessage(_ message: UserMessage, toChannel channel: OpenChannel) {
        self.channel.copyUserMessage(message, toTargetChannel: channel) { [weak self] message, error in
            guard let self = self else { return }
            if let error =  error {
                self.delegate?.copyMessageUseCase(self, didCopyFailed: error)
            } else {
                self.delegate?.copyMessageUseCase(self, didCopySuccessfully: message)
            }
        }
    }
    
    func copyFileMessage(_ message: FileMessage, toChannel channel: OpenChannel) {
        self.channel.copyFileMessage(message, toTargetChannel: channel) { [weak self] message, error in
            guard let self = self else { return }
            if let error =  error {
                self.delegate?.copyMessageUseCase(self, didCopyFailed: error)
            } else {
                self.delegate?.copyMessageUseCase(self, didCopySuccessfully: message)
            }
        }
    }

}
