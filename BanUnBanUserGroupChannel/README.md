# Ban or unban users

This sample app demonstrates how to ban or unban user in a group channel on Sendbird Chat SDK for iOS.

## Prerequisites
+ Xcode 14.1 or later

## How it works

You can ban or unban user in a group channel by using `channel.banUser()` or `channel.unbanUser()` method.

[BanAndUnBanUseCase.swift](./Sources/UseCase/BanAndUnBan/BanAndUnBanUseCase.swift#L19-L37)
``` swift
func ban(user: User, completion: @escaping(Result<Void, SBError>) -> Void) {
    channel.banUser(userId: user.userId, seconds: 120, description: nil, completionHandler: { error in
        guard let error = error else {
            completion(.success(()))
            return
        }
        completion(.failure(error))
    })
}

func unBan(user: User, completion: @escaping(Result<Void, SBError>) -> Void) {
    channel.unbanUser(userId: user.userId, completionHandler: { error in
        guard let error = error else {
            completion(.success(()))
            return
        }
        completion(.failure(error))
    })
}
```

And you can retrieve the list of banned users in a group channel by using `channel.createBannedUserListQuery()` method.

[GroupChannelMemberListUseCase.swift](./Sources/UseCase/GroupChannel/GroupChannelMemberListUseCase.swift#L24-L61)
``` swift
private lazy var bannedUserListQuery: BannedUserListQuery? = self.isBannedListQuery ? self.channel.createBannedUserListQuery() : nil
...
private func loadBannedUsers() {
    guard let query = bannedUserListQuery, !query.isLoading, query.hasNext else { return }
    
    query.loadNextPage { [weak self] members, error in
        self?.handleQueryResult(members, error: error)
    }
}
```

## How to run
``` bash
open BanUnBanUserGroupChannel.xcodeproj
```
