# examples-chat-ios
This repository provides feature-level Chat samples with Swift

Design considerations (Korean): [기능 단위로 확장 가능한 샘플 앱 만들기](https://medium.com/@hongseongho/%EA%B8%B0%EB%8A%A5-%EB%8B%A8%EC%9C%84%EB%A1%9C-%ED%99%95%EC%9E%A5-%EA%B0%80%EB%8A%A5%ED%95%9C-%EC%83%98%ED%94%8C-%EC%95%B1-%EB%A7%8C%EB%93%A4%EA%B8%B0-a5fd35ac5ca0)

## 🏗 Project structure

When the Feature Sample was added, the `GroupChannel` and `OpenChannel` workspaces were separated to make it easier to distinguish between GroupChannel and OpenChannel.

![image](https://user-images.githubusercontent.com/11647461/156985707-e504f40d-11ce-402e-8038-b13f90ee5db6.png)


### CommonModule

- UseCase: Objects that can be conceptually bundled and used in SendbirdSDK.
  - For example, when implementing the chat room message list, the functions to initialize the list, get the previous message, and get the next message are mostly used together.
  - So, even if it is not divided into screen units, things that can be grouped with a similar concept are grouped with UseCase.
  - If necessary, change the Access Control of BaseModule to open and use it.
- View
  - Small Views that can be easily modularized
  - It is recommended to collect all Views that are used for both Group Channel and Open Channel here.
- `CommonModule` is used as an embedded framework in each Sample App.
  - If you embed the framework and use it, you can quickly understand the changes in BaseModule in the Sample App.
  - I have connected the SendbirdSDK to the CommonModule as SPM. So you can manage your version of SendbirdSDK in one place.


### OpenChannel

`OpenChannel.xcworkspace`
- CommonModule
- BasicGroupChannel
- GroupChannelFeatureA, B, …, N: Implement additional functions after cloning the BasicGroupChannel project.

### GroupChannel

`GroupChannel.xcworkspace`
- CommonModule
- BasicGroupChannel
- GroupChannelFeatureA, B, …, N: Implement additional functions after cloning the BasicGroupChannel project.

## Feature Project 관리
- Implement additional functions after cloning the Basic Sample project. It is recommended to refer to [How to clone the Basic Sample App](https://sendbird.atlassian.net/wiki/spaces/SDK/pages/1771243091/How+to+clone+the+Basic+Sample+App)
- If you want to add a function to an existing UseCase, you can add the function through inheritance.
- Please place the feature use case file that inherits the basic use case under FeatureSample.
- Views used only in features can also be implemented under the feature project.

## ⛓ Constraints

- Minimum deployment target: 13.0
