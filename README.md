# examples-chat-ios
[Temporary] This repository provides feature-level Chat samples with Swift

## Structure
- Common: 기본 기능 Libary
  - 모듈화는 [UIKit](https://github.com/sendbird/uikit-ios/tree/release/3.0) 참고
  - 로그인
  - 설정
  - Group Channel
  - Open Channel
- BaseSample: 기본 기능 App
  - 대부분 Common에서 가져와서 사용 
- AFeatureSample: 확장 기능 App 1
  - Common 기본 틀 + 확장 기능 추가 
- BFeatureSample: 확장 기능 App 2
  - Common 기본 틀 + 확장 기능 추가 

## To do
### Open
- [ ] Create, view, update, or delete channel
- [ ] Enter and exit channel
- [ ] Send, receive message
- [ ] Send and receive media files (MIME types)
- [ ] Load previous messages
- [ ] Load messages by timestamp or message ID
- [ ] Retrieve a list of channels
- [ ] Event handlers/Delegates

### Group
- [ ] Create, view, or update channel
- [ ] Join and leave channel
- [ ] Invite as members
- [ ] Send, receive, update, copy or delete message
- [ ] Load previous messages
- [ ] Send and receive media files (MIME types)
- [ ] Load messages by timestamp or message ID
- [ ] Generate thumbnails of file message
- [ ] Mark messages as read
- [ ] Retrieve a list of channels
- [ ] Retrieve the last message of a channel
- [ ] Retrieve a list of members
- [ ] Logger
- [ ] Event handlers

### User
- [ ] Profile image
- [ ] Nick name
