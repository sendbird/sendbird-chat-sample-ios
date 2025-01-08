//
//  Dependencies.swift
//  Config
//
//  Created by Ernest Hong on 2022/03/15.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/sendbird/sendbird-chat-sdk-ios", requirement: .exact("4.24.1")),
        .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .exact("8.1.0")),
    ],
    platforms: [.iOS]
)
