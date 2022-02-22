//
//  GroupChannelViewController+FileMessage.swift
//  BasicGruopChannel
//
//  Created by Ernest Hong on 2022/02/11.
//

import UIKit
import SendBirdSDK
import CommonModule

extension GroupChannelViewController: ImagePickerRouterDelegate {

    func presentAttachFileAlert() {
        imagePickerRouter.presentAlert()
    }
    
    func imagePickerRouter(_ imagePickerRouter: ImagePickerRouter, didFinishPickingMediaFile mediaFile: ImagePickerMediaFile) {
        fileMessageUseCase.sendFile(.init(data: mediaFile.data, name: mediaFile.name, mimeType: mediaFile.mimeType)) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }

}
