import SwiftUI
import WebKit
import UniformTypeIdentifiers

// MARK: - Local Bundle Scheme Handler (lollylap://app/...)

public final class LollyBundleSchemeHandler: NSObject, WKURLSchemeHandler {
    private let root: URL? = Bundle.main.resourceURL?.appendingPathComponent("webapp", isDirectory: true)

    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let root = root, let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(URLError(.fileDoesNotExist))
            return
        }
        var relPath = url.path
        if relPath.hasPrefix("/") { relPath.removeFirst() }
        if relPath.isEmpty { relPath = "index.html" }

        let targetURL = root.appendingPathComponent(relPath).standardizedFileURL
        guard targetURL.path.hasPrefix(root.standardizedFileURL.path),
              FileManager.default.fileExists(atPath: targetURL.path),
              let data = try? Data(contentsOf: targetURL) else {
            let resp = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)!
            urlSchemeTask.didReceive(resp)
            urlSchemeTask.didFinish()
            return
        }

        let mime = Self.mimeType(for: targetURL.pathExtension)
        let headers: [String: String] = [
            "Content-Type": mime,
            "Content-Length": "\(data.count)",
            "Cache-Control": "public, max-age=31536000, immutable",
            "Access-Control-Allow-Origin": "*"
        ]
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}

    private static func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html": return "text/html; charset=utf-8"
        case "js", "mjs": return "text/javascript; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "json", "webmanifest": return "application/json; charset=utf-8"
        case "wasm": return "application/wasm"
        case "svg": return "image/svg+xml"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "webp": return "image/webp"
        case "glb": return "model/gltf-binary"
        case "woff2": return "font/woff2"
        case "ttf": return "font/ttf"
        default:
            if let utType = UTType(filenameExtension: ext), let m = utType.preferredMIMEType {
                return m
            }
            return "application/octet-stream"
        }
    }
}

// MARK: - Bidirectional Controller between Original 3D WebGL Engine & Native Swift Studios

@MainActor
public final class LollyEngineBridgeController: NSObject, ObservableObject, WKScriptMessageHandler, WKNavigationDelegate {
    public weak var webView: WKWebView?
    public weak var profile: PlayerProfileState?
    public weak var store: StoreKitClubManager?
    public var onOpenPaywall: (() -> Void)?
    public var onOpenProStudio: (() -> Void)?

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "lollyBridge",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }

        switch type {
        case "raceStart":
            HapticsAndAudioEngine.shared.playCountdownGo()
            if let map = body["map"] as? String {
                profile?.selectedCircuitId = map
            }
            if let laps = body["laps"] as? Int {
                profile?.selectedLaps = laps
            }

        case "popup":
            let kind = (body["kind"] as? String) ?? ""
            if kind == "boost" || kind == "drift" {
                HapticsAndAudioEngine.shared.playTurboBoost()
            } else {
                HapticsAndAudioEngine.shared.playItemPickup()
            }

        case "hurt":
            HapticsAndAudioEngine.shared.playWallImpact()

        case "raceEnd":
            HapticsAndAudioEngine.shared.playLapComplete(isFinal: true)
            let place = (body["place"] as? Int) ?? 1
            let clock = (body["clock"] as? Double) ?? 95.0
            let bestLap = (body["bestLap"] as? Double) ?? (clock / 3.0)
            let driftBoosts = (body["driftBoosts"] as? Int) ?? 6
            let mapId = (body["map"] as? String) ?? (profile?.selectedCircuitId ?? "candy")
            recordNativeTelemetry(mapId: mapId, place: place, totalTime: clock, bestLap: bestLap, driftBoosts: driftBoosts)

        case "openVipModal":
            HapticsAndAudioEngine.shared.playDriftTierUp(tier: 1)

        case "purchaseVipPlan":
            let plan = (body["plan"] as? String) ?? "annual"
            if let store = store {
                switch plan {
                case "monthly":
                    store.selectedPlanId = "com.lollylap.game.vip.monthly"
                case "quarterly":
                    store.selectedPlanId = "com.lollylap.game.vip.quarterly"
                default:
                    store.selectedPlanId = "com.lollylap.game.vip.annual"
                }
                Task {
                    await store.purchaseSelectedPlan()
                    if store.isVipActive {
                        syncVipToEngine(isVip: true)
                    } else {
                        onOpenPaywall?()
                    }
                }
            } else {
                onOpenPaywall?()
            }

        default:
            break
        }
    }

    public func launchRaceInOriginalEngine(circuitId: String, laps: Int) {
        let safeMap = circuitId.replacingOccurrences(of: "'", with: "")
        let clampedLaps = [2, 3, 5, 7].contains(laps) ? laps : 3
        let js = """
        (function() {
          try {
            if (window.__game && window.__game.save && window.__game.game) {
              window.__game.save.update({ map: '\(safeMap)', laps: \(clampedLaps) });
              window.__game.game.setMap('\(safeMap)');
              window.__game.game.setLaps(\(clampedLaps));
              if (window.__game.ui) {
                window.__game.ui.refreshCircuitPills();
                window.__game.ui.refreshSettings();
              }
              window.dispatchEvent(new CustomEvent('game:start'));
            }
          } catch (e) {}
        })();
        """
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    public func syncVipToEngine(isVip: Bool) {
        let js = "try { localStorage.setItem('lollylap:vip', '\(isVip ? "1" : "0")'); } catch(e) {}"
        webView?.evaluateJavaScript(js, completionHandler: nil)
    }

    private func recordNativeTelemetry(mapId: String, place: Int, totalTime: Double, bestLap: Double, driftBoosts: Int) {
        guard let profile = profile else { return }
        let circuit = GameCatalog.circuits.first(where: { $0.id == mapId }) ?? GameCatalog.circuits[0]
        let validBest = bestLap > 5.0 ? bestLap : max(24.0, totalTime / Double(max(1, profile.selectedLaps)))
        let s1 = validBest * 0.32
        let s2 = validBest * 0.35
        let s3 = validBest - s1 - s2

        var samples: [TelemetryPoint] = []
        let count = 24
        for i in 0...count {
            let p = Double(i) / Double(count)
            let wave = sin(p * .pi * 6.0) * 18.0 + cos(p * .pi * 4.0) * 11.0
            let speed = max(92.0, min(238.0, 178.0 + wave + Double(driftBoosts) * 1.6))
            let tier = (i % 5 == 0 && driftBoosts > 0) ? min(3, (i % 3) + 1) : 0
            samples.append(TelemetryPoint(normalizedDistance: p, speedKmh: speed, lateralG: abs(sin(p * .pi * 4.0)) * 1.4, driftTier: tier))
        }

        let avgSpeed = samples.map(\.speedKmh).reduce(0, +) / Double(samples.count)
        let topSpeed = samples.map(\.speedKmh).max() ?? 215.0

        let rec = LapTelemetryRecord(
            circuitId: circuit.id,
            driverId: profile.selectedDriverId,
            lapTimeSeconds: validBest,
            sector1Seconds: s1,
            sector2Seconds: s2,
            sector3Seconds: s3,
            topSpeedKmh: topSpeed,
            averageSpeedKmh: avgSpeed,
            driftBoostCount: max(1, driftBoosts),
            finishPosition: place,
            samples: samples
        )
        profile.telemetryRecords.insert(rec, at: 0)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if url.scheme == "lollylap" || url.scheme == "about" || url.scheme == "blob" || url.scheme == "data" {
            decisionHandler(.allow)
            return
        }
        if url.scheme == "http" || url.scheme == "https" {
            UIApplication.shared.open(url)
        }
        decisionHandler(.cancel)
    }
}

// MARK: - SwiftUI Wrapper for the Original Lolly Lap 3D Engine

public struct OriginalLollyLap3DView: UIViewRepresentable {
    @ObservedObject public var bridge: LollyEngineBridgeController

    public init(bridge: LollyEngineBridgeController) {
        self.bridge = bridge
    }

    public func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.setURLSchemeHandler(LollyBundleSchemeHandler(), forURLScheme: "lollylap")
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.userContentController.add(bridge, name: "lollyBridge")

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.isOpaque = false
        wv.backgroundColor = UIColor(red: 0.106, green: 0.094, blue: 0.220, alpha: 1.0)
        wv.scrollView.backgroundColor = wv.backgroundColor
        wv.scrollView.isScrollEnabled = false
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.navigationDelegate = bridge

        bridge.webView = wv
        if let startURL = URL(string: "lollylap://app/index.html") {
            wv.load(URLRequest(url: startURL))
        }
        return wv
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {}
}
