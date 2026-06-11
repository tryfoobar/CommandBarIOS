import UIKit
import WebKit

public class ResourceCenterWebView: WKWebView, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    public var articleId: Int? = nil
    /// `"resource-center"` uses `_showResourceCenter`; `"assistant"` uses `engagement.assistant.show({ initialPage: "chat" })` / `close()`.
    public var engagementShell: String = "resource-center"
    public var engagementInitialPage: String = "help-hub"
    public var options: CommandBarOptions? = nil {
        didSet {
            self.loadContent()
        }
    }

    private var debug: Bool = true

    /// Avoid crashing when `loadContent()` runs more than once (duplicate handler names are invalid).
    private var didInstallScriptHandlers: Bool = false

    public weak var delegate: ResourceCenterWebViewDelegate?

    /// Active Resource Center WebView, used to apply filter updates while the sheet is open.
    public static weak var activeInstance: ResourceCenterWebView?

    /// Extra top inset for page-sheet presentation so content clears rounded sheet corners (e.g. iOS 18+).
    public static let sheetTopContentInset: CGFloat = 20
    
    public init(frame: CGRect) {
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        navigationDelegate = self
        uiDelegate = self
        ResourceCenterWebView.activeInstance = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if ResourceCenterWebView.activeInstance === self {
            ResourceCenterWebView.activeInstance = nil
        }
    }

    /// Applies the latest native tag filters to a booted engagement instance.
    func applyEngagementFilters() {
        evaluateJavaScript(Self.buildApplyEngagementFiltersJavaScript(), completionHandler: nil)
    }

    /// Tears down the in-WebView engagement UI (`assistant.close()` or hide Resource Center).
    func closeEngagementShell() {
        evaluateJavaScript(Self.buildCloseEngagementShellJavaScript(), completionHandler: nil)
    }

    private static func buildCloseEngagementShellJavaScript() -> String {
        """
            (function() {
                var shell = window.__ampEngagementShell || "resource-center";
                if (shell === "assistant") {
                    try {
                        if (window.engagement && window.engagement.assistant && typeof window.engagement.assistant.close === "function") {
                            window.engagement.assistant.close();
                        }
                    } catch (e1) {}
                    return;
                }
                try {
                    if (window.engagement && typeof window.engagement._showResourceCenter === "function") {
                        window.engagement._showResourceCenter(false);
                    }
                } catch (e2) {}
            })();
            """
    }

    private static func buildApplyEngagementFiltersJavaScript() -> String {
        let rc = EngagementFilterStore.resourceCenterFilterJsonLiteral
        let assistant = EngagementFilterStore.assistantFilterJsonLiteral
        // We always mutate the `window.__ampNativeRCFilter` / `__ampNativeAssistantFilter`
        // globals so the boot-time snippet picks up the latest value when it runs
        // `applyNativeEngagementFilters()` after `engagement.boot()` resolves. This avoids
        // a race where the native filter was updated between WebView construction and
        // engagement boot completion. If engagement is already booted, we also push the
        // change live. `null` (clear) propagates through both paths intentionally.
        return """
            (function() {
                window.__ampNativeRCFilter = \(rc);
                window.__ampNativeAssistantFilter = \(assistant);
                try {
                    if (window.engagement && typeof window.engagement.setResourceCenterFilter === 'function') {
                        window.engagement.setResourceCenterFilter(window.__ampNativeRCFilter);
                    }
                } catch (e1) {}
                try {
                    if (window.engagement && window.engagement.assistant && typeof window.engagement.assistant.setAssistantFilter === 'function') {
                        window.engagement.assistant.setAssistantFilter(window.__ampNativeAssistantFilter);
                    }
                } catch (e2) {}
            })();
            """
    }

    /// Builds `<link>` tags that preload the given Google Font families. The WebView has no host
    /// page to load fonts, so a theme using a non-system family only renders if we fetch it here.
    /// Returns an empty string when no families are supplied.
    private static func buildFontPreloadLinks(_ families: [String]) -> String {
        families
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { family in
                let encoded = (family.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? family)
                    .replacingOccurrences(of: "%20", with: "+")
                return "<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css2?family=\(encoded)&display=swap\">"
            }
            .joined(separator: "\n                  ")
    }

    func loadContent() {
        if !didInstallScriptHandlers {
            configuration.userContentController.add(self, name: "engagement__onFallbackAction")
            configuration.userContentController.add(self, name: "onResourceCenterClose")
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

        let topPaddingPx = Int(Self.sheetTopContentInset)
        let fontLinks = Self.buildFontPreloadLinks(options.fontFamilies)
        let html = """
            <!DOCTYPE html>
            <html>
              <head>
                  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no, viewport-fit=cover">
                  <link rel="preconnect" href="https://fonts.googleapis.com">
                  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                  \(fontLinks)
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

                      /* Hide the Resource Center "Copy link" header button in the mobile WebView only. */
                      [data-testid="resource-center-copy-link"] {
                          display: none !important;
                      }

                      #copilot-container:not(:focus-within) {
                          padding-bottom: 50px;
                      }

                      /* Resource Center shell: pad below rounded page-sheet top edge */
                      html, body {
                          margin: 0;
                          padding: 0;
                          padding-top: calc(\(topPaddingPx)px + env(safe-area-inset-top, 0px));
                          width: 100%;
                          height: 100%;
                          min-height: 100%;
                          background-color: #ffffff;
                          box-sizing: border-box;
                      }
                      .loading-container {
                          position: fixed;
                          top: calc(\(topPaddingPx)px + env(safe-area-inset-top, 0px));
                          right: 0;
                          bottom: 0;
                          left: 0;
                          z-index: 1;
                          pointer-events: none;
                          background-color: transparent;
                      }
                      #engagement-wrapper {
                          position: relative;
                          z-index: 2147483000;
                          min-height: 100%;
                          box-sizing: border-box;
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

    /// Renders a Swift `String?` as a JS string literal or `null` so it can be embedded into the snippet.
    private static func jsStringOrNull(_ value: String?) -> String {
        guard let value = value else { return "null" }
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        return "\"\(escaped)\""
    }

    /// Serializes a `CommandBarOptions.User` to the `{ user_id, device_id }` JSON shape the web SDK expects,
    /// or `null` when no identity was supplied.
    private static func buildNativeUserJsLiteral(from user: CommandBarOptions.User?) -> String {
        guard let user = user, (user.userId != nil) || (user.deviceId != nil) else {
            return "null"
        }
        var parts: [String] = []
        if let uid = user.userId { parts.append("\"user_id\":\(jsStringOrNull(uid))") }
        if let did = user.deviceId { parts.append("\"device_id\":\(jsStringOrNull(did))") }
        return "{\(parts.joined(separator: ","))}"
    }

    private func loadSnippet() {
        guard let options = self.options else {
            return
        }

        let apiKeyJs = "\"\(escapeForEmbeddedJs(options.apiKey))\""
        let nativeUserJs = Self.buildNativeUserJsLiteral(from: options.user)
        let articleIdJs = self.articleId.map { String($0) } ?? "null"
        let serverZoneJs = "\"\(options.serverZone.rawValue)\""
        let serverUrlJs = Self.jsStringOrNull(options.serverUrl)
        let cdnUrlJs = Self.jsStringOrNull(options.cdnUrl)
        let chatUrlJs = Self.jsStringOrNull(options.chatUrl)
        let mediaUrlJs = Self.jsStringOrNull(options.mediaUrl)
        let localeJs = Self.jsStringOrNull(options.locale)
        let engagementShellJs = escapeForEmbeddedJs(self.engagementShell)
        let engagementInitialPageJs = escapeForEmbeddedJs(self.engagementInitialPage)
        let resourceCenterFilterJs = EngagementFilterStore.resourceCenterFilterJsonLiteral
        let assistantFilterJs = EngagementFilterStore.assistantFilterJsonLiteral
        let snippet = """
            (function() {
                window._ampIsWebView = true;

                function ampLog(msg) {
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.engagement__log) {
                            window.webkit.messageHandlers.engagement__log.postMessage(String(msg));
                        }
                    } catch (e) {}
                    try { console.log(msg); } catch (e2) {}
                }

                /** Dedicated bridge so native always dismisses the sheet (payload-less). */
                function notifyNativeResourceCenterClosed() {
                    try {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.onResourceCenterClose) {
                            window.webkit.messageHandlers.onResourceCenterClose.postMessage(null);
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

                function isResourceCenterCloseElement(el) {
                    if (!el || typeof el.getAttribute !== "function") { return false; }
                    var tag = (el.tagName || "").toUpperCase();
                    var role = (el.getAttribute("role") || "").toLowerCase();
                    var label = el.getAttribute("aria-label") || "";
                    if (!/^close$/i.test(label)) { return false; }
                    if (tag !== "BUTTON" && role !== "button") { return false; }
                    // The search input's clear button shares aria-label="close" but lives inside
                    // #resource-center-input-container. Only the header close should dismiss the widget.
                    if (typeof el.closest === "function" && el.closest("#resource-center-input-container")) { return false; }
                    return true;
                }

                function eventIndicatesResourceCenterClose(ev) {
                    var path = typeof ev.composedPath === "function" ? ev.composedPath() : [];
                    var i = 0;
                    for (i = 0; i < path.length; i++) {
                        if (isResourceCenterCloseElement(path[i])) { return true; }
                    }
                    var t = ev.target;
                    if (t && typeof t.closest === "function") {
                        var btn = t.closest('button[aria-label="close"], button[aria-label="Close"], [role="button"][aria-label="close"], [role="button"][aria-label="Close"]');
                        if (btn && isResourceCenterCloseElement(btn)) { return true; }
                    }
                    return false;
                }

                /** RC header close uses aria-label="close" (StyledResourceCenterModalHeader). Install before engagement boot guard. */
                function installNativeResourceCenterCloseBridge() {
                    if (window.__ampNativeResourceCenterCloseBridge) { return; }
                    window.__ampNativeResourceCenterCloseBridge = true;
                    var fired = false;
                      function relay(ev) {
                        if (fired || !eventIndicatesResourceCenterClose(ev)) { return; }
                        fired = true;
                        closeEngagementShell();
                        notifyNativeResourceCenterClosed();
                    }
                    document.addEventListener("pointerdown", relay, true);
                    document.addEventListener("click", relay, true);
                    document.addEventListener("touchend", relay, true);
                }
                installNativeResourceCenterCloseBridge();

                if (window.__ampMobileResourceCenterLoaded) { return; }

                var apiKey = \(apiKeyJs);
                var serverZone = \(serverZoneJs);
                var nativeUser = \(nativeUserJs);
                var nativeServerUrl = \(serverUrlJs);
                var nativeCdnUrl = \(cdnUrlJs);
                var nativeChatUrl = \(chatUrlJs);
                var nativeMediaUrl = \(mediaUrlJs);
                var nativeLocale = \(localeJs);
                var articleId = \(articleIdJs);
                var engagementShell = "\(engagementShellJs)";
                window.__ampEngagementShell = engagementShell;
                var engagementInitialPage = "\(engagementInitialPageJs)";
                // Initialise the native-filter globals from the latest value the native
                // side has cached at WebView construction time. `applyEngagementFilters()`
                // (called via `evaluateJavaScript` whenever native updates the filter) will
                // overwrite these globals, so by the time `applyNativeEngagementFilters()`
                // runs after `engagement.boot()` resolves, we always read the latest value.
                window.__ampNativeRCFilter = \(resourceCenterFilterJs);
                window.__ampNativeAssistantFilter = \(assistantFilterJs);

                function applyNativeEngagementFilters() {
                    try {
                        if (window.engagement && typeof window.engagement.setResourceCenterFilter === "function") {
                            window.engagement.setResourceCenterFilter(window.__ampNativeRCFilter);
                        }
                    } catch (eRc) {}
                    try {
                        if (window.engagement && window.engagement.assistant && typeof window.engagement.assistant.setAssistantFilter === "function") {
                            window.engagement.assistant.setAssistantFilter(window.__ampNativeAssistantFilter);
                        }
                    } catch (eAsst) {}
                }

                /**
                 * The host page normally loads custom fonts (see base/public/index.html). Inside a WebView there is no host
                 * page, so any theme using a non-system family (e.g. "Inter", "IBM Plex Sans") falls back to system fonts
                 * unless we fetch the font ourselves.
                 */
                var GENERIC_FONT_NAMES = {
                    "system-ui": 1, "sans-serif": 1, "serif": 1, "monospace": 1,
                    "cursive": 1, "fantasy": 1, "ui-serif": 1, "ui-sans-serif": 1,
                    "ui-monospace": 1, "ui-rounded": 1, "inherit": 1, "initial": 1, "unset": 1,
                    "-apple-system": 1, "blinkmacsystemfont": 1,
                    "segoe ui": 1, "roboto": 1, "helvetica": 1, "arial": 1, "helvetica neue": 1,
                    "apple color emoji": 1, "segoe ui emoji": 1, "segoe ui symbol": 1
                };

                function extractPrimaryFontFamily(value) {
                    if (!value) { return null; }
                    var families = String(value).split(",");
                    for (var i = 0; i < families.length; i++) {
                        var name = families[i].trim().replace(/^["']|["']$/g, "").trim();
                        if (name && !GENERIC_FONT_NAMES[name.toLowerCase()]) {
                            return name;
                        }
                    }
                    return null;
                }

                function ensureGoogleFontLoaded(name) {
                    if (!name) { return; }
                    if (!window.__ampLoadedThemeFonts) { window.__ampLoadedThemeFonts = {}; }
                    if (window.__ampLoadedThemeFonts[name]) { return; }
                    window.__ampLoadedThemeFonts[name] = true;
                    var encoded = encodeURIComponent(name).replace(/%20/g, "+");
                    var link = document.createElement("link");
                    link.rel = "stylesheet";
                    link.href = "https://fonts.googleapis.com/css2?family=" + encoded +
                        ":ital,wght@0,300;0,400;0,500;0,600;0,700;1,300;1,400;1,500;1,600;1,700&display=swap";
                    document.head.appendChild(link);
                }

                function detectAndLoadThemeFont() {
                    try {
                        var widget = document.querySelector('[class*="engagement-widget"]');
                        if (!widget) { return false; }
                        var value = getComputedStyle(widget).getPropertyValue("--font-font-family");
                        var primary = extractPrimaryFontFamily(value);
                        if (primary) { ensureGoogleFontLoaded(primary); }
                        return true;
                    } catch (e) {
                        return false;
                    }
                }

                /** Polls until widget mounts, then keeps checking so mid-session theme switches still load the new font. */
                function startThemeFontWatcher() {
                    var attempts = 0;
                    var maxAttempts = 200;
                    function tick() {
                        attempts++;
                        detectAndLoadThemeFont();
                        if (attempts >= maxAttempts) { return; }
                        setTimeout(tick, attempts < 50 ? 200 : 1000);
                    }
                    tick();
                }

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
                    var cdnBase = nativeCdnUrl
                        ? nativeCdnUrl
                        : (serverZone === "EU" ? "https://cdn.eu.amplitude.com" : "https://cdn.amplitude.com");
                    return cdnBase + "/script/" + encodeURIComponent(apiKey) + ".engagement.js";
                }

                function engagementInitOptions() {
                    var o = { serverZone: serverZone };
                    if (nativeServerUrl) { o.serverUrl = nativeServerUrl; }
                    if (nativeCdnUrl) { o.cdnUrl = nativeCdnUrl; }
                    if (nativeChatUrl) { o.chatUrl = nativeChatUrl; }
                    if (nativeMediaUrl) { o.mediaUrl = nativeMediaUrl; }
                    if (nativeLocale) { o.locale = nativeLocale; }
                    return o;
                }

                function buildUser() {
                    if (nativeUser && (nativeUser.user_id || nativeUser.device_id)) {
                        return nativeUser;
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

                function closeEngagementShell() {
                    if (engagementShell === "assistant") {
                        try {
                            if (window.engagement && window.engagement.assistant && typeof window.engagement.assistant.close === "function") {
                                window.engagement.assistant.close();
                            }
                        } catch (e1) {}
                        return;
                    }
                    try {
                        if (window.engagement && typeof window.engagement._showResourceCenter === "function") {
                            window.engagement._showResourceCenter(false);
                        }
                    } catch (e2) {}
                }

                function openAssistant() {
                    hideNativeLoadingSpinner();
                    try {
                        window.dispatchEvent(new Event("resize"));
                    } catch (e1) {}
                    requestAnimationFrame(function () {
                        requestAnimationFrame(function () {
                            try {
                                if (window.engagement && window.engagement.assistant && typeof window.engagement.assistant.show === "function") {
                                    window.engagement.assistant.show({ initialPage: "chat" });
                                }
                                try {
                                    window.dispatchEvent(new Event("resize"));
                                } catch (e2) {}
                            } catch (e3) {
                                ampLog("[Amplitude Engagement] assistant.show: " + e3);
                            }
                            window.__ampMobileResourceCenterLoaded = true;
                        });
                    });
                }

                function openResourceCenter() {
                    hideNativeLoadingSpinner();
                    var opts = { initialPage: engagementInitialPage };
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
                            window.__ampMobileResourceCenterLoaded = true;
                        });
                    });
                }

                function openEngagementShell() {
                    if (engagementShell === "assistant") {
                        openAssistant();
                    } else {
                        openResourceCenter();
                    }
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
                                    applyNativeEngagementFilters();
                                    openEngagementShell();
                                    startThemeFontWatcher();
                                }).catch(function (err) {
                                    ampLog("[Amplitude Engagement] boot failed: " + err);
                                });
                            } else {
                                applyNativeEngagementFilters();
                                openEngagementShell();
                                startThemeFontWatcher();
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
            CommandBarSDK.shared.closeResourceCenter()
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

        if message.name == "onResourceCenterClose" {
            DispatchQueue.main.async {
                CommandBarSDK.shared.closeResourceCenter()
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
                    CommandBarSDK.shared.closeResourceCenter()
                }
            }
            self.delegate?.didTriggerAssistantFallback(dict)
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
                            CommandBarSDK.shared.closeResourceCenter()
                        }
                    }
                    self.delegate?.didTriggerAssistantFallback(jsonDictionary)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

public protocol ResourceCenterWebViewDelegate: AnyObject {
    func didTriggerAssistantFallback(_ action: [String: Any])
}
