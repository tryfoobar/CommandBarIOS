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

    /// Avoid crashing when `loadContent()` runs more than once (duplicate handler names are invalid).
    private var didInstallScriptHandlers: Bool = false

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
        if !didInstallScriptHandlers {
            configuration.userContentController.add(self, name: "engagement__onFallbackAction")
            configuration.userContentController.add(self, name: "onHelpHubClose")
            configuration.userContentController.add(self, name: "engagement__log")
            didInstallScriptHandlers = true
        }

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

                      /* Help Hub shell for WKWebView: fill viewport and stack SDK UI above the native spinner */
                      html, body {
                          margin: 0;
                          padding: 0;
                          width: 100%;
                          height: 100%;
                          min-height: 100%;
                          background-color: #ffffff;
                      }
                      .loading-container {
                          position: fixed;
                          inset: 0;
                          z-index: 1;
                          pointer-events: none;
                          background-color: transparent;
                      }
                      #engagement-wrapper {
                          position: relative;
                          z-index: 2147483000;
                          min-height: 100%;
                      }
                  </style>
              </head>
              <body>
                <div class="loading-container"><div class="lds-ring"><div></div><div></div><div></div><div></div></div></div>
              </body>
            </html>
        """
        loadHTMLString(html, baseURL: URL(string: "https://cdn.amplitude.com"))
    }

    private func escapeForEmbeddedJs(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
    }

    private func loadSnippet() {
        guard let options = self.options else {
            return
        }

        let apiKeyJs = "\"\(escapeForEmbeddedJs(options.orgId))\""
        let userIdJs: String
        if let uid = options.userId {
            userIdJs = "\"\(escapeForEmbeddedJs(uid))\""
        } else {
            userIdJs = "null"
        }
        let articleIdJs = self.articleId.map { String($0) } ?? "null"
        let launchCodeJs = escapeForEmbeddedJs(options.launchCode)
        let serverZoneJs = escapeForEmbeddedJs(options.serverZone.uppercased() == "EU" ? "EU" : "US")
        let snippet = """
            (function() {
                window._cbIsWebView = true;

                function ampLog(msg) {
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.engagement__log) {
                            window.webkit.messageHandlers.engagement__log.postMessage(String(msg));
                        }
                    } catch (e) {}
                    try { console.log(msg); } catch (e2) {}
                }

                /** Dedicated bridge so native always dismisses the sheet (payload-less). */
                function notifyNativeHelpHubClosed() {
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.onHelpHubClose) {
                            window.webkit.messageHandlers.onHelpHubClose.postMessage(null);
                            return;
                        }
                    } catch (eDedicated) {}
                    var payload = JSON.stringify({ meta: { type: "close" } });
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.engagement__onFallbackAction) {
                            window.webkit.messageHandlers.engagement__onFallbackAction.postMessage(payload);
                        }
                    } catch (eFallback) {}
                }

                function isHelpHubCloseElement(el) {
                    if (!el || typeof el.getAttribute !== "function") { return false; }
                    var tag = (el.tagName || "").toUpperCase();
                    var role = (el.getAttribute("role") || "").toLowerCase();
                    var label = el.getAttribute("aria-label") || "";
                    if (!/^close$/i.test(label)) { return false; }
                    return tag === "BUTTON" || role === "button";
                }

                function eventIndicatesHelpHubClose(ev) {
                    var path = typeof ev.composedPath === "function" ? ev.composedPath() : [];
                    var i = 0;
                    for (i = 0; i < path.length; i++) {
                        if (isHelpHubCloseElement(path[i])) { return true; }
                    }
                    var t = ev.target;
                    if (t && typeof t.closest === "function") {
                        if (t.closest('button[aria-label="close"], button[aria-label="Close"], [role="button"][aria-label="close"], [role="button"][aria-label="Close"]')) {
                            return true;
                        }
                    }
                    return false;
                }

                /** RC header close uses aria-label="close" (StyledResourceCenterModalHeader). Install before engagement boot guard. */
                function installNativeHelpHubCloseBridge() {
                    if (window.__ampNativeHelpHubCloseBridge) { return; }
                    window.__ampNativeHelpHubCloseBridge = true;
                    var fired = false;
                    function relay(ev) {
                        if (fired || !eventIndicatesHelpHubClose(ev)) { return; }
                        fired = true;
                        notifyNativeHelpHubClosed();
                    }
                    document.addEventListener("pointerdown", relay, true);
                    document.addEventListener("click", relay, true);
                    document.addEventListener("touchend", relay, true);
                }
                installNativeHelpHubCloseBridge();

                if (window.__ampMobileHelpHubLoaded) { return; }

                var apiKey = \(apiKeyJs);
                var serverZone = "\(serverZoneJs)";
                var userIdRaw = \(userIdJs);
                var articleId = \(articleIdJs);
                var launchCode = "\(launchCodeJs)";
                var localDevHost = "localhost";

                function loadScript(src, async, onload, onerror) {
                    var s = document.createElement("script");
                    s.type = "text/javascript";
                    s.async = !!async;
                    s.src = src;
                    if (onload) { s.onload = onload; }
                    if (onerror) { s.onerror = onerror; }
                    document.head.appendChild(s);
                }

                function withPolyfills(done) {
                    var feats = ["Object.assign","Symbol","Symbol.for"].join("%2C");
                    if (typeof Object.assign !== "undefined" && typeof Symbol !== "undefined" && Symbol.for) {
                        done();
                    } else {
                        window.__AmpEngagementPolyDone__ = done;
                        loadScript("https://polyfill.io/v3/polyfill.min.js?version=3.101.0&callback=__AmpEngagementPolyDone__&features=" + feats, false, null, null);
                    }
                }

                function engagementScriptUrl() {
                    var cdnBase = serverZone === "EU" ? "https://cdn.eu.amplitude.com" : "https://cdn.amplitude.com";
                    return cdnBase + "/script/" + encodeURIComponent(apiKey) + ".engagement.js";
                }

                function engagementInitOptions() {
                    var o = { serverZone: serverZone === "EU" ? "EU" : "US" };
                    if (launchCode === "local") {
                        o.serverUrl = "http://" + localDevHost + ":8000";
                        o.cdnUrl = "http://" + localDevHost + ":8000";
                    }
                    return o;
                }

                function buildUser() {
                    if (userIdRaw) {
                        return { user_id: userIdRaw };
                    }
                    try {
                        var k = "__amp_engagement_wv_device";
                        var id = sessionStorage.getItem(k);
                        if (!id) {
                            id = (window.crypto && window.crypto.randomUUID) ? window.crypto.randomUUID() : ("wv-" + Date.now() + "-" + Math.random());
                            sessionStorage.setItem(k, id);
                        }
                        return { device_id: id };
                    } catch (e) {
                        return { device_id: "wv-" + Date.now() + "-" + Math.random() };
                    }
                }

                function hideNativeLoadingSpinner() {
                    var els = document.querySelectorAll(".loading-container");
                    for (var i = 0; i < els.length; i++) {
                        els[i].style.display = "none";
                    }
                }

                function openHelpHub() {
                    hideNativeLoadingSpinner();
                    var opts = { initialPage: "help-hub" };
                    if (articleId !== null && articleId !== undefined) {
                        opts.contentItemId = articleId;
                    }
                    try {
                        window.dispatchEvent(new Event("resize"));
                    } catch (e1) {}
                    requestAnimationFrame(function () {
                        requestAnimationFrame(function () {
                            try {
                                window.engagement._showResourceCenter(true, opts);
                                try {
                                    window.dispatchEvent(new Event("resize"));
                                } catch (e2) {}
                            } catch (e3) {
                                ampLog("[Amplitude Engagement] _showResourceCenter: " + e3);
                            }
                            window.__ampMobileHelpHubLoaded = true;
                        });
                    });
                }

                function tryBootAfterEngagementScript() {
                    var attempts = 0;
                    var maxAttempts = 120;
                    function tick() {
                        attempts++;
                        try {
                            if (!window.engagement || typeof window.engagement.boot !== "function") {
                                if (attempts >= maxAttempts) {
                                    ampLog("[Amplitude Engagement] Timed out waiting for engagement SDK after script load. URL: " + engagementScriptUrl());
                                    return;
                                }
                                setTimeout(tick, 100);
                                return;
                            }
                            window.engagement.init(apiKey, engagementInitOptions());
                            var p = window.engagement.boot({
                                user: buildUser(),
                                integrations: [{ track: function () {} }]
                            });
                            if (p && typeof p.then === "function") {
                                p.then(function () {
                                    openHelpHub();
                                }).catch(function (err) {
                                    ampLog("[Amplitude Engagement] boot failed: " + err);
                                });
                            } else {
                                openHelpHub();
                            }
                        } catch (e) {
                            ampLog("[Amplitude Engagement] boot setup failed: " + e);
                        }
                    }
                    tick();
                }

                function start() {
                    var src = engagementScriptUrl();
                    loadScript(src, false, function () {
                        tryBootAfterEngagementScript();
                    }, function () {
                        ampLog("[Amplitude Engagement] Failed to load script: " + src);
                    });
                }

                withPolyfills(start);
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
        let bodyDescription: String
        if let s = message.body as? String {
            bodyDescription = s
        } else {
            bodyDescription = String(describing: message.body)
        }

        // Debug Logging for local development (also used by injected JS for Amplitude load diagnostics).
        if message.name == "engagement__log" {
            print("\(bodyDescription)")
            return
        }

        if message.name == "onHelpHubClose" {
            DispatchQueue.main.async {
                CommandBarSDK.shared.closeHelpHub()
            }
            return
        }

        guard message.name == "engagement__onFallbackAction" else {
            return
        }

        if let dict = message.body as? [String: Any] {
            if let meta = dict["meta"] as? [String: Any],
               let typ = meta["type"] as? String,
               typ == "close" {
                DispatchQueue.main.async {
                    CommandBarSDK.shared.closeHelpHub()
                }
            }
            self.delegate?.didTriggerCopilotFallback(dict)
            return
        }

        let actionStr = bodyDescription

        if let jsonData = actionStr.data(using: .utf8) {
            do {
                if let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    if let meta = jsonDictionary["meta"] as? [String: Any],
                       let typ = meta["type"] as? String,
                       typ == "close" {
                        DispatchQueue.main.async {
                            CommandBarSDK.shared.closeHelpHub()
                        }
                    }
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
