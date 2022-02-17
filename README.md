# examples-chat-ios
[Temporary] This repository provides feature-level Chat samples with Swift

설계 과정: https://medium.com/@hongseongho/%EA%B8%B0%EB%8A%A5-%EB%8B%A8%EC%9C%84%EB%A1%9C-%ED%99%95%EC%9E%A5-%EA%B0%80%EB%8A%A5%ED%95%9C-%EC%83%98%ED%94%8C-%EC%95%B1-%EB%A7%8C%EB%93%A4%EA%B8%B0-a5fd35ac5ca0

## 🏗 Project structure

iOS에서는 Feature Sample이 추가 되었을 때 구분하기 쉽게하기 위해서 GroupChannel, OpenChannel workspace를 분리했습니다.

### CommonModule

- UseCase: SendbirdSDK에서 개념적으로 묶어서 사용할 수 있는 것을 객체화
  - 예를들어 채팅방 메세지 목록 기능을 구현할 때 목록 초기화, 이전 메세지 가져오기, 다음 메세지 가져오기 등은 대부분 함께 사용됩니다.
  - 화면 단위로 나누지 않더라도 비슷한 개념으로 묶을 수 있는 것을 UseCase로 묶어뒀습니다.
  - 필요시 BaseModule의 Access Control 들을 open 으로 변경해서 사용해주세요.
- View
  - Small Views that can be easily modularized
  - Group Channel, Open Channel 모두 다 사용되는 View는 이곳에 모아두는 것을 권장합니다.
- It is used as an embedded framework in each Sample App.
  - framework를 임베딩 시켜서 사용하면 BaseModule의 변화를 Sample App에서 빠르게 파악할 수 있습니다.
  - BaseModule에 Sendbird SDK를 SPM으로 연결해둬서, SendbirdSDK의 버전을 한 곳에서 관리할 수 있습니다.

### OpenChannel

`OpenChannel.xcworkspace`
- CommonModule
- BasicOpenChannel
- OpenChannelFeatureA: BasicOpenChannel project를 복제한 후 추가 기능 구현
- OpenChannelFeatureB
- …
- OpenChannelFeatureN

### GroupChannel

`GroupChannel.xcworkspace`
- CommonModule
- BasicGroupChannel
- GroupChannelFeatureA: BasicGroupChannel project를 복제한 후 추가 기능 구현
- GroupChannelFeatureB
- …
- GroupChannelFeatureN

## Feature Project 관리

- 이미 존재하는 UseCase 에 기능을 추가하고 싶다면, 위임이나 상속을 통해서 기능을 추가할 수 있습니다.
- Feature를 위한 UseCase는 Feature project 아래에 구현하시면 됩니다.
- Feature에서만 사용되는 View도 Feature project 아래에 구현하시면 됩니다. 

## ⛓ Constraints

- Minimum deployment target: 13.0
- Implement UI based on xib or storyboard
- Writing UI with code base can be confusing because it mixes with SDK code
