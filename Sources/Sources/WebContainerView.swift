import SwiftUI
import WebKit

struct WebContainerView: UIViewRepresentable {
    // ផ្លាស់ប្តូរ URL ខាងក្រោមទៅតាម GitHub Pages របស់អ្នកបើចង់ប្រើ online fallback
    private let fallbackURL = URL(string: "https://reachnyofficialy-a11y.github.io/")!

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = true
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.04, green: 0.07, blue: 0.13, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 0.04, green: 0.07, blue: 0.13, alpha: 1.0)

        if let localHTML = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(localHTML, allowingReadAccessTo: localHTML.deletingLastPathComponent())
        } else {
            webView.load(URLRequest(url: fallbackURL))
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        // គាំទ្រ alert() / confirm() ក្នុង JavaScript
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: "CADENZZA", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            topViewController()?.present(alert, animated: true)
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
