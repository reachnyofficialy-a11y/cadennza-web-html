import SwiftUI
import WebKit

struct WebContainerView: UIViewRepresentable {
    // URL សម្រាប់ fallback ករណីរក index.html ក្នុង bundle មិនឃើញ
    private let fallbackURL = URL(string: "https://reachnyofficialy-a11y.github.io/")!

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = true
        webView.isOpaque = false

        let darkNavy = UIColor(red: 0.04, green: 0.07, blue: 0.13, alpha: 1.0)
        webView.backgroundColor = darkNavy
        webView.scrollView.backgroundColor = darkNavy

        if let localHTML = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(localHTML, allowingReadAccessTo: localHTML.deletingLastPathComponent())
        } else {
            webView.load(URLRequest(url: fallbackURL))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebContainerView

        init(_ parent: WebContainerView) {
            self.parent = parent
        }

        // គាំទ្រ JavaScript alert()
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: "CADENZZA", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            topViewController()?.present(alert, animated: true)
        }

        // គាំទ្រ JavaScript confirm()
        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: "CADENZZA", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            topViewController()?.present(alert, animated: true)
        }

        // បើក external link (http/https) ក្នុង Safari ប្រសិនបើមិនមែនជា file local
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               navigationAction.navigationType == .linkActivated,
               let scheme = url.scheme?.lowercased(),
               (scheme == "http" || scheme == "https"),
               !url.host!.contains("github.io") {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        private func topViewController() -> UIViewController? {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
            var current = root
            while let presented = current.presentedViewController {
                current = presented
            }
            return current
        }
    }
}
