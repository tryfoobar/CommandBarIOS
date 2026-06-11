# Migrating from CommandBarIOS 1.x to 2.0

CommandBarIOS 2.0 is the **Amplitude** rewrite of the SDK. The renderer is now a single WebView that loads `*.engagement.js`, the public surface is collapsed to one type (`CommandBarSDK`), and the option names are aligned with the web Engagement SDK.

This is a **breaking** release. Every app on 1.x needs the changes below.

## TL;DR


| Area             | 1.x                                                                           | 2.0                                                                                              |
| ---------------- | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Identifier       | `orgId` (a CommandBar org id)                                                 | `apiKey` (your Amplitude project API key)                                                        |
| Boot signature   | `boot("<orgId>", CommandBarOptions(user_id: ...))`                            | `boot(options: CommandBarOptions(apiKey: ..., userId: ...))`                                     |
| Open methods     | `openHelpHub(articleId:, withFallbackAction:)`                                | `openResourceCenter(articleId:, fallbackAction:)` — no `options:` arg                            |
| Open methods     | -                                                                             | `openAssistant(fallbackAction:)` — no `options:` arg                                             |
| `launchCode`     | shortcut for staging/local endpoints                                          | removed — use explicit `serverUrl` / `cdnUrl` / `chatUrl` / `mediaUrl` / `locale` / `serverZone` |
| Deprecated types | `CommandBar_Deprecated`, `CommandBarInternalSDK`, `CommandBarInternalOptions` | removed                                                                                          |


## 1. Replace your `orgId` with an Amplitude `apiKey`

CommandBar is now Amplitude! Get your project **API key** from the Amplitude dashboard and use it wherever you previously passed an org id.

```diff
- CommandBarSDK.shared.boot("YOUR_ORG_ID")
+ CommandBarSDK.shared.boot(options: CommandBarOptions(apiKey: "YOUR_API_KEY"))
```

## 2. Use the unified `CommandBarOptions`

There is only one options struct now, and it covers everything `init` + `boot` used to take separately. `user_id` is renamed to `userId` and you can either keep using the flat shorthand or pass a nested `User` (for an explicit `deviceId`).

```diff
- CommandBarSDK.shared.boot(
-     "YOUR_ORG_ID",
-     CommandBarOptions(user_id: "user-123")
- )
+ CommandBarSDK.shared.boot(options: CommandBarOptions(
+     apiKey: "YOUR_API_KEY",
+     userId: "user-123"
+ ))
```

Or, with explicit device id:

```swift
CommandBarSDK.shared.boot(options: CommandBarOptions(
    apiKey: "YOUR_API_KEY",
    user: .init(userId: "user-123", deviceId: "device-abc")
))
```

## 3. Drop `options` from `openResourceCenter` / `openAssistant`

Boot now stores configuration on `CommandBarSDK.shared`. The open methods read from it, so they no longer accept `options`. The fallback callback label also changes from `withFallbackAction:` to `fallbackAction:`.

```diff
- CommandBarSDK.shared.openResourceCenter(
-     articleId: 123,
-     withFallbackAction: onFallback
- )
+ CommandBarSDK.shared.openResourceCenter(
+     articleId: 123,
+     fallbackAction: onFallback
+ )
```

Calls before `boot(options:)` are now a no-op and log a warning. Call `boot` as early as possible or as soon as you have a user ID.

## 4. Remove references to deprecated types

The following are no longer shipped. Delete any code that touches them; the new `CommandBarSDK` / `CommandBarOptions` cover their use cases.

- `CommandBar_Deprecated`
- `CommandBarInternalSDK`
- `CommandBarInternalOptions`

The old `Analytics/`, `Components/`, `Helpers/`, and `Types/` directories are also gone — they were leftovers from the pre-WebView native renderer and are unused at runtime.

## Reference

After migrating, the [README](./README.md) is the source of truth for the 2.0 API.