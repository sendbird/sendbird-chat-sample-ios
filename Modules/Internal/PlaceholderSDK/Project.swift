import ProjectDescription

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project(
    name: "SendbirdChat",
    organizationName: "Sendbird",
    targets: [
        Target(
            name: "SendbirdChat",
            platform: .iOS,
            product: .framework,
            bundleId: "placeholder"
        )
    ]
)
