//
//  GroupChannelImageCell.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/23.
//

import UIKit
import SendBirdSDK

public protocol GroupChannelImageCell: UITableViewCell {
    func configure(with message: SBDFileMessage)
}
