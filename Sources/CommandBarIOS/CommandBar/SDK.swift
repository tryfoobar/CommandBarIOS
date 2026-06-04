import Foundation
import JavaScriptCore

public protocol CommandBarSDKDelegate : AnyObject {}
// Optional Protocol methods
extension CommandBarSDKDelegate {
    func didTriggerAssistantFallback(withType type: String) {}
    func didFinishBooting(withError error: Error?) {}
}

// MARK: Public SDK
public final class CommandBarSDK {
    private static let sharedInternal = CommandBarInternalSDK.shared
    private var commandbar: CommandBar_Deprecated? = nil
    public static let shared = CommandBarSDK()
    
    
    var isReady: Bool = false
    var orgId: String? = nil
    var options: CommandBarOptions? = nil
    
    public weak var delegate: CommandBarSDKDelegate?
    weak var privateDelagate: CommandBarInternalSDK?
    
    public init() {
        self.orgId = nil
        self.options = nil
    }
    
    public func boot(_ orgId: String, with options: CommandBarOptions? = nil) {
        self.orgId = orgId
        self.options = options

        var dict: [String: Any] = ["orgId": orgId, "launchCode": "prod"]
        if let uid = options?.user_id {
            dict["userId"] = uid
        }

        self.commandbar = CommandBar_Deprecated(options: CommandBarOptions_Deprecated(dict))
        CommandBarSDK.sharedInternal.boot(orgId: orgId, with: options)
    }
    
    public func openResourceCenter(articleId: Int? = nil, withFallbackAction fallbackAction: ((String) -> Void)? = nil) {
        guard CommandBarSDK.shared.orgId != nil else { return }
        commandbar?.openResourceCenter(articleId: articleId, fallbackAction: fallbackAction)
    }

    public func openAssistant(withFallbackAction fallbackAction: ((String) -> Void)? = nil) {
        guard CommandBarSDK.shared.orgId != nil else { return }
        commandbar?.openAssistant(fallbackAction: fallbackAction)
    }

    public func closeResourceCenter() {
        guard CommandBarSDK.shared.orgId != nil else { return }
        commandbar?.closeResourceCenter()
    }

    /// Mirrors `window.engagement.assistant.setAssistantFilter`. Pass `nil` to clear.
    public func setAssistantFilter(_ filter: [String: Any]?) {
        EngagementFilterStore.setAssistantFilter(filter)
        ResourceCenterWebView.activeInstance?.applyEngagementFilters()
    }

    /// Mirrors `window.engagement.setResourceCenterFilter`. Pass `nil` to clear.
    public func setResourceCenterFilter(_ filter: [String: Any]?) {
        EngagementFilterStore.setResourceCenterFilter(filter)
        ResourceCenterWebView.activeInstance?.applyEngagementFilters()
    }
}

extension CommandBarSDK : CommandBarInternalSDKDelegate {
    func didBootComplete(withConfig config: Config) {
        CommandBarSDK.shared.isReady = true
        CommandBarSDK.shared.delegate?.didFinishBooting(withError: nil)
        
    }
    
    func didBootFail(withError error: Error?) {
        CommandBarSDK.shared.delegate?.didFinishBooting(withError: error)
    }
}
