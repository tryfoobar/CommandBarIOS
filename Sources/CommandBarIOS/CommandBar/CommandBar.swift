import Foundation
import WebKit

class CommandBar {
    private var options: CommandBarOptions_Deprecated;
    
    weak var delegate: HelpHubWebViewDelegate? // Add this property
    private weak var presentedNavigationController: UINavigationController? // Add this property
    
    init(options: CommandBarOptions_Deprecated) {
        self.options = options
    }

    func openHelpHub() {
        DispatchQueue.main.async {
            let viewController = HelpHubViewController(options: self.options)
            viewController.delegate = self

            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.toolbar.isHidden = true
            navigationController.setNavigationBarHidden(true, animated: false)
            self.presentedNavigationController = navigationController
            
            UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true)
        }
    }
    
    func closeHelpHub() {
        presentedNavigationController?.dismiss(animated: true, completion: nil)
        presentedNavigationController = nil
    }
}

extension CommandBar : HelpHubWebViewDelegate {
    func didReceiveFallbackAction(_ action: [String : Any]) {
        self.delegate?.didReceiveFallbackAction(action)
    }
}
