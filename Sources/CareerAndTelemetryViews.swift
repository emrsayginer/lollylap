import SwiftUI
import Charts

// MARK: - 28-Event Career Tour View

public struct CareerCampaignView: View {
    public let language: AppLanguage
    public let completedStars: [String: Int]
    public let isVipUnlocked: Bool
    public let onLaunchEvent: (CareerEventSpec) -> Void
    public let onOpenPaywall: () -> Void

    public init(
        language: AppLanguage,
        completedStars: [String: Int],
        isVipUnlocked: Bool,
        onLaunchEvent: @escaping (CareerEventSpec) -> Void,
        onOpenPaywall: @escaping () -> Void
    ) {
        self.language = language
        self.completedStars = completedStars
        self.isVipUnlocked = isVipUnlocked
        self.onLaunchEvent = onLaunchEvent
        self.onOpenPaywall = onOpenPaywall
    }

    private var totalStars: Int {
        completedStars.values.reduce(0, +)
    }

    private var licenseTitle: String {
        if totalStars >= 50 { return "Starlight Legend (S+)" }
        if totalStars >= 30 { return "Apex Pro License (Class S)" }
        if totalStars >= 15 { return "National License (Class A)" }
        if totalStars >= 5  { return "Clubman License (Class B)" }
        return "Rookie Kart License (Class C)"
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Driver License Banner
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.t("career.title", language))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(L10n.t("career.subtitle", language))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.72))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(totalStars) / 84 \(L10n.t("career.stars", language))")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                        Text(licenseTitle)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.cyan)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // 28 Career Events Grid
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(GameCatalog.careerEvents) { ev in
                        let locked = ev.chapterIndex > 1 && !isVipUnlocked
                        let stars = completedStars[ev.id] ?? 0
                        let circuit = GameCatalog.circuits.first(where: { $0.id == ev.circuitId }) ?? GameCatalog.circuits[0]

                        Button {
                            HapticsAndAudioEngine.shared.playTap()
                            if locked {
                                onOpenPaywall()
                            } else {
                                onLaunchEvent(ev)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("CUP \(ev.chapterIndex)-\(ev.eventIndex)")
                                        .font(.system(size: 11, weight: .black, design: .monospaced))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(UIColor(hex: circuit.curbPrimaryHex)).opacity(0.35))
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())

                                    Spacer()

                                    if locked {
                                        Label("VIP", systemImage: "lock.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.yellow)
                                    } else {
                                        HStack(spacing: 3) {
                                            ForEach(1...3, id: \.self) { s in
                                                Image(systemName: s <= stars ? "star.fill" : "star")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(s <= stars ? .yellow : .gray)
                                            }
                                        }
                                    }
                                }

                                Text(language == .tr ? ev.titleTr : ev.titleEn)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                HStack {
                                    Label("\(ev.laps) Laps", systemImage: "flag.checkered")
                                    Spacer()
                                    Label(String(format: "%.1fs", ev.targetTimeSeconds), systemImage: "stopwatch")
                                }
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(white: 0.72))
                            }
                            .padding(14)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(UIColor(hex: circuit.skyTopHex)).opacity(0.85),
                                        Color(red: 0.10, green: 0.12, blue: 0.22)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color(UIColor(hex: circuit.accentHex)).opacity(0.40), lineWidth: 1.2)
                            )
                        }
                    }
                }
            }
            .padding(18)
        }
    }
}

// MARK: - Apple Charts Telemetry & Sector Analyzer View

public struct TelemetryLabView: View {
    public let language: AppLanguage
    public let records: [LapTelemetryRecord]

    public init(language: AppLanguage, records: [LapTelemetryRecord]) {
        self.language = language
        self.records = records
    }

    private var activeRecord: LapTelemetryRecord {
        if let latest = records.first { return latest }
        // Default initial sample record so the Telemetry Lab is immediately rich on first open
        let defaultSamples: [TelemetryPoint] = (0..<40).map { i in
            let dist = Double(i) * 2.5
            let base = 138.0 + 22.0 * sin(Double(i) * 0.35)
            let pro = 144.0 + 18.0 * sin(Double(i) * 0.35 + 0.15)
            return TelemetryPoint(sampleIndex: i, distanceNormalized: dist, speedKmh: base, proReferenceKmh: pro, driftAngleDeg: abs(sin(Double(i) * 0.4)) * 28.0)
        }
        return LapTelemetryRecord(
            id: UUID(),
            circuitId: "candy",
            driverId: "luna",
            timestamp: Date(),
            totalTimeSeconds: 74.82,
            bestLapSeconds: 24.31,
            sector1Seconds: 7.84,
            sector2Seconds: 8.62,
            sector3Seconds: 7.85,
            peakSpeedKmh: 164.2,
            miniTurboCount: 7,
            finishPosition: 1,
            samples: defaultSamples
        )
    }

    public var body: some View {
        let rec = activeRecord
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("telemetry.title", language))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(L10n.t("telemetry.subtitle", language))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.72))
                }

                // Summary KPI Cards
                HStack(spacing: 12) {
                    telemetryMetricCard(title: L10n.t("result.bestLap", language), value: String(format: "%.2fs", rec.bestLapSeconds), color: .cyan)
                    telemetryMetricCard(title: L10n.t("result.topSpeed", language), value: String(format: "%.0f km/h", rec.peakSpeedKmh), color: .pink)
                    telemetryMetricCard(title: L10n.t("result.drifts", language), value: "\(rec.miniTurboCount)x", color: .yellow)
                    telemetryMetricCard(title: L10n.t("hud.pos", language), value: "#\(rec.finishPosition)", color: .green)
                }

                // Velocity Trace + Sector Comparison Row
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.t("telemetry.speedTrace", language))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Label("Your Kart", systemImage: "circle.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.cyan)
                            Label("Pro Target", systemImage: "circle.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.pink)
                        }

                        Chart {
                            ForEach(rec.samples) { pt in
                                LineMark(
                                    x: .value("Track %", pt.distanceNormalized),
                                    y: .value("Pro km/h", pt.proReferenceKmh),
                                    series: .value("Trace", "Pro")
                                )
                                .foregroundStyle(Color.pink.opacity(0.65))
                                .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 3]))

                                LineMark(
                                    x: .value("Track %", pt.distanceNormalized),
                                    y: .value("Your km/h", pt.speedKmh),
                                    series: .value("Trace", "Player")
                                )
                                .foregroundStyle(Color.cyan)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                            }
                        }
                        .chartYScale(domain: 70...195)
                        .frame(height: 185)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Sector Splits Bar Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.t("telemetry.sectorSplits", language))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Chart {
                            BarMark(x: .value("Sector", "S1"), y: .value("Sec", rec.sector1Seconds))
                                .foregroundStyle(Color.cyan)
                            BarMark(x: .value("Sector", "S2"), y: .value("Sec", rec.sector2Seconds))
                                .foregroundStyle(Color.pink)
                            BarMark(x: .value("Sector", "S3"), y: .value("Sec", rec.sector3Seconds))
                                .foregroundStyle(Color.yellow)
                        }
                        .frame(height: 185)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .frame(width: 240)
                }

                // AI Race Engineer Diagnostic Box
                HStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg.rectangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.t("telemetry.coach", language))
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                        Text(
                            language == .tr
                            ? "Sektör 2 çıkışında Mini-Turbo şarjını 2. kademeye kadar tutarak düzlük hızınızı +11 km/s artırabilirsiniz. 3B Garajda Son Dişli Oranını %60 seviyesine çekmeniz önerilir."
                            : "Holding your Mini-Turbo charge to Tier 2 exiting Sector 2 will add +11 km/h onto the main straight. Try setting Final Drive Ratio to 60% in the 3D Garage."
                        )
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    }
                }
                .padding(14)
                .background(Color.yellow.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow.opacity(0.35), lineWidth: 1)
                )
            }
            .padding(18)
        }
    }

    private func telemetryMetricCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Color(white: 0.70))
            Text(value)
                .font(.system(size: 20, weight: .black, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Interactive Driver Academy View

public struct DriverAcademyView: View {
    public let language: AppLanguage
    public let onStartDrill: (String) -> Void

    public init(language: AppLanguage, onStartDrill: @escaping (String) -> Void) {
        self.language = language
        self.onStartDrill = onStartDrill
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.t("academy.title", language))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(L10n.t("academy.subtitle", language))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.72))
                }

                ForEach(GameCatalog.academyLessons) { lesson in
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.pink.opacity(0.22))
                                .frame(width: 54, height: 54)
                            Image(systemName: lesson.iconName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.pink)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("LESSON 0\(lesson.number) • \(language == .tr ? lesson.titleTr : lesson.titleEn)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(.white)

                            Text(language == .tr ? lesson.summaryTr : lesson.summaryEn)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(white: 0.82))

                            Text("PRO TIP: \(language == .tr ? lesson.tipTr : lesson.tipEn)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                        }

                        Spacer()

                        Button {
                            HapticsAndAudioEngine.shared.playTap()
                            onStartDrill(lesson.circuitId)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                Text(L10n.t("academy.practice", language))
                            }
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(18)
        }
    }
}
