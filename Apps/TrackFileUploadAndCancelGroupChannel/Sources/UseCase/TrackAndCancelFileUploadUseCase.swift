//
//  TrackAndCancelFileUploadUseCase.swift
//  TrackFileUploadAndCancelGroupChannel
//
//  Created by Yogesh Veeraraj on 10.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import CommonModule

protocol TrackAndCancelFileUploadUseCaseDelegate: AnyObject {
    func trackAndCancelFileUploadUseCase(
        _ usecase: TrackAndCancelFileUploadUseCase,
        willUploadMessage message: FileMessage?
    )
    func trackAndCancelFileUploadUseCase(
        _ usecase: TrackAndCancelFileUploadUseCase,
        didSuccessUploadMessage message: FileMessage
    )
    func trackAndCancelFileUploadUseCase(
        _ usecase: TrackAndCancelFileUploadUseCase,
        didFailedUploadMessage error: SBError
    )
    func trackAndCancelFileUploadUseCase(
        _ usecase: TrackAndCancelFileUploadUseCase,
        fileProgress progress: Float
    )
}

class TrackAndCancelFileUploadUseCase: GroupChannelFileMessageUseCase {
    
    weak var delegate: TrackAndCancelFileUploadUseCaseDelegate?
    
    var currentFileMessage: FileMessage?
    
    override func sendFile(_ mediaFile: GroupChannelFileMessageUseCase.MediaFile, completion: @escaping (Result<FileMessage, SBError>) -> Void) -> FileMessage? {
        let fileMessageParams = FileMessageCreateParams(file: mediaFile.data)
        
        fileMessageParams.fileName = mediaFile.name
        fileMessageParams.fileSize = UInt(mediaFile.data.count)
        fileMessageParams.mimeType = mediaFile.mimeType
        fileMessageParams.thumbnailSizes = [.make(maxWidth: 320.0, maxHeight: 320.0)]
        
        currentFileMessage = channel.sendFileMessage(params: fileMessageParams) { [weak self] requestID, bytesSent, totalBytesSent, totalBytesExpectedToSend in
            guard let self = self else { return }
            let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            self.delegate?.trackAndCancelFileUploadUseCase(self, fileProgress: uploadProgress)

        } completionHandler: { [weak self] message, error in
            if let error = error, let self = self {
                self.delegate?.trackAndCancelFileUploadUseCase(self, didFailedUploadMessage: error)
                completion(.failure(error))
                return
            }
            
            guard let message = message, let self = self else { return }
            
            self.cachedDatasForResending.removeValue(forKey: message.requestID)
            
            completion(.success(message))
            
            self.delegate?.trackAndCancelFileUploadUseCase(self, didSuccessUploadMessage: message)
        }
        
        if let requestID = currentFileMessage?.requestID {
            cachedDatasForResending[requestID] = mediaFile.data
        }
        self.delegate?.trackAndCancelFileUploadUseCase(self, willUploadMessage: currentFileMessage)
        return currentFileMessage
    }
    
    func cancelUpload() {
        guard let requestId = currentFileMessage?.requestID else {
            return
        }
        GroupChannel.cancelUploadingFileMessage(requestID: requestId) { result, error in
            // Handle error and success
        }
    }
}
