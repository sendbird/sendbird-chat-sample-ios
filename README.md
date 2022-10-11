# [Sendbird Chat](https://sendbird.com/docs/chat) SDK Sample for iOS

[![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)](https://github.com/sendbird/sendbird-chat-sample-ios)
[![Language](https://img.shields.io/badge/Language-Swift-orange.svg)](https://github.com/sendbird/sendbird-chat-sample-ios)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tuist - Build](https://github.com/sendbird/sendbird-chat-sample-ios/actions/workflows/tuist-build.yml/badge.svg)](https://github.com/sendbird/sendbird-chat-sample-ios/actions/workflows/tuist-build.yml)

This repository provides feature-level Chat samples with Swift.

## 🔒 Security tip
When a new Sendbird application is created in the dashboard the default security settings are set permissive to simplify running samples and implementing your first code.

Before launching make sure to review the security tab under ⚙️ Settings -> Security, and set Access token permission to Read Only or Disabled so that unauthenticated users can not login as someone else. And review the Access Control lists. Most apps will want to disable "Allow retrieving user list" as that could expose usage numbers and other information.

## 🚀 Get started

You must use [tuist](https://github.com/tuist/tuist) to build these sample apps.

### 1. Install tuist
```bash
curl -Ls https://install.tuist.io | bash
```

### 2. Install Dependencies
```bash
tuist fetch
```

### 3. Generate Xcode project & workspace
```bash
tuist generate 
```

For more details: [Tuist Docs](https://docs.tuist.io/tutorial/get-started)

### 4. Execute sample apps

1. Execute `Samples.xcworkspace`.
2. Select the scheme of the feature you want to test.
3. Run the scheme.

## 🏗 Project structure

```
.
├── Samples.xcworkspace
├── Modules
│   └── CommonModule # Common Logic & View
├── Apps
│   ├── BasicGroupChannel
│   ├── BasicOpenChannel
│   ├── GroupChannelFeatureA
│   ├── OpenChannelFeatureA
│   ├── ...
│   ├── GroupChannelFeatureN
│   └── OpenChannelFeatureN
└── Tuist
```

### [CommonModule](Modules/CommonModule)

- [UseCase](Modules/CommonModule/Sources/UseCase): Objects that can be conceptually bundled and used in SendbirdSDK.
  - For example, when implementing the chat room message list, the functions to initialize the list, get the previous message, and get the next message are mostly used together.
  - So, even if it is not divided into screen units, things that can be grouped with a similar concept are grouped with UseCase.
  - If necessary, change the Access Control of BaseModule to open and use it.
- [View](Modules/CommonModule/Sources/UseCase)
  - Small Views that can be easily modularized
  - It is recommended to collect all Views that are used for both Group Channel and Open Channel here.
- `CommonModule` is used as an embedded framework in each Sample App.


# 🛠 For contributors
Below is an additional explanation for contributors.

## 📲 How to add new `Feature Sample App` with tuist
1. Copy [Apps/BasicGroupChannel](Apps/BasicGroupChannel) or [Apps/BasicOpenChannel](Apps/BasicOpenChannel)
2. Paste under [Apps](Apps) folder.
3. Rename folder name `BasicGroupChannel` to `{FeatureSampleName}`
4. Rename parameter `"BasicGroupChannel"` to `"{FeatureSampleName}"` in `Apps/{FeatureSampleName}/Project.swift`
```swift
let project = Project.app(name: {FeatureSampleName})
```
5. Re-generate Xcode project & workspace
```
tuist generate
```

## Considerations in real world app
 - In this sample repo users are connecting to sendbird using a user ID (Sendbird Dashboard --> Security --> Read & Write). Read & Write is not secure and will create a new user automatically from the SDK if none exists. In production be sure to change the Sendbird Dashboard security settings to Deny login, and [authenticate users](https://sendbird.com/docs/chat/v4/ios/guides/authentication#2-connect-to-sendbird-server-with-a-user-id-and-an-access-token) with a Sendbird generated Session Token.
