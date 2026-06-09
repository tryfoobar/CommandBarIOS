<img src="docs/img/CommandBar.png" alt="CommandBar Logo" width="200" height="200">
<img src="https://www.freelogovectors.net/wp-content/uploads/2023/11/amplitude_logo-freelogovectors.net_.png" alt="Amplitude Logo" width="260" height="200">

# CommandBarIOS

Assistant & Resource Center in IOS

> [!WARNING]
> CommandBar is now part of [Amplitude](https://amplitude.com). This repository has been updated to help existing CommandBar customers migrate to **Amplitude Resource Center & Assistant**, but it should be treated as **deprecated** and will not receive updates.
> For those migrating from CommandBar/CommandAI, please see our [migration guide](./MIGRATING.md)

## Requirements

## Installation

### CocoaPods

CommandBarIOS is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CommandBarIOS'
```

### Swift Package Manager

To install it using Swift Package Manager, add the following to your `Package.swift` file:

```
dependencies: [
    .package(url: "https://github.com/tryfoobar/CommandBarIOS.git", from: "1.1.9")
]
```

## Usage

### 1. Import the SDK

```
import CommandBarIOS
```

### 2. Boot the SDK

Boot once at app launch with your Amplitude **project API key**. The booted options are reused by every subsequent `openResourceCenter` / `openAssistant` call.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Minimal boot
        CommandBarSDK.shared.boot(options: CommandBarOptions(apiKey: "<your api key>"))

        // Boot with a known user and additional overrides (all optional)
        CommandBarSDK.shared.boot(options: CommandBarOptions(
            apiKey: "<your api key>",
            user: .init(userId: "<your user id>"),
            serverZone: .us,           // .us (default), .eu, .local
            // serverUrl: "...",       // override Amplitude server endpoint
            // cdnUrl: "...",          // override engagement.js CDN base
            // chatUrl: "...",
            // mediaUrl: "...",
            // locale: "en-US",
            spinnerColor: "#3662F1"
        ))
        return true
    }
}
```

Call `boot(options:)` again at any time to swap in new options (e.g. after the user signs in).

### 3. (Optional) Tag filters

Set filters before or after opening the sheet; the latest values are applied on each WebView load and immediately if the sheet is already open.

```swift
CommandBarSDK.shared.setAssistantFilter(["tags": ["[Zendesk] mobile"]])

let resourceCenterFilter: [String: Any] = [
  "and": [
    ["tags": ["[Zendesk] mobile"]] as [String: Any],
    ["or": [
      ["tags": ["[Zendesk] v2"]] as [String: Any],
      ["tags": ["[Zendesk] v3"]] as [String: Any],
    ]] as [String: Any],
  ] as [String: Any],
]
CommandBarSDK.shared.setResourceCenterFilter(resourceCenterFilter)
CommandBarSDK.shared.setAssistantFilter(nil) // clear
```

### 4. Open Resource Center / Assistant

Use `openResourceCenter` to open the Help Hub tab, or `openAssistant` for the Assistant tab. Neither takes options — they use the configuration from `boot(options:)`.

```swift
struct MyView: View {
  var body: some View {
    Button(action: {
      CommandBarSDK.shared.openResourceCenter()
    }) {
      Text("Tap me!").padding()
    }
  }
}
```

You can pass `articleId` to deep-link into a specific article, and `fallbackAction` to receive a callback when the user triggers an Open Chat action:

```swift
struct MyView: View {
  var body: some View {
    Button(action: {
      CommandBarSDK.shared.openResourceCenter(articleId: 123, fallbackAction: { type in
        print("User triggered fallback: \(type)")
        CommandBarSDK.shared.closeResourceCenter()
      })
    }) {
      Text("Tap me!").padding()
    }
  }
}
```

### 5. (Optional) Run the Example App

To run the example project, first clone the repo, then:

1. `cd CommandBarIOS/Example && pod install`
2. Open `Example/CommandBarIOS.xcworkspace` in Xcode
3. Navigate to `HomeView.swift` and replace the `ORG_ID` variable with your Organization's ID from [CommandBar](https://mobile.commandbar.com)
4. Run the App 🎉

## License

CommandBarIOS is available under the MIT license. See the LICENSE file for more info.
