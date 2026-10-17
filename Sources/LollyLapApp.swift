import SwiftUI
import WebKit
import StoreKit
import UniformTypeIdentifiers

final class LocalBundleSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(URLError(.badURL))
            return
        }
        var relPath = url.path
        if relPath.isEmpty || relPath == "/" {
            relPath = "/index.html"
        }
        let cleanRel = relPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let webappURL = Bundle.main.resourceURL?.appendingPathComponent("webapp") else {
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        let fileURL = webappURL.appendingPathComponent(cleanRel)
        guard let data = try? Data(contentsOf: fileURL) else {
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        let ext = fileURL.pathExtension.lowercased()
        let mime: String
        switch ext {
        case "html": mime = "text/html; charset=utf-8"
        case "js", "mjs": mime = "application/javascript; charset=utf-8"
        case "css": mime = "text/css; charset=utf-8"
        case "json": mime = "application/json; charset=utf-8"
        case "png": mime = "image/png"
        case "jpg", "jpeg": mime = "image/jpeg"
        case "svg": mime = "image/svg+xml"
        case "webp": mime = "image/webp"
        case "woff2": mime = "font/woff2"
        case "mp3": mime = "audio/mpeg"
        case "wav": mime = "audio/wav"
        default:
            mime = UTType(filenameExtension: ext)?.preferredMIMEType ?? "application/octet-stream"
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": mime,
                "Content-Length": "\(data.count)",
                "Access-Control-Allow-Origin": "*"
            ]
        )!
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}

@MainActor
final class StoreKitCoordinator: NSObject, WKScriptMessageHandler {
    weak var webView: WKWebView?
    static let productIds = [
        "com.lollylap.game.vip.monthly",
        "com.lollylap.game.vip.quarterly",
        "com.lollylap.game.vip.annual"
    ]

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }
        Task {
            if action == "purchase", let productId = body["productId"] as? String {
                await purchase(productId: productId)
            } else if action == "restore" {
                await restore()
            } else if action == "checkEntitlements" {
                await checkEntitlements()
            }
        }
    }

    func purchase(productId: String) async {
        do {
            let products = try await Product.products(for: [productId])
            guard let product = products.first else { return }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    notifyWeb(vipActive: true, productId: productId)
                }
            default:
                break
            }
        } catch {
            print("StoreKit purchase error: \(error)")
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.productIds.contains(transaction.productID) {
                notifyWeb(vipActive: true, productId: transaction.productID)
                return
            }
        }
    }

    private func notifyWeb(vipActive: Bool, productId: String) {
        let js = "window.localStorage.setItem('lollylap_vip_active', '\(vipActive ? "1" : "0")'); window.dispatchEvent(new CustomEvent('lollylap-vip-updated', { detail: { active: \(vipActive), productId: '\(productId)' } }));"
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }
}

struct GameWebView: UIViewRepresentable {
    func makeCoordinator() -> StoreKitCoordinator {
        StoreKitCoordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(LocalBundleSchemeHandler(), forURLScheme: "app")
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.userContentController.add(context.coordinator, name: "storekit")

        let bridgeScript = WKUserScript(
            source: """
            window.LollyLapNativeStore = {
              purchase: function(productId) {
                window.webkit.messageHandlers.storekit.postMessage({ action: 'purchase', productId: productId });
              },
              restore: function() {
                window.webkit.messageHandlers.storekit.postMessage({ action: 'restore' });
              }
            };
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(bridgeScript)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.webView = webView

        if let startURL = URL(string: "app://localhost/index.html") {
            webView.load(URLRequest(url: startURL))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

@main
struct LollyLapApp: App {
    var body: some Scene {
        WindowGroup {
            GameWebView()
                .ignoresSafeArea()
                .statusBarHidden(true)
        }
    }
}
