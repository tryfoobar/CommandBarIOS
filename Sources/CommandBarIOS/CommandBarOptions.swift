
public struct CommandBarOptions {
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
