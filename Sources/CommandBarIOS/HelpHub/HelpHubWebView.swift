import UIKit
import WebKit

public class HelpHubWebView: WKWebView, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    public var articleId: Int? = nil
    public var options: CommandBarOptions_Deprecated? = nil {
        didSet {
            self.loadContent()
        }
    }

    private var debug: Bool = true

    public weak var delegate: HelpHubWebViewDelegate?
    
    public init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        navigationDelegate = self
        uiDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadContent() {
        configuration.userContentController.add(self, name: "commandbar__onFallbackAction")
        configuration.userContentController.add(self, name: "commandbar__log")

        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        guard let options = self.options else {
            return
        }
        
        // Before iOS 16.4, webviews are always inspectable
        #if compiler(>=5.8) && os(iOS)
          if #available(iOS 16.4, *) {
            self.isInspectable = debug
          }
        #endif

        let html = """
            <!DOCTYPE html>
            <html>
              <head>
                  <meta name="viewport" content="user-scalable=no, width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
                  <style>
                      .loading-container {
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          width: 100%;
                          height: 100%;
                      }
                      .lds-ring {
                        display: inline-block;
                        position: relative;
                        width: 80px;
                        height: 80px;
                      }
                      .lds-ring div {
                        box-sizing: border-box;
                        display: block;
                        position: absolute;
                        width: 64px;
                        height: 64px;
                        margin: 8px;
                        border: 8px solid \(options.spinnerColor);
                        border-radius: 50%;
                        animation: lds-ring 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
                        border-color: \(options.spinnerColor) transparent transparent transparent;
                      }
                      .lds-ring div:nth-child(1) {
                        animation-delay: -0.45s;
                      }
                      .lds-ring div:nth-child(2) {
                        animation-delay: -0.3s;
                      }
                      .lds-ring div:nth-child(3) {
                        animation-delay: -0.15s;
                      }
                      @keyframes lds-ring {
                        0% {
                          transform: rotate(0deg);
                        }
                        100% {
                          transform: rotate(360deg);
                        }
                      }

                      #helphub-close-button {
                          display: none !important;
                      }
                      
                      #copilot-container:not(:focus-within) {
                          padding-bottom: 50px;
                      }
                  </style>
              </head>
              <body>
                  <div class="loading-container"><div class="lds-ring"><div></div><div></div><div></div><div></div></div></div>
              </body>
            </html>
        """
        loadHTMLString(html, baseURL: URL(string: "http://api.commandbar.com"))
    }

    private func loadSnippet() {
        guard let options = self.options else {
            return
        }

        let userId = options.userId == nil ? "null" : "\"\(options.userId!)\""
        let executable = self.articleId == nil ? "window.CommandBar.openHelpHub()" : "window.CommandBar.openHelpHub({ articleId: \(self.articleId!) })"
        let snippet = """
            (function() {
                    window._cbIsWebView = true;
                    var o="\(options.orgId)",n=["Object.assign","Symbol","Symbol.for"].join("%2C"),a=window;function t(o,n){void 0===n&&(n=!1),"complete"!==document.readyState&&window.addEventListener("load",t.bind(null,o,n),{capture:!1,once:!0});var a=document.createElement("script");a.type="text/javascript",a.async=n,a.src=o,document.head.appendChild(a)}function r(){var n;if(void 0===a.CommandBar){delete a.__CommandBarBootstrap__;var r=Symbol.for("CommandBar::configuration"),e=Symbol.for("CommandBar::orgConfig"),c=Symbol.for("CommandBar::disposed"),i=Symbol.for("CommandBar::isProxy"),m=Symbol.for("CommandBar::queue"),l=Symbol.for("CommandBar::unwrap"),d=[],s="api=\(options.launchCode);commandbar=\(options.launchCode)",u=s&&s.includes("local")?"http://localhost:8000":"https://api.commandbar.com",f=Object.assign(((n={})[r]={uuid:o},n[e]={},n[c]=!1,n[i]=!0,n[m]=new Array,n[l]=function(){return f},n),a.CommandBar),p=["addCommand","boot"],y=f;Object.assign(f,{shareCallbacks:function(){return{}},shareContext:function(){return{}}}),a.CommandBar=new Proxy(f,{get:function(o,n){return n in y?f[n]:p.includes(n)?function(){var o=Array.prototype.slice.call(arguments);return new Promise((function(a,t){o.unshift(n,a,t),f[m].push(o)}))}:function(){var o=Array.prototype.slice.call(arguments);o.unshift(n),f[m].push(o)}}}),null!==s&&d.push("lc=".concat(s)),d.push("version=2"),t("".concat(u,"/latest/").concat(o,"?").concat(d.join("&")),!0)}}void 0===Object.assign||"undefined"==typeof Symbol||void 0===Symbol.for?(a.__CommandBarBootstrap__=r,t("https://polyfill.io/v3/polyfill.min.js?version=3.101.0&callback=__CommandBarBootstrap__&features="+n)):r();
                    window.CommandBar.boot(\(userId), {}, { products: ["help_hub"] });
                    \(executable)
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

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadSnippet()
    }
    
    // MARK: - WKUIDelegate
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        
        if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            CommandBarSDK.shared.closeHelpHub()
            UIApplication.shared.open(url)
            
        }
        
        return nil
    }

    // MARK: - WKScriptMessageHandler

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let actionStr = message.body as? String else {
            return
        }
        
        // Debug Logging for local development
        if message.name == "commandbar__log" {
            print(message.body)
            return
        }
        
        if let jsonData = actionStr.data(using: .utf8) {
            do {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    self.delegate?.didTriggerCopilotFallback(jsonDictionary)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

public protocol HelpHubWebViewDelegate: AnyObject {
    func didTriggerCopilotFallback(_ action: [String: Any])
}
