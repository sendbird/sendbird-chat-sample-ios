//
//  GroupChannelOutgoingCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

public protocol GroupChannelOutgoingCellDelegate: AnyObject {
    func groupChannelOutgoingCell(_ cell: GroupChannelOutgoingCell, didTouchResendButton resendButton: UIButton, forUserMessage message: SBDUserMessage)
    func groupChannelOutgoingCell(_ cell: GroupChannelOutgoingCell, didTouchResendButton resendButton: UIButton, forFileMessage message: SBDFileMessage)
}

public protocol GroupChannelOutgoingCell: AnyObject {
    var delegate: GroupChannelOutgoingCellDelegate? { get set }
}
