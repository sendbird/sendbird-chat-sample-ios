# [Sendbird Chat](https://sendbird.com/docs/chat) SDK Sample for iOS

[![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)](https://github.com/sendbird/sendbird-chat-sample-ios)
[![Language](https://img.shields.io/badge/Language-Swift-orange.svg)](https://github.com/sendbird/sendbird-chat-sample-ios)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tuist - Build](https://github.com/sendbird/sendbird-chat-sample-ios/actions/workflows/tuist-build.yml/badge.svg)](https://github.com/sendbird/sendbird-chat-sample-ios/actions/workflows/tuist-build.yml)

This repository provides feature-level Chat samples with Swift.

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

### Execute sample apps

1. Execute `Samples.xcworkspace`.
2. Select the scheme of the feature you want to test.
3. Run the scheme.

## 🏗 Project structure

```
.
├── Samples.xcworkspace
├── Modules
│   ├── CommonModule # Common Logic & View
│   ├── External # External Libraries
│   └── Internal # Sendbird SDK
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

![image](https://user-images.githubusercontent.com/11647461/156985707-e504f40d-11ce-402e-8038-b13f90ee5db6.png)
Design considerations (Korean): [Link](https://medium.com/@hongseongho/%EA%B8%B0%EB%8A%A5-%EB%8B%A8%EC%9C%84%EB%A1%9C-%ED%99%95%EC%9E%A5-%EA%B0%80%EB%8A%A5%ED%95%9C-%EC%83%98%ED%94%8C-%EC%95%B1-%EB%A7%8C%EB%93%A4%EA%B8%B0-a5fd35ac5ca0)


### [CommonModule](Modules/CommonModule)

- [UseCase](Modules/CommonModule/Sources/UseCase): Objects that can be conceptually bundled and used in SendbirdSDK.
  - For example, when implementing the chat room message list, the functions to initialize the list, get the previous message, and get the next message are mostly used together.
  - So, even if it is not divided into screen units, things that can be grouped with a similar concept are grouped with UseCase.
  - If necessary, change the Access Control of BaseModule to open and use it.
- [View](Modules/CommonModule/Sources/UseCase)
  - Small Views that can be easily modularized
  - It is recommended to collect all Views that are used for both Group Channel and Open Channel here.
- `CommonModule` is used as an embedded framework in each Sample App.

### BasicSample
- [BasicGroupChannel](Apps/BasicGroupChannel)
- [BasicOpenChannel](Apps/BasicOpenChannel)

### FeatureSamples
- GroupChannelFeatureA, B, …, N: Implement additional functions after cloning the BasicGroupChannel folder.
- OpenChannelFeatureA, B, …, N: Implement additional functions after cloning the BasicOpenChannel folder.
- Implement additional functions after cloning the Basic Sample project. 
- If you want to add a function to an existing UseCase, you can add the function through inheritance.
- Please place the feature use case file that inherits the basic use case under FeatureSample.
- Views used only in features can also be implemented under the feature project.

----

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

## ⛓ Constraints

- Minimum deployment target: 13.0

----

# 🦅 For Sendbird Devlopers

- [SDK Debug Tip](Modules/Internal/SendbirdChat-Debug)
