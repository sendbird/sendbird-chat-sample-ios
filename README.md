# [Sendbird Chat](https://sendbird.com/docs/chat) SDK Sample for Android

[![Platform](https://img.shields.io/badge/Platform-iOS-orange.svg)](https://github.com/sendbird/sendbird-chat-sample-ios)
[![Language](https://img.shields.io/badge/Language-Swift-orange.svg)](https://github.com/sendbird/sendbird-chat-sample-ios)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains code samples in Kotlin, showcasing the key functionalities provided by Sendbird Chat SDK for Android. Each sample has a dedicated readme file briefing how the feature works on the code level. To learn more, see our [documentation for iOS](https://sendbird.com/docs/chat/v4/ios/overview).

## Prerequisites
+ Xcode 14.1 or later

## Sendbird Application ID

To streamline the implementation process, a sample Application ID has been provided for codes in this repository. However, you need a unique Sendbird Application ID to properly initialize the Chat SDK and enable its features in your production application. Sendbird Application ID can be found in the Overview page on [Sendbird Dashboard](https://dashbaord.sendbird.com). To learn more about how and when to use the Application ID, see our documentation on [initialization](https://sendbird.com/docs/chat/sdk/v4/ios/getting-started/send-first-message#2-get-started-3-step-3-initialize-the-chat-sdk).

## Code samples

Refer to the following list of code samples and their readme files.

- [Group Channel Add Remove Operators](./groupchannel-add-remove-operators/README.md)
- [Group Channel Admin Message](./groupchannel-admin-message/README.md)
- [Group Channel Ban Unban User](./groupchannel-ban-unban-user/README.md)
- [Group Channel Categorize Channels](./groupchannel-categorize-channels/README.md)
- [Group Channel Categorize Messages](./groupchannel-categorize-messages/README.md)
- [Group Channel Dnd Snooze](./groupchannel-dnd-snooze/README.md)
- [Group Channel File Progress Cancel](./groupchannel-file-progress-cancel/README.md)
- [Group Channel Freeze Unfreeze](./groupchannel-freeze-unfreeze/README.md)
- [Group Channel Friends](./groupchannel-friends/README.md)
- [Group Channel Hide Archive](./groupchannel-hide-archive/README.md)

## 🔒 Security tip
When a new Sendbird application is created in the dashboard the default security settings are set permissive to simplify running samples and implementing your first code.

Before launching make sure to review the security tab under ⚙️ Settings -> Security, and set Access token permission to Read Only or Disabled so that unauthenticated users can not login as someone else. And review the Access Control lists. Most apps will want to disable "Allow retrieving user list" as that could expose usage numbers and other information.

## Considerations in real world app
 - In this sample repo users are connecting to sendbird using a user ID (Sendbird Dashboard --> Security --> Read & Write). Read & Write is not secure and will create a new user automatically from the SDK if none exists. In production be sure to change the Sendbird Dashboard security settings to Deny login, and [authenticate users](https://sendbird.com/docs/chat/sdk/v4/ios/application/authenticating-a-user/authentication#2-connect-to-the-sendbird-server-with-a-user-id) with a Sendbird generated Session Token.
