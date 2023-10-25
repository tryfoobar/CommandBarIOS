import WebKit

public struct CommandBar {
    public static func openHelpHub(resolve: (() -> Void)? = nil, reject: (() -> Void)? = nil) {
      DispatchQueue.main.async {
          let viewController = HelpHubViewController()
          let navigationController = UINavigationController(rootViewController: viewController)
              navigationController.modalPresentationStyle = .pageSheet
              navigationController.toolbar.isHidden = true
              navigationController.setNavigationBarHidden(true, animated: false)
            
          UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: resolve)
        }
  }
}
