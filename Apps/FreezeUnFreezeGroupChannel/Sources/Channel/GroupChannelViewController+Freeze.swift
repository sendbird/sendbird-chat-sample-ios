//
//  GroupChannelViewController+Freeze.swift
//  FreezeUnFreezeGroupChannel
//
//  Created by Yogesh Veeraraj on 08.04.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import UIKit

extension GroupChannelViewController {
    func freezeChannel() {
        channel.freeze { [weak self] error in
            guard let sbError = error else {
                self?.presentAlert(title: "Freeze Channel", message: "Success", closeHandler: nil)
                return
            }
            self?.presentAlert(error: sbError)
        }
    }
    
    func unFreezeChannel() {
        channel.unfreeze { [weak self] error in
            guard let sbError = error else {
                self?.presentAlert(title: "UnFreeze Channel", message: "Success", closeHandler: nil)
                return
            }
            self?.presentAlert(error: sbError)
        }
    }

}
