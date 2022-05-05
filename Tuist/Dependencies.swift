//
//  Dependencies.swift
//  Config
//
//  Created by Ernest Hong on 2022/03/15.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/sendbird/sendbird-chat-sdk-ios", requirement: .upToNextMinor(from: "4.0.0-beta.3")),
        .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMajor(from: "7.2.0")),
    ],
    platforms: [.iOS]
)
