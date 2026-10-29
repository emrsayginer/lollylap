import SwiftUI
import StoreKit
import Charts

// MARK: - Native StoreKit 2 Subscription Manager

public enum StoreKitOutcome: String {
    case idle
    case checking
    case activated
    case cancelled
    case restored
    case restoreEmpty
}

@MainActor
public final class StoreKitClubManager: ObservableObject {
    public static let productIds: [String] = [
        "com.lollylap.game.vip.monthly",
        "com.lollylap.game.vip.quarterly",
        "com.lollylap.game.vip.annual"
    ]

    @Published public var isVipActive: Bool = false
    @Published public var products: [Product] = []
    @Published public var selectedPlanId: String = "com.lollylap.game.vip.annual"
    @Published public var isLoading: Bool = false
    @Published public var statusMessageKey: String = ""
    @Published public var lastOutcome: StoreKitOutcome = .idle

    private var updatesTask: Task<Void, Never>? = nil

    public init() {
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    await tx.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    public func loadProducts() async {
        do {
            let fetched = try await Product.products(for: Self.productIds)
            self.products = fetched.sorted { $0.price < $1.price }
        } catch {
            // Products fallback display prices when StoreKit configuration is offline
        }
    }

    public func purchaseSelectedPlan() async {
        isLoading = true
        lastOutcome = .checking
        statusMessageKey = "vip.status.checking"
        defer { isLoading = false }

        do {
            if products.isEmpty {
                await loadProducts()
            }
            guard let product = products.first(where: { $0.id == selectedPlanId }) ?? products.first else {
                lastOutcome = .cancelled
                statusMessageKey = "vip.status.cancelled"
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    await tx.finish()
                    isVipActive = true
                    UserDefaults.standard.set(true, forKey: "lollylap.vip.active")
                    lastOutcome = .activated
                    statusMessageKey = "vip.status.activated"
                } else {
                    lastOutcome = .cancelled
                    statusMessageKey = "vip.status.cancelled"
                }
            case .userCancelled:
                lastOutcome = .cancelled
                statusMessageKey = "vip.status.cancelled"
            case .pending:
                lastOutcome = .checking
                statusMessageKey = "vip.status.checking"
            @unknown default:
                lastOutcome = .cancelled
                statusMessageKey = "vip.status.cancelled"
            }
        } catch {
            lastOutcome = .cancelled
            statusMessageKey = "vip.status.cancelled"
        }
    }

    public func restorePurchases() async {
        isLoading = true
        lastOutcome = .checking
        statusMessageKey = "vip.status.checking"
        defer { isLoading = false }
        try? await AppStore.sync()
        await refreshEntitlements()
        if isVipActive {
            lastOutcome = .restored
            statusMessageKey = "vip.status.restored"
        } else {
            lastOutcome = .restoreEmpty
            statusMessageKey = "vip.status.restoreEmpty"
        }
    }

    public func manageSubscriptions() async {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            do {
                try await AppStore.showManageSubscriptions(in: scene)
                await refreshEntitlements()
                return
            } catch {}
        }
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            await UIApplication.shared.open(url)
        }
    }

    public func refreshEntitlements() async {
        var foundActive = false
        let now = Date()
        for await res in Transaction.currentEntitlements {
            if case .verified(let tx) = res,
               Self.productIds.contains(tx.productID),
               tx.revocationDate == nil,
               (tx.expirationDate == nil || tx.expirationDate! > now) {
                foundActive = true
                break
            }
        }
        isVipActive = foundActive
        UserDefaults.standard.set(foundActive, forKey: "lollylap.vip.active")
    }
}

// MARK: - Persistent Player Profile & Career State

@MainActor
public final class PlayerProfileState: ObservableObject {
    @Published public var language: AppLanguage = .en {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "lollylap.lang") }
    }
    @Published public var selectedCircuitId: String = "candy"
    @Published public var selectedDriverId: String = "luna"
    @Published public var selectedLaps: Int = 3
    @Published public var selectedDifficulty: Int = 1
    @Published public var controlMode: SteeringControlMode = .touch
    @Published public var loadout: KartLoadout = KartLoadout() {
        didSet { saveLoadout() }
    }
    @Published public var completedCareerStars: [String: Int] = ["ch1_ev1": 3, "ch1_ev2": 2] {
        didSet { saveCareer() }
    }
    @Published public var telemetryRecords: [LapTelemetryRecord] = []

    public init() {
        if let savedLang = UserDefaults.standard.string(forKey: "lollylap.lang"),
           let parsed = AppLanguage(rawValue: savedLang) {
            self.language = parsed
        }
        if let data = UserDefaults.standard.data(forKey: "lollylap.loadout"),
           let decoded = try? JSONDecoder().decode(KartLoadout.self, from: data) {
            self.loadout = decoded
        }
        if let cData = UserDefaults.standard.data(forKey: "lollylap.career"),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: cData) {
            self.completedCareerStars = decoded
        }
    }

    private func saveLoadout() {
        if let data = try? JSONEncoder().encode(loadout) {
            UserDefaults.standard.set(data, forKey: "lollylap.loadout")
        }
    }

    private func saveCareer() {
        if let data = try? JSONEncoder().encode(completedCareerStars) {
            UserDefaults.standard.set(data, forKey: "lollylap.career")
        }
    }

    public var currentCircuit: CircuitSpec {
        GameCatalog.circuits.first(where: { $0.id == selectedCircuitId }) ?? GameCatalog.circuits[0]
    }

    public var currentDriver: CritterDriverSpec {
        GameCatalog.drivers.first(where: { $0.id == selectedDriverId }) ?? GameCatalog.drivers[0]
    }
}

// MARK: - Root App

@main
struct LollyLapApp: App {
    @StateObject private var profile = PlayerProfileState()
    @StateObject private var store = StoreKitClubManager()

    var body: some Scene {
        WindowGroup {
            RootContainerView(profile: profile, store: store)
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
        }
    }
}

public enum HubTab: String, CaseIterable {
    case race
    case career
    case garage
    case telemetry
    case academy
}

public struct RootContainerView: View {
    @ObservedObject public var profile: PlayerProfileState
    @ObservedObject public var store: StoreKitClubManager

    @StateObject private var bridge = LollyEngineBridgeController()
    @State private var selectedTab: HubTab = .race
    @State private var showPaywall: Bool = false
    @State private var activeRaceEngine: RaceSimulationEngine? = nil
    @State private var activeCareerEventId: String? = nil

    public var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.14), Color(red: 0.14, green: 0.05, blue: 0.24)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Always keep the original Lolly Lap 3D engine alive in the background so graphics/state never reset
            OriginalLollyLap3DView(bridge: bridge)
                .ignoresSafeArea()
                .opacity(selectedTab == .race && activeRaceEngine == nil ? 1.0 : 0.0)
                .allowsHitTesting(selectedTab == .race && activeRaceEngine == nil)

            if let engine = activeRaceEngine {
                Active3DRaceScreenView(
                    engine: engine,
                    language: profile.language,
                    onRestart: {
                        launchRace(circuit: engine.circuit, driver: engine.playerDriver, laps: engine.totalLaps, careerEventId: activeCareerEventId)
                    },
                    onExitAndSave: { record in
                        if let rec = record {
                            profile.telemetryRecords.insert(rec, at: 0)
                            if let evId = activeCareerEventId {
                                let stars = rec.finishPosition == 1 ? 3 : (rec.finishPosition <= 3 ? 2 : 1)
                                profile.completedCareerStars[evId] = max(profile.completedCareerStars[evId] ?? 0, stars)
                            }
                        }
                        engine.stopLoop()
                        activeRaceEngine = nil
                    }
                )
            } else if selectedTab != .race {
                VStack(spacing: 0) {
                    topNavigationBar
                    Divider().background(Color.white.opacity(0.15))

                    Group {
                        switch selectedTab {
                        case .race:
                            EmptyView()
                        case .career:
                            CareerCampaignView(
                                language: profile.language,
                                completedStars: profile.completedCareerStars,
                                isVipUnlocked: store.isVipActive,
                                onLaunchEvent: { ev in
                                    activeCareerEventId = ev.id
                                    selectedTab = .race
                                    bridge.launchRaceInOriginalEngine(circuitId: ev.circuitId, laps: ev.laps)
                                },
                                onOpenPaywall: { showPaywall = true }
                            )
                        case .garage:
                            KartGarageCustomizerView(
                                language: profile.language,
                                selectedDriver: profile.currentDriver,
                                loadout: $profile.loadout,
                                isVipUnlocked: store.isVipActive,
                                onOpenPaywall: { showPaywall = true }
                            )
                        case .telemetry:
                            TelemetryLabView(language: profile.language, records: profile.telemetryRecords)
                        case .academy:
                            DriverAcademyView(language: profile.language) { circuitId in
                                selectedTab = .race
                                bridge.launchRaceInOriginalEngine(circuitId: circuitId, laps: 3)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // Sleek floating Native Pro Studio pill centered at top so it never overlaps LOLLY LAP brand
                HStack {
                    Spacer()
                    Button {
                        HapticsAndAudioEngine.shared.playDriftTierUp(tier: 1)
                        selectedTab = .career
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.yellow)
                            Text(profile.language == .tr ? "Kariyer • 3B Garaj • Telemetri" : "Career • 3D Garage • Telemetry")
                                .font(.system(size: 11.5, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.black.opacity(0.66))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.cyan.opacity(0.45), lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.top, 12)
            }
        }
        .onAppear {
            bridge.profile = profile
            bridge.store = store
            bridge.onOpenPaywall = { showPaywall = true }
            bridge.onOpenProStudio = { selectedTab = .garage }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallSheetView(language: profile.language, store: store)
        }
    }

    private func launchRace(circuit: CircuitSpec, driver: CritterDriverSpec, laps: Int, careerEventId: String?) {
        activeCareerEventId = careerEventId
        selectedTab = .race
        bridge.launchRaceInOriginalEngine(circuitId: circuit.id, laps: laps)
    }

    // MARK: - Top Navigation Bar

    private var topNavigationBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flag.2.crossed.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.pink)
                Text("LOLLY LAP")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    tabPill(.race, icon: "flag.checkered", title: L10n.t("tab.race", profile.language))
                    tabPill(.career, icon: "trophy.fill", title: L10n.t("tab.career", profile.language))
                    tabPill(.garage, icon: "wrench.and.screwdriver.fill", title: L10n.t("tab.garage", profile.language))
                    tabPill(.telemetry, icon: "chart.xyaxis.line", title: L10n.t("tab.telemetry", profile.language))
                    tabPill(.academy, icon: "graduationcap.fill", title: L10n.t("tab.academy", profile.language))
                }
            }

            Spacer()

            // Language Toggle (EN / TR)
            Button {
                HapticsAndAudioEngine.shared.playTap()
                profile.language = (profile.language == .en) ? .tr : .en
            } label: {
                Text(profile.language == .en ? "EN 🇬🇧" : "TR 🇹🇷")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.10))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            // VIP Pass Button
            Button {
                HapticsAndAudioEngine.shared.playTap()
                showPaywall = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: store.isVipActive ? "checkmark.seal.fill" : "crown.fill")
                        .foregroundColor(.yellow)
                    Text(store.isVipActive ? "VIP ACTIVE" : "7-DAY FREE TRIAL")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    LinearGradient(colors: [Color.pink, Color.purple], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.35))
    }

    private func tabPill(_ tab: HubTab, icon: String, title: String) -> some View {
        let active = (selectedTab == tab)
        return Button {
            HapticsAndAudioEngine.shared.playTap()
            selectedTab = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(active ? Color.cyan.opacity(0.28) : Color.white.opacity(0.06))
            .foregroundColor(active ? .cyan : .white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(active ? Color.cyan : Color.clear, lineWidth: 1.2)
            )
        }
    }

    // MARK: - Quick Race Setup Screen

    private var quickRaceSetupView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    // Left: Live 3D Kart Preview + Start Race CTA
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomLeading) {
                            GarageTurntableSCNView(driver: profile.currentDriver, loadout: profile.loadout)
                                .frame(width: 280, height: 195)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.pink.opacity(0.5), lineWidth: 1.5)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.currentDriver.name)
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text(profile.currentDriver.localizedSkill(profile.language))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.cyan)
                            }
                            .padding(10)
                            .background(Color.black.opacity(0.65))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(10)
                        }

                        Button {
                            HapticsAndAudioEngine.shared.playTap()
                            launchRace(circuit: profile.currentCircuit, driver: profile.currentDriver, laps: profile.selectedLaps, careerEventId: nil)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "flag.checkered.2.crossed")
                                    .font(.system(size: 18, weight: .black))
                                Text(L10n.t("race.start", profile.language))
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                            }
                            .frame(width: 280)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .pink.opacity(0.5), radius: 10, x: 0, y: 4)
                        }
                    }

                    // Right: Circuit Selection + Driver Selection + Race Rules
                    VStack(alignment: .leading, spacing: 14) {
                        Text(L10n.t("race.selectCircuit", profile.language))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(GameCatalog.circuits) { circuit in
                                    let locked = !circuit.isFreeInDemo && !store.isVipActive
                                    let selected = profile.selectedCircuitId == circuit.id
                                    Button {
                                        HapticsAndAudioEngine.shared.playTap()
                                        if locked {
                                            showPaywall = true
                                        } else {
                                            profile.selectedCircuitId = circuit.id
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Circle()
                                                    .fill(Color(UIColor(hex: circuit.curbPrimaryHex)))
                                                    .frame(width: 12, height: 12)
                                                Text("\(circuit.lengthMeters)m • \(circuit.cornerCount) Turns")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                    .foregroundColor(.cyan)
                                                Spacer()
                                                if locked {
                                                    Image(systemName: "lock.fill")
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                            Text(circuit.localizedName(profile.language))
                                                .font(.system(size: 14, weight: .black, design: .rounded))
                                                .foregroundColor(.white)
                                            Text(circuit.localizedSubtitle(profile.language))
                                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(white: 0.72))
                                                .lineLimit(2)
                                        }
                                        .padding(12)
                                        .frame(width: 195, alignment: .leading)
                                        .background(selected ? Color.pink.opacity(0.28) : Color.white.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selected ? Color.pink : Color.white.opacity(0.12), lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                        }

                        Text(L10n.t("race.selectDriver", profile.language))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(GameCatalog.drivers) { drv in
                                    let locked = !drv.isFreeInDemo && !store.isVipActive
                                    let selected = profile.selectedDriverId == drv.id
                                    Button {
                                        HapticsAndAudioEngine.shared.playTap()
                                        if locked {
                                            showPaywall = true
                                        } else {
                                            profile.selectedDriverId = drv.id
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(Color(UIColor(hex: drv.primaryColorHex)))
                                                .frame(width: 26, height: 26)
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 4) {
                                                    Text(drv.name)
                                                        .font(.system(size: 13, weight: .black, design: .rounded))
                                                        .foregroundColor(.white)
                                                    if locked {
                                                        Image(systemName: "lock.fill")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.yellow)
                                                    }
                                                }
                                                Text("SPD \(Int(drv.baseSpeed * 100)) • DRF \(Int(drv.baseDriftBoost * 100))")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                    .foregroundColor(.cyan)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 9)
                                        .background(selected ? Color.cyan.opacity(0.28) : Color.white.opacity(0.07))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selected ? Color.cyan : Color.white.opacity(0.12), lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                        }

                        // Laps, AI Pace & Steering Mode Controls
                        HStack(spacing: 14) {
                            Picker(L10n.t("race.laps", profile.language), selection: $profile.selectedLaps) {
                                Text("2 Laps").tag(2)
                                Text("3 Laps").tag(3)
                                Text("5 Laps").tag(5)
                            }
                            .pickerStyle(.segmented)

                            Picker(L10n.t("race.difficulty", profile.language), selection: $profile.selectedDifficulty) {
                                Text("100cc").tag(0)
                                Text("150cc").tag(1)
                                Text("200cc").tag(2)
                            }
                            .pickerStyle(.segmented)

                            Picker(L10n.t("race.controls", profile.language), selection: $profile.controlMode) {
                                Text(L10n.t("control.touch", profile.language)).tag(SteeringControlMode.touch)
                                Text(L10n.t("control.tilt", profile.language)).tag(SteeringControlMode.tilt)
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Active 3D Race Screen + Native SwiftUI Racing HUD

public struct Active3DRaceScreenView: View {
    @ObservedObject public var engine: RaceSimulationEngine
    public let language: AppLanguage
    public let onRestart: () -> Void
    public let onExitAndSave: (LapTelemetryRecord?) -> Void

    public var body: some View {
        ZStack {
            SceneKitRaceViewport(engine: engine)
                .ignoresSafeArea()

            // HUD Overlay
            VStack {
                // Top Bar: Position, Lap, Timer, Minimap, Pause
                HStack(alignment: .top) {
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.t("hud.pos", language))
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.cyan)
                            Text("#\(engine.currentPlace) / 6")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Divider().frame(height: 32).background(Color.white.opacity(0.25))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.t("hud.lap", language))
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.pink)
                            Text("\(engine.currentLap) / \(engine.totalLaps)")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Divider().frame(height: 32).background(Color.white.opacity(0.25))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TIME")
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.2fs", engine.elapsedSeconds))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.62))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    Spacer()

                    if !engine.statusBanner.isEmpty {
                        Text(engine.statusBanner)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }

                    Spacer()

                    // Live Minimap + Pause Button
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.60))
                                .frame(width: 76, height: 76)

                            Canvas { ctx, size in
                                guard engine.minimapPoints.count > 2 else { return }
                                var path = Path()
                                for (i, pt) in engine.minimapPoints.enumerated() {
                                    let p = CGPoint(x: 8 + pt.x * (size.width - 16), y: 8 + pt.y * (size.height - 16))
                                    if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                                }
                                path.closeSubpath()
                                ctx.stroke(path, with: .color(.white.opacity(0.45)), lineWidth: 3)

                                for ai in engine.aiMinimapPoints {
                                    let ap = CGPoint(x: 8 + ai.x * (size.width - 16), y: 8 + ai.y * (size.height - 16))
                                    ctx.fill(Path(ellipseIn: CGRect(x: ap.x - 3, y: ap.y - 3, width: 6, height: 6)), with: .color(.cyan))
                                }

                                let pp = CGPoint(
                                    x: 8 + engine.playerMinimapPoint.x * (size.width - 16),
                                    y: 8 + engine.playerMinimapPoint.y * (size.height - 16)
                                )
                                ctx.fill(Path(ellipseIn: CGRect(x: pp.x - 4.5, y: pp.y - 4.5, width: 9, height: 9)), with: .color(.pink))
                            }
                            .frame(width: 76, height: 76)
                        }

                        Button {
                            HapticsAndAudioEngine.shared.playTap()
                            engine.isPaused = true
                        } label: {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 18, weight: .black))
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.62))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Center Countdown
                if !engine.countdownText.isEmpty {
                    Text(engine.countdownText)
                        .font(.system(size: 76, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                        .shadow(color: .pink, radius: 16)
                }

                Spacer()

                // Bottom Controls & Speedometer
                HStack(alignment: .bottom) {
                    // Left Steering Buttons
                    HStack(spacing: 14) {
                        steerButton(label: "◀", axisValue: -1.0)
                        steerButton(label: "▶", axisValue: 1.0)
                    }

                    Spacer()

                    // Center Speedometer & Drift Charge Meter
                    VStack(spacing: 6) {
                        if engine.driftChargeProgress > 0 {
                            HStack(spacing: 6) {
                                Text("DRIFT TIER \(engine.driftTier)")
                                    .font(.system(size: 11, weight: .black, design: .monospaced))
                                    .foregroundColor(engine.driftTier >= 3 ? .purple : (engine.driftTier == 2 ? .orange : .cyan))
                                ProgressView(value: engine.driftChargeProgress)
                                    .tint(engine.driftTier >= 3 ? .purple : (engine.driftTier == 2 ? .orange : .cyan))
                                    .frame(width: 110)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(engine.speedKmh)")
                                .font(.system(size: 38, weight: .black, design: .monospaced))
                                .foregroundColor(engine.boostActive ? .cyan : .white)
                            Text("KM/H")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.pink)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.62))
                        .clipShape(Capsule())
                    }

                    Spacer()

                    // Right Pedals: Drift + Boost / Item
                    HStack(spacing: 14) {
                        // Hold Drift Button
                        Text(L10n.t("hud.drift", language))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .frame(width: 88, height: 64)
                            .background(engine.isDriftingInput ? Color.orange : Color.white.opacity(0.18))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.4), lineWidth: 1.5))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in engine.isDriftingInput = true }
                                    .onEnded { _ in engine.isDriftingInput = false }
                            )

                        // Boost / Item Fire Button
                        Button {
                            engine.triggerBoostButton()
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: engine.heldItem?.iconName ?? "flame.fill")
                                    .font(.system(size: 20, weight: .black))
                                Text(engine.heldItem != nil ? "ITEM" : L10n.t("hud.boost", language))
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                            }
                            .frame(width: 88, height: 64)
                            .background(
                                LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }

            // Pause Overlay
            if engine.isPaused {
                Color.black.opacity(0.75).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text(L10n.t("hud.pause", language))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Button(L10n.t("hud.resume", language)) {
                        engine.isPaused = false
                    }
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .frame(width: 220)
                    .padding(.vertical, 12)
                    .background(Color.cyan)
                    .foregroundColor(.black)
                    .clipShape(Capsule())

                    Button(L10n.t("hud.restart", language)) {
                        onRestart()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(width: 220)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .clipShape(Capsule())

                    Button(L10n.t("hud.exit", language)) {
                        onExitAndSave(nil)
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(width: 220)
                    .padding(.vertical, 12)
                    .background(Color.pink.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
            }

            // Post-Race Finish & Telemetry Breakdown Overlay
            if engine.isRaceFinished {
                Color.black.opacity(0.82).ignoresSafeArea()
                VStack(spacing: 16) {
                    Text(L10n.t("result.finished", language))
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)

                    HStack(spacing: 16) {
                        statBox(label: L10n.t("hud.pos", language), val: "#\(engine.currentPlace)")
                        statBox(label: L10n.t("result.time", language), val: String(format: "%.2fs", engine.elapsedSeconds))
                        statBox(label: L10n.t("result.bestLap", language), val: String(format: "%.2fs", engine.bestLapSeconds))
                        statBox(label: "S1 / S2 / S3", val: String(format: "%.1f / %.1f / %.1f", engine.sector1Split, engine.sector2Split, engine.sector3Split))
                    }

                    HStack(spacing: 16) {
                        Button(L10n.t("result.playAgain", language)) {
                            onRestart()
                        }
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .clipShape(Capsule())

                        Button(L10n.t("result.backHub", language)) {
                            onExitAndSave(engine.completedTelemetry)
                        }
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding(24)
            }
        }
    }

    private func steerButton(label: String, axisValue: Float) -> some View {
        Text(label)
            .font(.system(size: 26, weight: .black))
            .frame(width: 78, height: 64)
            .background(engine.touchSteerAxis == axisValue ? Color.cyan.opacity(0.55) : Color.white.opacity(0.18))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.4), lineWidth: 1.5))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in engine.touchSteerAxis = axisValue }
                    .onEnded { _ in
                        if engine.touchSteerAxis == axisValue {
                            engine.touchSteerAxis = 0
                        }
                    }
            )
    }

    private func statBox(label: String, val: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.cyan)
            Text(val)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - StoreKit 2 Lolly Lap Club Paywall Sheet

public struct PaywallSheetView: View {
    @Environment(\.dismiss) private var dismiss
    public let language: AppLanguage
    @ObservedObject public var store: StoreKitClubManager

    public var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.05, blue: 0.16).ignoresSafeArea()

            VStack(spacing: 14) {
                HStack {
                    Text(L10n.t("vip.badge", language))
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.yellow.opacity(0.2))
                        .foregroundColor(.yellow)
                        .clipShape(Capsule())
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }

                Text(L10n.t("vip.title", language))
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(L10n.t("vip.subtitle", language))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color(white: 0.75))

                HStack(spacing: 12) {
                    planCard(id: "com.lollylap.game.vip.monthly", title: "1 MONTH", price: "$4.99 / mo", sub: "7-Day Free Trial")
                    planCard(id: "com.lollylap.game.vip.quarterly", title: "3 MONTHS", price: "$4.49 / mo", sub: "$13.47 every 3 mo")
                    planCard(id: "com.lollylap.game.vip.annual", title: "12 MONTHS", price: "$3.99 / mo", sub: "$47.88 / yr • BEST")
                }

                Button {
                    Task { await store.purchaseSelectedPlan() }
                } label: {
                    Text(store.isLoading ? "..." : L10n.t("vip.startTrial", language))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }

                if !store.statusMessageKey.isEmpty {
                    Text(L10n.t(store.statusMessageKey, language))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(store.isVipActive ? .green : .yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                }

                HStack(spacing: 16) {
                    Button(L10n.t("vip.restore", language)) {
                        Task { await store.restorePurchases() }
                    }
                    Button(L10n.t("vip.manageCancel", language)) {
                        Task { await store.manageSubscriptions() }
                    }
                    Link("Privacy Policy", destination: URL(string: "https://lollylap.com/#privacy")!)
                    Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.cyan)
            }
            .padding(22)
        }
    }

    private func planCard(id: String, title: String, price: String, sub: String) -> some View {
        let selected = store.selectedPlanId == id
        return Button {
            store.selectedPlanId = id
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.cyan)
                Text(price)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text(sub)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(white: 0.72))
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(selected ? Color.pink.opacity(0.28) : Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? Color.pink : Color.white.opacity(0.15), lineWidth: 2)
            )
        }
    }
}
