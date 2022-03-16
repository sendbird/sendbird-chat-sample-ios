//
//  GroupChannelFileMessageUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChat

open class GroupChannelFileMessageUseCase {
    
    public struct MediaFile {
        let data: Data
        let name: String
        let mimeType: String
        
        public init(data: Data, name: String, mimeType: String) {
            self.data = data
            self.name = name
            self.mimeType = mimeType
        }
    }
    
    private let channel: SBDGroupChannel
    
    private var cachedDatasForResending: [String: Data] = [:]
    
    public init(channel: SBDGroupChannel) {
        self.channel = channel
    }

    open func sendFile(_ mediaFile: MediaFile, completion: @escaping (Result<FileMessage, SBError>) -> Void) -> FileMessage? {
        guard let fileMessageParams = FileMessageParams(file: mediaFile.data) else {
            return nil
        }
        
        fileMessageParams.fileName = mediaFile.name
        fileMessageParams.fileSize = UInt(mediaFile.data.count)
        fileMessageParams.mimeType = mediaFile.mimeType
        fileMessageParams.thumbnailSizes = [SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)]

        let fileMessage = channel.sendFileMessage(with: fileMessageParams) { [weak self] message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            self?.cachedDatasForResending.removeValue(forKey: message.requestId)
            completion(.success(message))
        }
        
        cachedDatasForResending[fileMessage.requestId] = mediaFile.data
        
        return fileMessage
    }
    
    open func resendMessage(_ message: FileMessage, completion: @escaping (Result<BaseMessage, SBError>) -> Void) {
        channel.resendFileMessage(with: message, binaryData: cachedDatasForResending[message.requestId]) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }

}
