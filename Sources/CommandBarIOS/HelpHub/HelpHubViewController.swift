import UIKit
import WebKit

public class HelpHubViewController: UIViewController {
    var helpHubView: HelpHubWebView!
    private var options: CommandBarOptions_Deprecated
    public var delegate: HelpHubWebViewDelegate?
    private var fallbackAction: ((String) -> Void)?
    private var articleId: Int?

    public init(options: CommandBarOptions_Deprecated, articleId: Int? = nil, fallbackAction: ((String) -> Void)? = nil) {
        self.options = options
        self.articleId = articleId
        self.fallbackAction = fallbackAction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureHelpHubView()
    }

    private func configureHelpHubView() {
        helpHubView = HelpHubWebView(frame: self.view.frame)
        helpHubView.delegate = self
        helpHubView.articleId = self.articleId
        helpHubView.options = self.options
        
        view.addSubview(helpHubView)
        helpHubView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            helpHubView.topAnchor.constraint(equalTo: view.topAnchor),
            helpHubView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            helpHubView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            helpHubView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
}

extension HelpHubViewController : HelpHubWebViewDelegate {
    public func didTriggerCopilotFallback(_ action: [String : Any]) {
        let meta = action["meta"] as? [String: Any] ?? [:]
        let type = meta["type"] as? String ?? ""
        
        if (self.fallbackAction != nil) {
            self.fallbackAction!(type)
        }
    }
}
