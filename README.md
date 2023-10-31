<img src="docs/img/CommandBar.png" alt="CommandBar Logo" width="200" height="200">

# CommandBarIOS

[![Build](https://github.com/tryfoobar/CommandBarIOS/actions/workflows/ci.yml/badge.svg)](https://github.com/tryfoobar/CommandBarIOS/actions/workflows/ci.yml)

Copilot & HelpHub in IOS

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
    .package(url: "https://github.com/tryfoobar/CommandBarIOS.git", from: "1.0.9")
]
```

## Usage

### `CommandBar`

`init`:

-   `options` (required): An instance of the `CommandBarOptions` class that holds the options for the `HelpHubWebView``.
    -   `orgId` (required): Your Organization ID from [CommandBar](https://app.commandbar.com)
    -   `spinnerColor` (optional): Optionally specify a color to render the loading Spinner

`openHelpHub()`: Opens HelpHubWebView in a BottomSheet modal

`onFallbackAction`: If you need to handle fallback actions from the HelpHub web view, you can conform to `HelpHubWebViewDelegate` protocol and implement the `didReceiveFallbackAction(_:)` method. The `CommandBar` class itself is already conforming to this protocol and forwarding the callback to its own delegate which you can set on your instance of `CommandBar` like `commandbar.delegate = self`

### `HelpHubWebView`

`init`: Loads HelpHub in a WebView. The WebView won't load its content until options are set via `helpHubWebView.options = CommandBarOptions()`

-   `options` (optional): An instance of the `CommandBarOptions` class that holds the options for the `HelpHubWebView``.
    -   `orgId` (required): Your Organization ID from [CommandBar](https://app.commandbar.com)
    -   `spinnerColor` (optional): Optionally specify a color to render the loading Spinner
-   `onFallbackAction` (optional): A callback function to receive an event when a Fallback CTA is interacted with

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. Open `Example/CommandBarIOS.xcworkspace` in Xcode and run the project.

## License

CommandBarIOS is available under the MIT license. See the LICENSE file for more info.
