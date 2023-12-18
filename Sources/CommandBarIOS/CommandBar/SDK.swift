import Foundation
import JavaScriptCore

public protocol CommandBarSDKDelegate : AnyObject {
    func didFinishBooting(withError error: Error?)
}

// Optional Protocol methods
extension CommandBarSDKDelegate {
    func didTriggerOpenChat(withType type: String) {}
}

// MARK: Public SDK
public final class CommandBarSDK {
    private static let sharedInternal = CommandBarInternalSDK.shared
    private var commandbar: CommandBar? = nil
    public static let shared = CommandBarSDK()
    
    
    var isReady: Bool = false
    var orgId: String? = nil
    var options: CommandBarOptions? = nil
    
    weak var delegate: CommandBarSDKDelegate?
    weak var privateDelagate: CommandBarInternalSDK?
    
    public init() {
        self.orgId = nil
        self.options = nil
    }
    
    public func boot(_ orgId: String, with options: CommandBarOptions? = nil) {
        self.orgId = orgId
        self.options = options
        self.commandbar = CommandBar(options: CommandBarOptions_Deprecated(["orgId": orgId, "launchCode": "prod" ]))

        CommandBarSDK.sharedInternal.boot(orgId: orgId, with: options)
    }
    
    
    public func trackEvent(event: String) {
        CommandBarSDK.sharedInternal.trackEvent(event: event)
    }
    
    public func openHelpHub() {
        guard let orgId = CommandBarSDK.shared.orgId else { return }
        
        commandbar?.openHelpHub()
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
    
    func didTriggerOpenChat(withType type: String) {
        CommandBarSDK.shared.delegate?.didTriggerOpenChat(withType: type)
    }
}

