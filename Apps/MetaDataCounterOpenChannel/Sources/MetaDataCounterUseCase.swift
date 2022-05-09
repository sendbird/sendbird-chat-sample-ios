//
//  AddExtraDataToMessageUseCase.swift
//  AddExtraDataMessageOpenChannel
//
//  Created by Yogesh Veeraraj on 04.05.22.
//  Copyright © 2022 Sendbird. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import UIKit

class MetaDataCounterUseCase {
    private let channel: OpenChannel
    
    init(channel: OpenChannel) {
        self.channel = channel
    }
    
    func addMetaData(completion: @escaping (Result<[String: String], SBError>)-> Void) {
        let metaData = ["color": "#0000FF"]
        channel.createMetaData(metaData) { metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = metaData else {
                return
            }
            completion(.success(data))
        }
    }
    
    func updateMetaData(completion: @escaping (Result<[String: String], SBError>)-> Void) {
        let metaData = ["color": "#808080"]
        channel.updateMetaData(metaData) { metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = metaData else {
                return
            }
            completion(.success(data))
        }
    }
    
    func addMetaDataCounter(completion: @escaping (Result<[String: Int], SBError>)-> Void) {
        let counter = ["likes": 1]
        channel.createMetaCounters(counter) { metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = metaData else {
                return
            }
            completion(.success(data))
        }
    }
    
    func increaseMetaDataCounter(completion: @escaping (Result<[String: Int], SBError>)-> Void) {
        let counter = ["likes": 1]
        channel.increaseMetaCounters(counter) { metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = metaData else {
                return
            }
            completion(.success(data))
        }
    }
    
    func getMetaDataCounter(completion: @escaping (Result<[String: Int], SBError>)-> Void)  {
        channel.getAllMetaCounters { metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = metaData else {
                return
            }
            completion(.success(data))
        }
    }
    
    func getMetaData(completion: @escaping (Result<[String: String], SBError>)-> Void) {
        channel.getAllMetaData { metaData, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = metaData else {
                return
            }
            completion(.success(data))
        }
    }
}
