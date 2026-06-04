import Foundation

/// Latest tag filters set from native; embedded into the WebView snippet and applied via JS after boot.
enum EngagementFilterStore {
    private static let lock = NSLock()
    private static var _assistantFilterJson: String?
    private static var _resourceCenterFilterJson: String?

    static var assistantFilterJsonLiteral: String {
        lock.lock()
        defer { lock.unlock() }
        return _assistantFilterJson ?? "null"
    }

    static var resourceCenterFilterJsonLiteral: String {
        lock.lock()
        defer { lock.unlock() }
        return _resourceCenterFilterJson ?? "null"
    }

    static func setAssistantFilter(_ filter: [String: Any]?) {
        lock.lock()
        _assistantFilterJson = Self.jsonLiteral(from: filter)
        lock.unlock()
    }

    static func setResourceCenterFilter(_ filter: [String: Any]?) {
        lock.lock()
        _resourceCenterFilterJson = Self.jsonLiteral(from: filter)
        lock.unlock()
    }

    private static func jsonLiteral(from filter: [String: Any]?) -> String? {
        guard let filter = filter else { return nil }
        guard JSONSerialization.isValidJSONObject(filter),
              let data = try? JSONSerialization.data(withJSONObject: filter),
              let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }
}
