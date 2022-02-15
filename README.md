# examples-chat-ios
[Temporary] This repository provides feature-level Chat samples with Swift

## Project Design

https://sendbird.atlassian.net/wiki/spaces/SDK/pages/1767407864/Sample+2.0

- `Samples.workspace`
    - Base module
        - Business Logic
        - (Optional) Small Views that can be easily modularized
        - It is used as an embedded framework in each Sample App.
    - Basic Open Channel Sample App
    - Basic Group Channel Sample App
    - Feature Sample 1 App: Implementing additional functions after copying and pasting the basic sample
    - Feature Sample 2 App: Implementing additional functions after copying and pasting the basic sample
    - Feature Sample N App: Implementing additional functions after copying and pasting the basic sample
- How should I implement a feature that is applied to both Open and Group Channels?
    - Implementation based only on Group Sample
- Minimum deployment target: 13.0

## To do

### Group
- [x] Create, view, or update channel
- [x] Join and leave channel
- [x] Invite as members
- [x] Send, receive, update, copy or delete message
- [x] Load previous messages
- [x] Send and receive media files (MIME types)
- [ ] Load messages by timestamp or message ID
- [x] Generate thumbnails of file message
- [x] Mark messages as read
- [x] Retrieve a list of channels
- [x] Retrieve the last message of a channel
- [x] Retrieve a list of members
- [x] Logger
- [x] Event handlers

### Open
- [x] Create, view, update, or delete channel
- [x] Enter and exit channel
- [x] Send, receive message
- [x] Send and receive media files (MIME types)
- [x] Load previous messages
- [ ] Load messages by timestamp or message ID
- [x] Retrieve a list of channels
- [x] Event handlers/Delegates

### User
- [x] Profile image
- [x] Nick name
