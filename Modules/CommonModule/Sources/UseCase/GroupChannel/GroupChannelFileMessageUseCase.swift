//
//  GroupChannelFileMessageUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendbirdChatSDK

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
    
    private let channel: GroupChannel
    
    private var cachedDatasForResending: [String: Data] = [:]
    
    public init(channel: GroupChannel) {
        self.channel = channel
    }

    open func sendFile(_ mediaFile: MediaFile, completion: @escaping (Result<FileMessage, SBError>) -> Void) -> FileMessage? {
        let fileMessageParams = FileMessageCreateParams(file: mediaFile.data)
        
        fileMessageParams.fileName = mediaFile.name
        fileMessageParams.fileSize = UInt(mediaFile.data.count)
        fileMessageParams.mimeType = mediaFile.mimeType
        fileMessageParams.thumbnailSizes = [.make(maxWidth: 320.0, maxHeight: 320.0)]

        let fileMessage = channel.sendFileMessage(params: fileMessageParams) { [weak self] message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            if let requestId = message.requestId {
                self?.cachedDatasForResending.removeValue(forKey: requestId)
            }
            
            completion(.success(message))
        }
        
        if let requestId = fileMessage?.requestId {
            cachedDatasForResending[requestId] = mediaFile.data
        }
        
        return fileMessage
    }
    
    open func resendMessage(_ message: FileMessage, completion: @escaping (Result<BaseMessage, SBError>) -> Void) {
        guard let requestId = message.requestId,
                  let binaryData = cachedDatasForResending[requestId] else { return }
        
        channel.resendFileMessage(message, binaryData: binaryData) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }

}
