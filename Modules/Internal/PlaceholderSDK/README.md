# PlacholderSDK

1. Set `usePlaceholderSDK: true` in `Project.swift`

```
let project = Project.app(
    names: ["BasicGroupChannel", "BasicOpenChannel"],
    platform: .iOS
    platform: .iOS,
    usePlaceholderSDK: true
)
```

2. Run `tuist generate` in terminal.
3. Remove `SendbirdChat` project in `Samples` workspace.
4. Drag and drop `SendbirdChat` project in private repo to `Samples` workspace.
5. Enjoy debug.
