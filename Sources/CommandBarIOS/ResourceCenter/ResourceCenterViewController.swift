import UIKit
import WebKit

public class ResourceCenterViewController: UIViewController {
    var resourceCenterView: ResourceCenterWebView!
    private var options: CommandBarOptions_Deprecated
    public var delegate: ResourceCenterWebViewDelegate?
    private var fallbackAction: ((String) -> Void)?
    private var articleId: Int?
    private var engagementInitialPage: String

    public init(
        options: CommandBarOptions_Deprecated,
        articleId: Int? = nil,
        engagementInitialPage: String = "help-hub",
        fallbackAction: ((String) -> Void)? = nil
    ) {
        self.options = options
        self.articleId = articleId
        self.engagementInitialPage = engagementInitialPage
        self.fallbackAction = fallbackAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureResourceCenterView()
    }

    private func configureResourceCenterView() {
        resourceCenterView = ResourceCenterWebView(frame: self.view.frame)
        resourceCenterView.delegate = self
        resourceCenterView.articleId = self.articleId
        resourceCenterView.engagementInitialPage = self.engagementInitialPage
        resourceCenterView.options = self.options
        
        view.addSubview(resourceCenterView)
        resourceCenterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resourceCenterView.topAnchor.constraint(equalTo: view.topAnchor),
            resourceCenterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resourceCenterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resourceCenterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
}

extension ResourceCenterViewController : ResourceCenterWebViewDelegate {
    public func didTriggerAssistantFallback(_ action: [String : Any]) {
        let meta = action["meta"] as? [String: Any] ?? [:]
        let type = meta["type"] as? String ?? ""
        
        if (self.fallbackAction != nil) {
            self.fallbackAction!(type)
        }
    }
}
