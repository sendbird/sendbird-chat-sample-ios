# SendBird Chat SDK Sample for iOS
This repository provides feature-level Chat samples with Swift

## Get started

You must use [tuist](https://github.com/tuist/tuist) to build these sample apps.

### Install tuist
```bash
curl -Ls https://install.tuist.io | bash
```

### Generate Xcode project & workspace
```bash
tuist fetch
tuist generate
```

For more details: [Tuist Docs](https://docs.tuist.io/tutorial/get-started)

## 🏗 Project structure

```
.
├── Project.swift
├── Targets
│   ├── CommonModule
│   ├── BasicGroupChannel
│   ├── BasicOpenChannel
│   ├── GroupChannelFeatureA
│   ├── OpenChannelFeatureA
│   ├── ...
│   ├── GroupChannelFeatureN
│   └── OpenChannelFeatureN
└── Tuist
    ├── Config.swift
    ├── Dependencies.swift
    └── ProjectDescriptionHelpers
```

![image](https://user-images.githubusercontent.com/11647461/156985707-e504f40d-11ce-402e-8038-b13f90ee5db6.png)
Design considerations (Korean): [Link](https://medium.com/@hongseongho/%EA%B8%B0%EB%8A%A5-%EB%8B%A8%EC%9C%84%EB%A1%9C-%ED%99%95%EC%9E%A5-%EA%B0%80%EB%8A%A5%ED%95%9C-%EC%83%98%ED%94%8C-%EC%95%B1-%EB%A7%8C%EB%93%A4%EA%B8%B0-a5fd35ac5ca0)


### [CommonModule](https://github.com/sendbird/examples-chat-ios/tree/main/CommonModule/CommonModule)

- [UseCase](https://github.com/sendbird/examples-chat-ios/tree/main/CommonModule/CommonModule/UseCase): Objects that can be conceptually bundled and used in SendbirdSDK.
  - For example, when implementing the chat room message list, the functions to initialize the list, get the previous message, and get the next message are mostly used together.
  - So, even if it is not divided into screen units, things that can be grouped with a similar concept are grouped with UseCase.
  - If necessary, change the Access Control of BaseModule to open and use it.
- [View](https://github.com/sendbird/examples-chat-ios/tree/main/CommonModule/CommonModule/View)
  - Small Views that can be easily modularized
  - It is recommended to collect all Views that are used for both Group Channel and Open Channel here.
- `CommonModule` is used as an embedded framework in each Sample App.

### BasicSample
- BasicGroupChannel
- BasicOpenChannel

### FeatureSample
- GroupChannelFeatureA, B, …, N: Implement additional functions after cloning the BasicGroupChannel folder.
- OpenChannelFeatureA, B, …, N: Implement additional functions after cloning the BasicOpenChannel folder.
- Implement additional functions after cloning the Basic Sample project. 
- If you want to add a function to an existing UseCase, you can add the function through inheritance.
- Please place the feature use case file that inherits the basic use case under FeatureSample.
- Views used only in features can also be implemented under the feature project.

## 📲 How to add new feature sample with tuist
1. Copy [Targets/BasicGroupChannel](Targets/BasicGroupChannel) or [Targets/BasicOpenChannel](Targets/BasicOpenChannel)
2. Paste under [Targets](Targets) folder.
3. Rename `BasicGroupChannel` to `{FeatureSampleName}`
4. Add `{FeatureSampleName}` to `names` parameter in [Project.swift](Project.swift)
  ```swift
  let project = Project.app(
    names: ["BasicGroupChannel", "BasicOpenChannel", "{FeatureSampleName}"],
    platform: .iOS
  )
  ```
5. Re-generate Xcode project & workspace
  ```
  tuist generate
  ```

## ⛓ Constraints

- Minimum deployment target: 13.0
