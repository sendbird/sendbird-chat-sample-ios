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

### Open
- [ ] Create, view, update, or delete channel
- [ ] Enter and exit channel
- [ ] Send, receive message
- [ ] Send and receive media files (MIME types)
- [ ] Load previous messages
- [ ] Load messages by timestamp or message ID
- [ ] Retrieve a list of channels
- [ ] Event handlers/Delegates

### User
- [ ] Profile image
- [ ] Nick name
