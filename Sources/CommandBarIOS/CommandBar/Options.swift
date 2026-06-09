import Foundation

/// Amplitude data residency / target endpoint family.
/// Maps to `SDKConfig.serverZone` in the Engagement web SDK.
public enum ServerZone: String {
    case us = "US"
    case eu = "EU"
    case local = "local"
}

/// Configuration for the Amplitude Engagement WebView SDK.
///
/// Native callers create one `CommandBarOptions` and the WebView routes
/// fields to `engagement.init(apiKey, {...})` and `engagement.boot({ user, ... })`
/// internally, matching the web `EngagementSDK` split.
public struct CommandBarOptions {
    /// Amplitude project API key. Routes to `engagement.init(apiKey, ...)`.
    public var apiKey: String

    /// End user identity. Routes to `engagement.boot({ user, ... })`.
    /// If `nil`, the WebView generates a session-scoped anonymous `device_id`.
    public var user: User?

    /// Amplitude data residency. Routes to `engagement.init` `serverZone`.
    public var serverZone: ServerZone

    /// Override Amplitude server endpoint. Routes to `engagement.init` `serverUrl`.
    public var serverUrl: String?

    /// Override the CDN base used for `*.engagement.js` and engagement-browser bundles.
    /// Routes to `engagement.init` `cdnUrl` and is preferred for the bootstrap script URL.
    public var cdnUrl: String?

    /// Override the Assistant chat endpoint. Routes to `engagement.init` `chatUrl`.
    public var chatUrl: String?

    /// Override the media (image/video) endpoint. Routes to `engagement.init` `mediaUrl`.
    public var mediaUrl: String?

    /// Localization locale (e.g. `"en-US"`). Routes to `engagement.init` `locale`.
    public var locale: String?

    /// CSS color used by the loading spinner shown while the WebView boots Engagement.
    public var spinnerColor: String

    public struct User {
        public var userId: String?
        public var deviceId: String?

        public init(userId: String? = nil, deviceId: String? = nil) {
            self.userId = userId
            self.deviceId = deviceId
        }
    }

    /// Flat-form initializer: pass `userId` directly without constructing a `User`.
    public init(
        apiKey: String,
        userId: String? = nil,
        serverZone: ServerZone = .us,
        serverUrl: String? = nil,
        cdnUrl: String? = nil,
        chatUrl: String? = nil,
        mediaUrl: String? = nil,
        locale: String? = nil,
        spinnerColor: String = "#3662F1"
    ) {
        self.apiKey = apiKey
        self.user = userId.map { User(userId: $0) }
        self.serverZone = serverZone
        self.serverUrl = serverUrl
        self.cdnUrl = cdnUrl
        self.chatUrl = chatUrl
        self.mediaUrl = mediaUrl
        self.locale = locale
        self.spinnerColor = spinnerColor
    }

    /// Nested-form initializer: pass a full `User` (e.g. with `deviceId`).
    public init(
        apiKey: String,
        user: User?,
        serverZone: ServerZone = .us,
        serverUrl: String? = nil,
        cdnUrl: String? = nil,
        chatUrl: String? = nil,
        mediaUrl: String? = nil,
        locale: String? = nil,
        spinnerColor: String = "#3662F1"
    ) {
        self.apiKey = apiKey
        self.user = user
        self.serverZone = serverZone
        self.serverUrl = serverUrl
        self.cdnUrl = cdnUrl
        self.chatUrl = chatUrl
        self.mediaUrl = mediaUrl
        self.locale = locale
        self.spinnerColor = spinnerColor
    }

    /// Dictionary initializer used by the React Native bridge.
    /// Accepts both the flat shorthand (`userId`) and nested (`user: { userId, deviceId }`) forms.
    public init(dictionary: [String: Any]) {
        let apiKey = (dictionary["apiKey"] as? String)
            ?? (dictionary["orgId"] as? String)
            ?? ""
        self.apiKey = apiKey

        if let userDict = dictionary["user"] as? [String: Any] {
            self.user = User(
                userId: userDict["userId"] as? String,
                deviceId: userDict["deviceId"] as? String
            )
        } else if let userId = dictionary["userId"] as? String {
            self.user = User(userId: userId)
        } else {
            self.user = nil
        }

        if let raw = dictionary["serverZone"] as? String {
            switch raw.uppercased() {
            case "EU": self.serverZone = .eu
            case "LOCAL": self.serverZone = .local
            default: self.serverZone = .us
            }
        } else {
            self.serverZone = .us
        }

        self.serverUrl = dictionary["serverUrl"] as? String
        self.cdnUrl = dictionary["cdnUrl"] as? String
        self.chatUrl = dictionary["chatUrl"] as? String
        self.mediaUrl = dictionary["mediaUrl"] as? String
        self.locale = dictionary["locale"] as? String
        self.spinnerColor = dictionary["spinnerColor"] as? String ?? "#3662F1"
    }
}
