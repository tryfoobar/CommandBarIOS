import Foundation
import UIKit

public protocol CommandBarSDKDelegate: AnyObject {}
extension CommandBarSDKDelegate {
    public func didTriggerAssistantFallback(withType type: String) {}
}

/// Public entry point for the Amplitude Engagement WebView SDK on iOS.
///
/// Lifecycle:
/// 1. Call `boot(options:)` once at app start with your `CommandBarOptions`.
/// 2. Call `openResourceCenter` / `openAssistant` later — they use the booted options.
public final class CommandBarSDK {
    public static let shared = CommandBarSDK()

    public weak var delegate: CommandBarSDKDelegate?

    /// Configuration stored by the most recent `boot(options:)` call. Used by every
    /// subsequent `openResourceCenter` / `openAssistant`.
    public private(set) var bootOptions: CommandBarOptions?

    private weak var presentedNavigationController: UINavigationController?

    public init() {}

    /// Stores the configuration used by subsequent `openResourceCenter` / `openAssistant` calls.
    /// Safe to call again to swap configuration (e.g. after the user signs in).
    public func boot(options: CommandBarOptions) {
        self.bootOptions = options
    }

    /// Presents the Resource Center as a page sheet. Requires `boot(options:)` to have been called first.
    public func openResourceCenter(
        articleId: Int? = nil,
        fallbackAction: ((String) -> Void)? = nil
    ) {
        guard let options = self.bootOptions else {
            print("[CommandBarSDK] openResourceCenter called before boot(options:); no-op.")
            return
        }
        presentEngagementShell(
            options: options,
            articleId: articleId,
            engagementShell: "resource-center",
            engagementInitialPage: "help-hub",
            fallbackAction: fallbackAction
        )
    }

    /// Presents the Assistant chat as a page sheet. Requires `boot(options:)` to have been called first.
    public func openAssistant(
        fallbackAction: ((String) -> Void)? = nil
    ) {
        guard let options = self.bootOptions else {
            print("[CommandBarSDK] openAssistant called before boot(options:); no-op.")
            return
        }
        presentEngagementShell(
            options: options,
            articleId: nil,
            engagementShell: "assistant",
            engagementInitialPage: "help-hub",
            fallbackAction: fallbackAction
        )
    }

    /// Dismisses the presented engagement sheet (Resource Center or Assistant), if any.
    /// The injected WebView bridge picks the correct web-side teardown based on the
    /// active shell, so this method works regardless of which `open*` was used.
    public func closeResourceCenter() {
        ResourceCenterWebView.activeInstance?.closeEngagementShell()
        presentedNavigationController?.dismiss(animated: true, completion: nil)
        presentedNavigationController = nil
    }

    /// Symmetric alias for `closeResourceCenter()`. Both methods dismiss whichever
    /// engagement sheet (Resource Center or Assistant) is currently presented.
    public func closeAssistant() {
        closeResourceCenter()
    }

    /// Mirrors `window.engagement.assistant.setAssistantFilter`. Pass `nil` to clear.
    public func setAssistantFilter(_ filter: [String: Any]?) {
        EngagementFilterStore.setAssistantFilter(filter)
        ResourceCenterWebView.activeInstance?.applyEngagementFilters()
    }

    /// Mirrors `window.engagement.setResourceCenterFilter`. Pass `nil` to clear.
    public func setResourceCenterFilter(_ filter: [String: Any]?) {
        EngagementFilterStore.setResourceCenterFilter(filter)
        ResourceCenterWebView.activeInstance?.applyEngagementFilters()
    }

    private func presentEngagementShell(
        options: CommandBarOptions,
        articleId: Int?,
        engagementShell: String,
        engagementInitialPage: String,
        fallbackAction: ((String) -> Void)?
    ) {
        DispatchQueue.main.async {
            let viewController = ResourceCenterViewController(
                options: options,
                articleId: articleId,
                engagementShell: engagementShell,
                engagementInitialPage: engagementInitialPage,
                fallbackAction: fallbackAction
            )

            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .pageSheet
            navigationController.toolbar.isHidden = true
            navigationController.setNavigationBarHidden(true, animated: false)
            self.presentedNavigationController = navigationController

            UIApplication.shared.keyWindow?.rootViewController?.present(
                navigationController,
                animated: true
            )
        }
    }
}
