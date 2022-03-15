import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(
    names: ["BasicGroupChannel", "BasicOpenChannel"],
    platform: .iOS
)
