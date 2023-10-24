import WebKit

public struct CommandBar {
  func openHelpHub(resolve: @escaping (() -> Void),reject: @escaping (() -> Void)) -> Void {
      DispatchQueue.main.async {
      let viewController = HelpHubViewController()
      let navigationController = UINavigationController(rootViewController: viewController)
          navigationController.modalPresentationStyle = .pageSheet
          navigationController.toolbar.isHidden = true
          navigationController.setNavigationBarHidden(true, animated: false)
        
      UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    resolve()
  }
}
