import Foundation
import JavaScriptCore

public protocol CommandBarSDKDelegate : AnyObject {}
// Optional Protocol methods
extension CommandBarSDKDelegate {
    func didTriggerCopilotFallback(withType type: String) {}
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
    
    private var copilotFallbackAction: ((String) -> Void)? = nil
    
    public init() {
        self.orgId = nil
        self.options = nil
    }
    
    public func boot(_ orgId: String, with options: CommandBarOptions? = nil) {
        self.orgId = orgId
        self.options = options
        self.commandbar = CommandBar_Deprecated(options: CommandBarOptions_Deprecated(["orgId": orgId, "launchCode": "local" ]))
        self.commandbar?.delegate = self
        CommandBarSDK.sharedInternal.boot(orgId: orgId, with: options)
    }
    
    public func openHelpHub(articleId: Int? = nil, withCopilotFallback copilotFallbackCallback: ((String) -> Void)? = nil) {
        guard let orgId = CommandBarSDK.shared.orgId else { return }
            
        self.copilotFallbackAction = copilotFallbackCallback
        commandbar?.openHelpHub(articleId: articleId)
    }
    
    public func closeHelpHub() {
        guard let orgId = CommandBarSDK.shared.orgId else { return }
        commandbar?.closeHelpHub()
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
    
    func didTriggerCopilotFallback(withType type: String) {
        CommandBarSDK.shared.delegate?.didTriggerCopilotFallback(withType: type)
    }
}

extension CommandBarSDK : HelpHubWebViewDelegate {
    public func didTriggerCopilotFallback(_ action: [String : Any]) {
        let meta = action["meta"] as? [String: Any] ?? [:]
        let type = meta["type"] as? String ?? ""
        
        if (self.copilotFallbackAction != nil) {
            self.copilotFallbackAction!(type)
        }
    }
}
