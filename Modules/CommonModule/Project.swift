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
                .external(name: "Kingfisher"),
    //                .external(name: "SendBirdSDK"),
//                .project(target: "SendbirdChat", path: .relativeToRoot("Modules/Internal/PlaceholderSDK")),
                    .xcframework(path: .relativeToRoot("Modules/Internal/v4-AlphaTest/SendbirdChat.xcframework")),
            ]
        )
    ]
)
