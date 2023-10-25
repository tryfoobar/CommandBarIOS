import UIKit
import WebKit

public class HelpHubViewController: UIViewController {
    var helpHubView: HelpHubWebView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureHelpHubView()
    }

    private func configureHelpHubView() {
        helpHubView = HelpHubWebView()
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
