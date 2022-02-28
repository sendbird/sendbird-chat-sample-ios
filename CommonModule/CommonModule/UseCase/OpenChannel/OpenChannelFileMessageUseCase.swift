//
//  OpenChannelFileMessageUseCase.swift
//  CommonModule
//
//  Created by Ernest Hong on 2022/02/11.
//

import Foundation
import SendBirdSDK

public class OpenChannelFileMessageUseCase {
    
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
    
    private let channel: SBDOpenChannel
    
    public init(channel: SBDOpenChannel) {
        self.channel = channel
    }

    public func sendFile(_ mediaFile: MediaFile, completion: @escaping (Result<SBDBaseMessage, SBDError>) -> Void) -> SBDFileMessage? {
        guard let fileMessageParams = SBDFileMessageParams(file: mediaFile.data) else {
            return nil
        }
        
        fileMessageParams.fileName = mediaFile.name
        fileMessageParams.fileSize = UInt(mediaFile.data.count)
        fileMessageParams.mimeType = mediaFile.mimeType
        fileMessageParams.thumbnailSizes = [SBDThumbnailSize.make(withMaxWidth: 320.0, maxHeight: 320.0)]

        return channel.sendFileMessage(with: fileMessageParams) { message, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let message = message else { return }
            
            completion(.success(message))
        }
    }

}
