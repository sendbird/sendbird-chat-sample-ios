# SendbirdChat-Debug

`SendbirdChat-Debug` is a trick for sendbird developers 💌 🦅. This project is used to trick the tuist into creating a placeholder SDK named SendbirdChat.

1. Set `.project(target: "SendbirdChat", path: .relativeToRoot("Modules/Internal/SendbirdChat-Debug"))` as depedency in [`Modules/CommonModule/Project.swift`](../../CommonModule/Project.swift)

```diff
let project = Project(
    name: "CommonModule",
    organizationName: "Sendbird",
    targets: [
        Target(
            name: "CommonModule",
            platform: .iOS,
            product: .framework,
            bundleId: "com.sendbird.chat.CommonModule",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .xcframework(path: .relativeToRoot("Modules/External/Kingfisher-7.2.0/Kingfisher.xcframework")),
-                .xcframework(path: .relativeToRoot("Modules/Internal/SendbirdChat-4.0.0/SendbirdChat.xcframework")),
+                .project(target: "SendbirdChat", path: .relativeToRoot("Modules/Internal/SendbirdChat-Debug")),
            ]
        )
    ]
)
```

2. Run `tuist generate` in terminal.
3. Remove `SendbirdChat` project in `Samples` workspace.
4. Drag and drop `SendbirdChat` project in private repo to `Samples` workspace.
5. Enjoy debug.
