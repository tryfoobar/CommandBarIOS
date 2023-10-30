import UIKit
import WebKit

public class HelpHubViewController: UIViewController {
    var helpHubView: HelpHubWebView!
    private var options: CommandBarOptions
    public var delegate: HelpHubWebViewDelegate? // Add this property

    public init(options: CommandBarOptions) {
        self.options = options
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
        helpHubView = HelpHubWebView(frame: CGRect.zero, options: self.options)
        helpHubView.delegate = self
        view.addSubview(helpHubView)
        helpHubView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            helpHubView.topAnchor.constraint(equalTo: view.topAnchor),
            helpHubView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            helpHubView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            helpHubView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        helpHubView.loadContent()
    }
}

extension HelpHubViewController : HelpHubWebViewDelegate {
    public func didReceiveFallbackAction(_ action: [String : Any]) {
        self.delegate?.didReceiveFallbackAction(action)
    }
}
