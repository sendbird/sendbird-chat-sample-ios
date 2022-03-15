//
//  Dependencies.swift
//  Config
//
//  Created by Ernest Hong on 2022/03/15.
//

import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/sendbird/sendbird-chat-ios-spm", requirement: .upToNextMajor(from: "3.1.7")),
        .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMajor(from: "7.0.0")),
    ],
    platforms: [.iOS]
)
