import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(
    names: ["BasicGroupChannel", "BasicOpenChannel"],
    platform: .iOS,
    usePlaceholderSDK: true
)

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/
extension Project {
    
    /// Helper function to create the Project for this ExampleApp
    public static func app(names: [String],
                           platform: Platform,
                           usePlaceholderSDK: Bool) -> Project {
        var targets = names.map {
            makeAppTarget(
                name: $0,
                platform: platform,
                dependencies: [.target(name: "CommonModule")]
            )
        }
        
        targets.append(
            contentsOf: makeFrameworkTargets(name: "CommonModule",
                                             platform: platform,
                                             usePlaceholderSDK: usePlaceholderSDK)
        )
                
        return Project(
            name: "Samples",
            organizationName: "Sendbird",
            targets: targets
        )
    }

    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(name: String,
                                             platform: Platform,
                                             usePlaceholderSDK: Bool) -> [Target] {
        let sources = Target(
            name: name,
            platform: platform,
            product: .framework,
            bundleId: "com.sendbird.chat.\(name)",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: [
                .external(name: "Kingfisher"),
                usePlaceholderSDK ?
                    .project(target: "SendbirdChat", path: "Tuist/PlaceholderSDK") : .external(name: "SendBirdSDK")
            ]
        )
        
        return [sources]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTarget(name: String, platform: Platform, dependencies: [TargetDependency]) -> Target {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "Main",
            "UILaunchStoryboardName": "LaunchScreen",
        ]

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "com.sendbird.chat.\(name)",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies,
            settings: .settings(
                base: SettingsDictionary().automaticCodeSigning(devTeam: "RM4A5PXTUX"),
                debug: SettingsDictionary().automaticCodeSigning(devTeam: "RM4A5PXTUX"),
                release: SettingsDictionary().automaticCodeSigning(devTeam: "RM4A5PXTUX"),
                defaultSettings: .recommended
            )
        )
        
        return mainTarget
    }
    
}
