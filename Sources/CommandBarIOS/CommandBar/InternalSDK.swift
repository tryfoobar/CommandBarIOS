import Foundation

protocol CommandBarInternalSDKDelegate: AnyObject {
    func didBootComplete(withConfig config: Config)
    func didBootFail(withError error: Error?)
    
    func didTriggerOpenChat(withType type: String)
}

// MARK: Internal SDK
final class CommandBarInternalSDK : CommandBarInternalSDKDelegate {
    internal final var LAUNCH_CODE: LaunchCode = .prod
    
    var orgId: String? = nil
    var options: CommandBarInternalOptions = CommandBarInternalOptions(launch_code: .prod)
    var config: Config? = nil
    
    // Update when you need to test localhost
    
    weak var delegate: CommandBarInternalSDKDelegate?
    static let shared = CommandBarInternalSDK()
    
    var isReady: Bool = false
    
    func boot(orgId: String, with options: CommandBarOptions? = nil) {
        self.orgId = orgId
        self.options = options != nil ? CommandBarInternalOptions(from: options!, with: LAUNCH_CODE) : self.options
        
        guard let url = self.options.getAPIUrl(with: "/organizations/\(self.orgId!)/config/") else {
            print("Warning: Could not boot CommandBar")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print("Warning: Could not boot CommandBar")
                CommandBarInternalSDK.shared.didBootFail(withError: error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let config = try decoder.decode(Config.self, from: data)
                
                // Once we've decoded the condig, setup Analytics
                Analytics.shared.setup(orgId: orgId, with: self.options)
                
                DispatchQueue.main.async {
                    CommandBarInternalSDK.shared.isReady = true
                    CommandBarInternalSDK.shared.didBootComplete(withConfig: config)
                }
                
            } catch let error {
                print("Warning: Could not boot CommandBar")
                DispatchQueue.main.async {
                    CommandBarInternalSDK.shared.didBootFail(withError: error)
                }
            }
        }
        task.resume()
    }
    
    func triggerNudges() {
        guard let config = CommandBarInternalSDK.shared.config else { return }
        
        // TODO: Can probably hook up some sort of background queue to enqueue to from here
        if let nudge = filterNudges().first {
            NudgeWindowManager.shared.renderNudge(nudge)
        }
    }
    
    
    func triggerNudges(withEvent event: String) {
        guard let config = CommandBarInternalSDK.shared.config else { return }
        
        if let nudge = filterNudges().first {
            NudgeWindowManager.shared.renderNudge(nudge)
        }
    }
    
    
    func filterNudges() -> [Nudge] {
        guard let config = CommandBarInternalSDK.shared.config else { return [] }
        
        return config.nudges_v2.filter({ nudge in
            if (!nudge.is_live || nudge.archived) {
                return false
            }
            
            let hasUnsupportedStep = nudge.steps.contains(where: { step in
                if (step.form_factor.type == .pin) {
                    return true
                }
                let hasUnsupportedContent = step.content.contains(where: { content in
                    if (content.type == .button) {
                        if let actionMeta = content.meta as? NudgeContentButtonBlockMeta {
                            if (actionMeta.action.isSameType(as: "execute_command")) {
                                return true
                            } else if (actionMeta.action.isSameType(as: "click")) {
                                return true
                            } else if (actionMeta.action.isSameType(as: "open_bar")) {
                                return true
                            } else if (actionMeta.action.isSameType(as: "questlist")) {
                                return true
                            } else if (actionMeta.action.isSameType(as: "snooze")) {
                                return true
                            } else if (actionMeta.action.isSameType(as: "open_chat")) {
                                return true
                            } else {
                                return false
                            }
                        }
                    } else if (content.type == .contentList || content.type == .helpDoc) {
                        return true
                    }
                    
                    return true
                })
                return hasUnsupportedContent;
            })
            return hasUnsupportedStep
        })
    }
    
    public func trackEvent(event: String) {
        CommandBarInternalSDK.shared.triggerNudges(withEvent: event)
    }
    
    
    func didBootComplete(withConfig config: Config) {
        CommandBarInternalSDK.shared.config = config
        
        CommandBarInternalSDK.shared.triggerNudges()
        CommandBarInternalSDK.shared.delegate?.didBootComplete(withConfig: config)
    }
    
    func didBootFail(withError error: Error?) {
        print("Failed to boot CommandBar: \(String(describing: error))")
        CommandBarInternalSDK.shared.delegate?.didBootFail(withError: error)
    }
    
    func didTriggerOpenChat(withType type: String) {
        CommandBarInternalSDK.shared.delegate?.didTriggerOpenChat(withType: type)
    }

}
