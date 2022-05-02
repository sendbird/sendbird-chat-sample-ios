//
//  ReportMessageUserUseCase.swift
//  ReportMessageUserOpenChannel
//
//  Created by Yogesh Veeraraj on 28.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol ReportMessageUserUseCaseDelegate: AnyObject {
    func reportMessageUserUseCase(
        _ useCase: ReportMessageUserUseCase,
        didSuccessReporting message: BaseMessage
    )
    
    func reportMessageUserUseCase(
        _ useCase: ReportMessageUserUseCase,
        didFailedReporting error: SBError
    )
    
    func reportMessageUserUseCase(
        _ useCase: ReportMessageUserUseCase,
        didSuccessReporting user: User
    )
    
    func reportMessageUserUseCase(
        _ useCase: ReportMessageUserUseCase,
        didSuccessReporting channel: GroupChannel
    )
}


final class ReportMessageUserUseCase {
    
    private let channel: GroupChannel
    
    weak var delegate: ReportMessageUserUseCaseDelegate?
    
    init(channel: GroupChannel) {
        self.channel = channel
    }
    
    func reportMessage(_ message: BaseMessage) {
        channel.report(message: message, reportCategory: .spam, reportDescription: "Message contains spamming information") { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.delegate?.reportMessageUserUseCase(self, didFailedReporting: error)
            } else {
                self.delegate?.reportMessageUserUseCase(self, didSuccessReporting: message)
            }
        }
    }
    
    func reportUser(_ user: User) {
        channel.report(offendingUser: user, reportCategory: .harassing, reportDescription: "User is abusive") { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.delegate?.reportMessageUserUseCase(self, didFailedReporting: error)
            } else {
                self.delegate?.reportMessageUserUseCase(self, didSuccessReporting: user)
            }
        }
    }
    
    func reportChannel() {
        channel.report(category: .suspicious, reportDescription: "Suspicious", completionHandler: { [weak self] error in
            guard let self = self else {
                return
            }
            if let error = error {
                self.delegate?.reportMessageUserUseCase(self, didFailedReporting: error)
            } else {
                self.delegate?.reportMessageUserUseCase(self, didSuccessReporting: self.channel)
            }
        })
    }

}
