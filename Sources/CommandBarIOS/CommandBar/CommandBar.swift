import Foundation
import WebKit

public class CommandBar_Deprecated {
    private var options: CommandBarOptions_Deprecated;
    
    private weak var presentedNavigationController: UINavigationController?
    
    public init(options: CommandBarOptions_Deprecated) {
        self.options = options
    }

    public func openResourceCenter(articleId: Int? = nil, fallbackAction: ((String) -> Void)? = nil) {
        DispatchQueue.main.async {
            let viewController = HelpHubViewController(
                options: self.options,
                articleId: articleId,
                engagementInitialPage: "help-hub",
                fallbackAction: fallbackAction
            )

            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.toolbar.isHidden = true
            navigationController.setNavigationBarHidden(true, animated: false)
            self.presentedNavigationController = navigationController

            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true)
        }
    }

    public func openAssistant(fallbackAction: ((String) -> Void)? = nil) {
        DispatchQueue.main.async {
            let viewController = HelpHubViewController(
                options: self.options,
                articleId: nil,
                engagementInitialPage: "assistant",
                fallbackAction: fallbackAction
            )

            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.toolbar.isHidden = true
            navigationController.setNavigationBarHidden(true, animated: false)
            self.presentedNavigationController = navigationController

            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true)
        }
    }

    public func closeResourceCenter() {
        presentedNavigationController?.dismiss(animated: true, completion: nil)
        presentedNavigationController = nil
    }
}
