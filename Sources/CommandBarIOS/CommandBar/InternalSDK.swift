import Foundation

protocol CommandBarInternalSDKDelegate: AnyObject {
    func didBootComplete(withConfig config: Config)
    func didBootFail(withError error: Error?)
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
    }
    
    
    func didBootComplete(withConfig config: Config) {
        CommandBarInternalSDK.shared.config = config
        
        CommandBarInternalSDK.shared.delegate?.didBootComplete(withConfig: config)
    }
    
    func didBootFail(withError error: Error?) {
        print("Failed to boot CommandBar: \(String(describing: error))")
        CommandBarInternalSDK.shared.delegate?.didBootFail(withError: error)
    }
}
