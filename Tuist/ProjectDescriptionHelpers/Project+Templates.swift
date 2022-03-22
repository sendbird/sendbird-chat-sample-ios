import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    
    /// Helper function to create the Project for this ExampleApp
    public static func app(name: String) -> Project {
        Project(
            name: name,
            organizationName: "Sendbird",
            targets: [
                makeAppTarget(
                    name: name,
                    platform: .iOS,
                    dependencies: [
                        .project(
                            target: "CommonModule",
                            path: .relativeToRoot("Modules/CommonModule")
                        )
                    ]
                )
            ]
        )
    }

    // MARK: - Private
    
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
            sources: [.glob(.relativeToManifest("Sources/**"))],
            resources: [.glob(pattern: .relativeToManifest("Resources/**"))],
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

