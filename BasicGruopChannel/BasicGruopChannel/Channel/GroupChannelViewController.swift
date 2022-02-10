//
//  GroupChannelViewController.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/09.
//

import UIKit
import SendBirdSDK

class GroupChannelViewController: UIViewController {
    
    private let channel: SBDGroupChannel
    
    init(channel: SBDGroupChannel) {
        self.channel = channel
        super.init(nibName: "GroupChannelViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
