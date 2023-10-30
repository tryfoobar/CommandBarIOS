import WebKit

public class CommandBar {
    private var orgId: String;
    public weak var delegate: HelpHubWebViewDelegate? // Add this property
    private weak var presentedNavigationController: UINavigationController? // Add this property
    
    public init(orgId: String) {
        self.orgId = orgId
    }

    public func openHelpHub(resolve: ((Any?) -> Void)? = nil, reject: ((Any?) -> Void)? = nil) {
        DispatchQueue.main.async {
            let viewController = HelpHubViewController(orgId: self.orgId)
            viewController.delegate = self

            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.toolbar.isHidden = true
            navigationController.setNavigationBarHidden(true, animated: false)
            self.presentedNavigationController = navigationController
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true) {
                resolve?(true)
            }
        }
    }
    
    public func closeHelpHub() {
        presentedNavigationController?.dismiss(animated: true, completion: nil)
        presentedNavigationController = nil
    }
}

extension CommandBar : HelpHubWebViewDelegate {
    public func didReceiveFallbackAction(_ action: [String : Any]) {
        self.delegate?.didReceiveFallbackAction(action)
    }
}
