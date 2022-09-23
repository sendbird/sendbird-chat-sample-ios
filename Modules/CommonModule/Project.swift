import ProjectDescription

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
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
//                .external(name: "SendbirdChatSDK"),
                .external(name: "Kingfisher"),
//                .xcframework(path: .relativeToRoot("Modules/External/Kingfisher-7.2.0/Kingfisher.xcframework")),
//                .xcframework(path: .relativeToRoot("Modules/Internal/SendbirdChat-4.0.0/SendbirdChatSDK.xcframework")),
                .project(target: "SendbirdChatSDK", path: .relativeToRoot("Modules/Internal/SendbirdChat-Debug")),
            ]
        )
    ]
)
