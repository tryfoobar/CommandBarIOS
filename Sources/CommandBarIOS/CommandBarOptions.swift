
public struct CommandBarOptions {
    var orgId: String
    var userId: String?
    var spinnerColor: String;
    
    public init(orgId: String, userId: String? = nil, spinnerColor: String? = nil) {
        self.orgId = orgId
        self.userId = userId
        self.spinnerColor = spinnerColor ?? "#3662F1"
    }
    
    public init(dictionary: [String: Any]) {
        orgId = dictionary["orgId"] as! String
        userId = dictionary["userId"] as? String
        spinnerColor = dictionary["spinnerColor"] as? String ?? "#3662F1"
    }
}
