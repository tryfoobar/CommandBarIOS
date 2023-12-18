
// MARK: Public
protocol CommandBarOptionsDelegate: Codable {
    var user_id: String? { get set }
}

public struct CommandBarOptions : CommandBarOptionsDelegate, Codable {
    public var user_id: String? = nil
    
    public init(user_id: String? = nil) {
        self.user_id = user_id
    }
}


// MARK: Internal
internal enum LaunchCode: String, Codable {
    case prod = "prod"
    case labs = "labs"
    case localDev = "local-dev"
}

internal struct CommandBarInternalOptions : CommandBarOptionsDelegate, Codable {
    var user_id: String?
    internal var launch_code: LaunchCode
    
    internal init() {
        self.launch_code = .prod
        self.user_id = nil
    }
    
    internal init(launch_code: LaunchCode, user_id: String? = nil) {
        self.user_id = user_id
        self.launch_code = launch_code
    }
    
    internal init(from options: CommandBarOptions, with launch_code: LaunchCode = .prod) {
        self.user_id = options.user_id
        self.launch_code = launch_code
    }
    
    internal func getAPIUrl(for resource: InternalAPIResource = .api, with path: String) -> URL? {
        let baseURLStr = self.getBaseURLStr(for: resource)
        if var components = URLComponents(string: baseURLStr) {
            components.path = path
            
            return components.url
        }
        
        return nil
    }
    
    internal func getBaseURL(for resource: InternalAPIResource = .api) -> URL? {
        let urlStr = self.getBaseURLStr(for: resource)
        return URL(string: urlStr)
    }
    
    internal func getBaseURLStr(for resource: InternalAPIResource = .api) -> String {
        var baseURLStr = "https://api.commandbar.com"
        
        switch(self.launch_code) {
        case .labs:
            baseURLStr = "https://api-labs.commandbar.com"
            break;
        case .localDev:
            baseURLStr = "http://localhost:8000"
            break
        default:
            if resource == .analytics {
                baseURLStr = "https://t.commandbar.com"
            }
        }
        
        return baseURLStr
    }
    
    enum InternalAPIResource {
        case analytics
        case api
    }
}

public struct CommandBarOptions_Deprecated {
    var orgId: String
    var userId: String?
    var spinnerColor: String;
    var launchCode: String;
    
    public init(_ dict: [String: Any]) {
        orgId = dict["orgId"] as! String
        userId = dict["userId"] as? String
        spinnerColor = dict["spinnerColor"] as? String ?? "#3662F1"
        launchCode = dict["launchCode"] as? String ?? "prod"
    }
}

