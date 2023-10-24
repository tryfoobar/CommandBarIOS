import UIKit
import WebKit

class HelpHubViewController: UIViewController {
    var helpHubView: HelpHubWebView!

    override func viewDidLoad() {
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

class HelpHubWebView: WKWebView, WKNavigationDelegate, WKScriptMessageHandler {
    // TODO: Make these configurable
    private var orgId: String = "foocorp"
    private var launchCode: String = "local-dev"
    private var userId: String = "1234"
    private var debug: Bool = true

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadContent() {
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "onOpenSupportChat")

        configuration.userContentController = userContentController
        configuration.websiteDataStore = WKWebsiteDataStore.default()

        // Before iOS 16.4, webviews are always inspectable
        if #available(iOS 16.4, *) {
            isInspectable = debug
        }

        let html = """
            <head>
                <meta name="viewport" content="user-scalable=no, width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
                <style>
                    #helphub-close-button {
                        display: none !important;
                    }
                    
                    #copilot-container:not(:focus-within) {
                        padding-bottom: 50px;
                    }
                </style>
            </head>
            <body>
                <div></div>
            </body>
        """
        loadHTMLString(html, baseURL: URL(string: "http://api.commandbar.com"))
    }

    private func loadSnippet() {
        let snippet = """
            (function() {
                    var o="\(self.orgId)",n=["Object.assign","Symbol","Symbol.for"].join("%2C"),a=window;function t(o,n){void 0===n&&(n=!1),"complete"!==document.readyState&&window.addEventListener("load",t.bind(null,o,n),{capture:!1,once:!0});var a=document.createElement("script");a.type="text/javascript",a.async=n,a.src=o,document.head.appendChild(a)}function r(){var n;if(void 0===a.CommandBar){delete a.__CommandBarBootstrap__;var r=Symbol.for("CommandBar::configuration"),e=Symbol.for("CommandBar::orgConfig"),c=Symbol.for("CommandBar::disposed"),i=Symbol.for("CommandBar::isProxy"),m=Symbol.for("CommandBar::queue"),l=Symbol.for("CommandBar::unwrap"),d=[],s="\(self.launchCode)",u=s&&s.includes("local")?"http://localhost:8000":"https://api.commandbar.com",f=Object.assign(((n={})[r]={uuid:o},n[e]={},n[c]=!1,n[i]=!0,n[m]=new Array,n[l]=function(){return f},n),a.CommandBar),p=["addCommand","boot"],y=f;Object.assign(f,{shareCallbacks:function(){return{}},shareContext:function(){return{}}}),a.CommandBar=new Proxy(f,{get:function(o,n){return n in y?f[n]:p.includes(n)?function(){var o=Array.prototype.slice.call(arguments);return new Promise((function(a,t){o.unshift(n,a,t),f[m].push(o)}))}:function(){var o=Array.prototype.slice.call(arguments);o.unshift(n),f[m].push(o)}}}),null!==s&&d.push("lc=".concat(s)),d.push("version=2"),t("".concat(u,"/latest/").concat(o,"?").concat(d.join("&")),!0)}}void 0===Object.assign||"undefined"==typeof Symbol||void 0===Symbol.for?(a.__CommandBarBootstrap__=r,t("https://polyfill.io/v3/polyfill.min.js?version=3.101.0&callback=__CommandBarBootstrap__&features="+n)):r();
                    window.CommandBar.boot("\(self.userId)", { products: ["help_hub"] });
                    window.CommandBar.openHelpHub();
            })();
        """

        evaluateJavaScript(snippet) { (result, error) in
            guard error == nil else {
                // TODO: Throw this error
                print(error ?? "Unknown error")
                return
            }
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadSnippet()
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
        guard let dict = message.body as? [String: Any] else {
            return
        }

        // TODO: Bubble this event up
        print(dict)
    }
}
