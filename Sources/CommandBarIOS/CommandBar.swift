import WebKit

public struct CommandBar {
    public static func openHelpHub(orgId: String, resolve: ((Any?) -> Void)? = nil, reject: ((Any?) -> Void)? = nil) {
        DispatchQueue.main.async {
            let viewController = HelpHubViewController(orgId: orgId)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.toolbar.isHidden = true
            navigationController.setNavigationBarHidden(true, animated: false)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true) {
                resolve?(true)
            }
        }
    }
}
