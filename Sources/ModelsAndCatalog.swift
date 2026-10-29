import Foundation
import SwiftUI
import simd

// MARK: - Localization

public enum AppLanguage: String, CaseIterable, Codable {
    case en = "en"
    case tr = "tr"

    public var displayName: String {
        switch self {
        case .en: return "English"
        case .tr: return "Türkçe"
        }
    }
}

public struct L10n {
    public static func t(_ key: String, _ lang: AppLanguage) -> String {
        if lang == .tr, let val = trTable[key] {
            return val
        }
        return enTable[key] ?? key
    }

    private static let enTable: [String: String] = [
        "app.title": "LOLLY LAP",
        "app.subtitle": "3D Kart Racing, Garage Dyno & Telemetry Simulator",
        "tab.race": "Quick Race",
        "tab.career": "Career Tour",
        "tab.garage": "3D Garage",
        "tab.telemetry": "Telemetry",
        "tab.academy": "Academy",
        "race.start": "START 3D RACE",
        "race.selectCircuit": "Select 3D Circuit",
        "race.selectDriver": "Select Critter Driver",
        "race.laps": "Race Laps",
        "race.difficulty": "AI Pace",
        "race.controls": "Steering Mode",
        "control.touch": "Touch Buttons",
        "control.tilt": "Gyro Tilt",
        "control.gamepad": "Gamepad / Touch",
        "diff.casual": "Rookie (100cc)",
        "diff.pro": "Pro (150cc)",
        "diff.master": "Apex Master (200cc)",
        "garage.title": "3D Kart Garage & Dyno Lab",
        "garage.subtitle": "Drag the 3D kart to inspect • Tune mechanical setup for each track",
        "garage.paint": "Chassis Paint Finish",
        "garage.rims": "Wheel & Tire Compound",
        "garage.wing": "Aero Rear Wing",
        "garage.dyno": "Mechanical Dyno Tuning",
        "garage.gearRatio": "Final Drive Ratio (Accel vs Top Speed)",
        "garage.downforce": "Aero Wing Downforce (Cornering G)",
        "garage.suspension": "Suspension Stiffness (Drift Response)",
        "garage.boostMix": "Mini-Turbo Injector Pressure",
        "garage.dynoChart": "Simulated Dyno Velocity Curve (km/h vs sec)",
        "career.title": "Starlight World Championship",
        "career.subtitle": "28 Career Events across 7 Championship Cups",
        "career.stars": "Career Stars",
        "career.license": "Driver License",
        "telemetry.title": "Apex Telemetry & Sector Analyzer",
        "telemetry.subtitle": "Apple Charts analysis of your speed trace, drift angles & sector splits",
        "telemetry.speedTrace": "Lap Velocity Trace (km/h)",
        "telemetry.sectorSplits": "Sector Split Comparison (Seconds)",
        "telemetry.coach": "AI Race Engineer Advice",
        "academy.title": "Lolly Lap Racing Academy",
        "academy.subtitle": "Master apex braking, 3-stage drift charging & slipstream drafting",
        "academy.practice": "Launch Track Drill",
        "vip.badge": "LOLLY LAP CLUB • 7-DAY FREE TRIAL",
        "vip.title": "Unlock All 7 Circuits, 6 Drivers & Pro Garage Parts",
        "vip.subtitle": "Start your 7-Day Free Trial. Cancel anytime in App Store Settings.",
        "vip.monthly": "Monthly Plan • $4.99 / month",
        "vip.quarterly": "Quarterly Plan • $4.49 / mo ($13.47 / 3 mo)",
        "vip.annual": "Annual Plan • $3.99 / mo ($47.88 / year)",
        "vip.startTrial": "Start 7-Day Free Trial",
        "vip.restore": "Restore Purchases",
        "vip.manageCancel": "Cancel / Manage Subscription",
        "vip.status.checking": "Verifying with App Store...",
        "vip.status.restored": "Purchases restored! Pro Racing Pass is active.",
        "vip.status.restoreEmpty": "No active subscription found for this account.",
        "vip.status.cancelled": "Purchase cancelled. No charge was made.",
        "vip.status.activated": "Pro Racing Pass activated! All circuits unlocked.",
        "hud.lap": "LAP",
        "hud.pos": "POS",
        "hud.drift": "DRIFT",
        "hud.boost": "BOOST",
        "hud.pause": "RACE PAUSED",
        "hud.resume": "Resume Race",
        "hud.restart": "Restart Race",
        "hud.exit": "Exit to Paddock",
        "result.finished": "RACE COMPLETE!",
        "result.time": "Total Time",
        "result.bestLap": "Best Lap",
        "result.topSpeed": "Peak Speed",
        "result.drifts": "Mini-Turbos",
        "result.playAgain": "Race Again",
        "result.backHub": "Save Telemetry & Exit"
    ]

    private static let trTable: [String: String] = [
        "app.title": "LOLLY LAP",
        "app.subtitle": "3B Kart Yarışı, Garaj Dyno ve Telemetri Simülatörü",
        "tab.race": "Hızlı Yarış",
        "tab.career": "Kariyer Turu",
        "tab.garage": "3B Garaj",
        "tab.telemetry": "Telemetri",
        "tab.academy": "Akademi",
        "race.start": "3B YARIŞI BAŞLAT",
        "race.selectCircuit": "3B Pist Seçimi",
        "race.selectDriver": "Yarışçı Seçimi",
        "race.laps": "Tur Sayısı",
        "race.difficulty": "Yapay Zeka Hızı",
        "race.controls": "Sürüş Kontrolü",
        "control.touch": "Dokunmatik Buton",
        "control.tilt": "Jiroskop Eğim",
        "control.gamepad": "Oyun Kolu / Dokunmatik",
        "diff.casual": "Çaylak (100cc)",
        "diff.pro": "Profesyonel (150cc)",
        "diff.master": "Usta (200cc)",
        "garage.title": "3B Kart Garajı ve Dyno Laboratuvarı",
        "garage.subtitle": "İncelemek için 3B aracı çevirin • Piste göre mekanik ayar yapın",
        "garage.paint": "Şasi Boya Kaplaması",
        "garage.rims": "Jant ve Lastik Hamuru",
        "garage.wing": "Aerodinamik Arka Kanat",
        "garage.dyno": "Mekanik Dyno Ayarları",
        "garage.gearRatio": "Son Dişli Oranı (İvmelenme / Son Hız)",
        "garage.downforce": "Arka Kanat Bastırma Kuvveti (Viraj Tutuşu)",
        "garage.suspension": "Süspansiyon Sertliği (Drift Tepkisi)",
        "garage.boostMix": "Mini-Turbo Enjektör Basıncı",
        "garage.dynoChart": "Simüle Edilen Dyno Hız Eğrisi (km/s - sn)",
        "career.title": "Yıldız Işığı Dünya Şampiyonası",
        "career.subtitle": "7 Şampiyona Kupasında 28 Kariyer Etkinliği",
        "career.stars": "Kariyer Yıldızı",
        "career.license": "Sürücü Lisansı",
        "telemetry.title": "Apex Telemetri ve Sektör Analizi",
        "telemetry.subtitle": "Hız grafiği, drift açıları ve sektör zamanlarının Apple Charts analizi",
        "telemetry.speedTrace": "Tur Hız Grafiği (km/s)",
        "telemetry.sectorSplits": "Sektör Süre Karşılaştırması (Saniye)",
        "telemetry.coach": "Yapay Zeka Yarış Mühendisi Önerisi",
        "academy.title": "Lolly Lap Sürüş Akademisi",
        "academy.subtitle": "Apex frenleme, 3 kademeli drift şarjı ve hava koridoru teknikleri",
        "academy.practice": "Pist Antrenmanını Başlat",
        "vip.badge": "LOLLY LAP CLUB • 7 GÜN ÜCRETSİZ DENEME",
        "vip.title": "Tüm 7 Pisti, 6 Yarışçıyı ve Pro Garaj Parçalarını Açın",
        "vip.subtitle": "7 Gün Ücretsiz Denemeyi başlatın. İstediğiniz zaman iptal edin.",
        "vip.monthly": "Aylık Plan • $4.99 / ay",
        "vip.quarterly": "3 Aylık Plan • $4.49 / ay (3 ayda bir $13.47)",
        "vip.annual": "Yıllık Plan • $3.99 / ay (yıllık $47.88)",
        "vip.startTrial": "7 Gün Ücretsiz Denemeyi Başlat",
        "vip.restore": "Satın Alımları Geri Yükle",
        "vip.manageCancel": "Aboneliği Yönet / İptal Et",
        "vip.status.checking": "App Store ile doğrulanıyor...",
        "vip.status.restored": "Satın alımlarınız geri yüklendi! Pro Yarış Paketi aktif.",
        "vip.status.restoreEmpty": "Bu hesapta aktif bir abonelik bulunamadı.",
        "vip.status.cancelled": "Satın alma işlemi iptal edildi. Ücret yansıtılmadı.",
        "vip.status.activated": "Pro Yarış Paketi aktif edildi! Tüm pistler açıldı.",
        "hud.lap": "TUR",
        "hud.pos": "SIRA",
        "hud.drift": "DRİFT",
        "hud.boost": "TURBO",
        "hud.pause": "YARIŞ DURAKLATILDI",
        "hud.resume": "Yarışa Devam Et",
        "hud.restart": "Yarışı Yeniden Başlat",
        "hud.exit": "Padoğa Dön",
        "result.finished": "YARIŞ TAMAMLANDI!",
        "result.time": "Toplam Süre",
        "result.bestLap": "En İyi Tur",
        "result.topSpeed": "Maksimum Hız",
        "result.drifts": "Mini-Turbolar",
        "result.playAgain": "Tekrar Yarış",
        "result.backHub": "Telemetriyi Kaydet ve Çık"
    ]
}

// MARK: - Circuits (7 Distinct 3D Spline Tracks)

public struct CircuitSpec: Identifiable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameTr: String
    public let subtitleEn: String
    public let subtitleTr: String
    public let lengthMeters: Int
    public let cornerCount: Int
    public let difficultyRating: Int
    public let isFreeInDemo: Bool
    public let skyTopHex: UInt32
    public let skyBottomHex: UInt32
    public let groundHex: UInt32
    public let asphaltHex: UInt32
    public let curbPrimaryHex: UInt32
    public let curbSecondaryHex: UInt32
    public let accentHex: UInt32
    public let controlPoints: [SIMD3<Float>]

    public func localizedName(_ lang: AppLanguage) -> String {
        lang == .tr ? nameTr : nameEn
    }

    public func localizedSubtitle(_ lang: AppLanguage) -> String {
        lang == .tr ? subtitleTr : subtitleEn
    }
}

// MARK: - Critter Drivers (6 Distinct 3D Characters)

public struct CritterDriverSpec: Identifiable, Hashable {
    public let id: String
    public let index: Int
    public let name: String
    public let titleEn: String
    public let titleTr: String
    public let skillNameEn: String
    public let skillNameTr: String
    public let isFreeInDemo: Bool
    public let primaryColorHex: UInt32
    public let secondaryColorHex: UInt32
    public let helmetColorHex: UInt32
    public let baseSpeed: Double
    public let baseAccel: Double
    public let baseHandling: Double
    public let baseDriftBoost: Double

    public func localizedTitle(_ lang: AppLanguage) -> String {
        lang == .tr ? titleTr : titleEn
    }

    public func localizedSkill(_ lang: AppLanguage) -> String {
        lang == .tr ? skillNameTr : skillNameEn
    }
}

// MARK: - Kart Customization & Mechanical Dyno Setup

public struct KartPaintOption: Identifiable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameTr: String
    public let bodyHex: UInt32
    public let trimHex: UInt32
    public let metalness: Float
    public let roughness: Float
}

public struct KartRimOption: Identifiable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameTr: String
    public let rimHex: UInt32
    public let gripBonus: Double
    public let spokeCount: Int
}

public struct KartWingOption: Identifiable, Hashable {
    public let id: String
    public let nameEn: String
    public let nameTr: String
    public let wingHex: UInt32
    public let downforceBonus: Double
    public let styleIndex: Int
}

public struct KartLoadout: Codable, Equatable {
    public var paintId: String = "candy_pink"
    public var rimId: String = "aero_gold"
    public var wingId: String = "gt_swan"
    public var finalDriveRatio: Double = 0.55     // 0 = max accel, 1 = max top speed
    public var aeroDownforce: Double = 0.60       // 0 = low drag, 1 = max cornering G
    public var suspensionStiffness: Double = 0.65 // 0 = soft, 1 = sharp drift initiation
    public var driftBoostMix: Double = 0.70       // 0 = long duration, 1 = explosive burst

    public init(
        paintId: String = "candy_pink",
        rimId: String = "aero_gold",
        wingId: String = "gt_swan",
        finalDriveRatio: Double = 0.55,
        aeroDownforce: Double = 0.60,
        suspensionStiffness: Double = 0.65,
        driftBoostMix: Double = 0.70
    ) {
        self.paintId = paintId
        self.rimId = rimId
        self.wingId = wingId
        self.finalDriveRatio = finalDriveRatio
        self.aeroDownforce = aeroDownforce
        self.suspensionStiffness = suspensionStiffness
        self.driftBoostMix = driftBoostMix
    }
}

// MARK: - Career Mode & Telemetry Models

public enum CareerEventType: String, Codable {
    case grandPrix = "Grand Prix"
    case timeAttack = "Time Attack"
    case driftChallenge = "Drift Gate"
    case elimination = "Knockout"
}

public struct CareerEventSpec: Identifiable, Hashable {
    public let id: String
    public let chapterIndex: Int
    public let eventIndex: Int
    public let titleEn: String
    public let titleTr: String
    public let circuitId: String
    public let eventType: CareerEventType
    public let laps: Int
    public let targetTimeSeconds: Double
    public let targetDriftPoints: Int
}

public struct TelemetryPoint: Identifiable, Codable {
    public var id: Int { sampleIndex }
    public let sampleIndex: Int
    public let distanceNormalized: Double
    public let speedKmh: Double
    public let proReferenceKmh: Double
    public let driftAngleDeg: Double
}

public struct LapTelemetryRecord: Identifiable, Codable {
    public let id: UUID
    public let circuitId: String
    public let driverId: String
    public let timestamp: Date
    public let totalTimeSeconds: Double
    public let bestLapSeconds: Double
    public let sector1Seconds: Double
    public let sector2Seconds: Double
    public let sector3Seconds: Double
    public let peakSpeedKmh: Double
    public let miniTurboCount: Int
    public let finishPosition: Int
    public let samples: [TelemetryPoint]
}

public struct AcademyLesson: Identifiable {
    public let id: String
    public let number: Int
    public let titleEn: String
    public let titleTr: String
    public let summaryEn: String
    public let summaryTr: String
    public let tipEn: String
    public let tipTr: String
    public let circuitId: String
    public let iconName: String
}

// MARK: - Master Catalog

public enum GameCatalog {
    public static let circuits: [CircuitSpec] = [
        CircuitSpec(
            id: "candy",
            nameEn: "Starlight Valley",
            nameTr: "Yıldız Işığı Vadisi",
            subtitleEn: "Sugar-glazed sweeping hairpins, twin boost straights & pastel canyon bridges",
            subtitleTr: "Şeker kaplı geniş virajlar, çift turbo düzlüğü ve pastel kanyon köprüleri",
            lengthMeters: 1420,
            cornerCount: 9,
            difficultyRating: 1,
            isFreeInDemo: true,
            skyTopHex: 0x1E1B4B,
            skyBottomHex: 0xF472B6,
            groundHex: 0xFDE68A,
            asphaltHex: 0x3B2F4A,
            curbPrimaryHex: 0xFF4D94,
            curbSecondaryHex: 0xFFFFFF,
            accentHex: 0x38BDF8,
            controlPoints: [
                SIMD3<Float>(0, 0, -110),
                SIMD3<Float>(85, 2, -95),
                SIMD3<Float>(130, 5, -30),
                SIMD3<Float>(110, 3, 55),
                SIMD3<Float>(45, 0, 105),
                SIMD3<Float>(-35, 4, 115),
                SIMD3<Float>(-110, 6, 70),
                SIMD3<Float>(-135, 2, -15),
                SIMD3<Float>(-80, 0, -85)
            ]
        ),
        CircuitSpec(
            id: "canyon",
            nameEn: "Crystal Canyon",
            nameTr: "Kristal Kanyon",
            subtitleEn: "High-speed amethyst gorges with banked switchbacks & glowing prism tunnels",
            subtitleTr: "Eğimli virajlar ve parlayan prizma tünelleriyle yüksek hızlı ametist vadisi",
            lengthMeters: 1680,
            cornerCount: 11,
            difficultyRating: 2,
            isFreeInDemo: false,
            skyTopHex: 0x0F172A,
            skyBottomHex: 0x7C3AED,
            groundHex: 0x4C1D95,
            asphaltHex: 0x1E1B4B,
            curbPrimaryHex: 0xA855F7,
            curbSecondaryHex: 0x38BDF8,
            accentHex: 0xF43F5E,
            controlPoints: [
                SIMD3<Float>(0, 0, -125),
                SIMD3<Float>(105, 6, -100),
                SIMD3<Float>(145, 10, -10),
                SIMD3<Float>(90, 4, 45),
                SIMD3<Float>(125, 2, 105),
                SIMD3<Float>(20, 0, 130),
                SIMD3<Float>(-75, 5, 95),
                SIMD3<Float>(-130, 8, 25),
                SIMD3<Float>(-105, 3, -75)
            ]
        ),
        CircuitSpec(
            id: "neon",
            nameEn: "Neon Bay",
            nameTr: "Neon Koy",
            subtitleEn: "Cyber-pastel coastal highway with double-apex chicanes & synthwave boardwalks",
            subtitleTr: "Çift apeksli şikanlar ve sahil viyadükleriyle siber-pastel otoyol",
            lengthMeters: 1790,
            cornerCount: 12,
            difficultyRating: 3,
            isFreeInDemo: false,
            skyTopHex: 0x020617,
            skyBottomHex: 0x0EA5E9,
            groundHex: 0x0F172A,
            asphaltHex: 0x1E293B,
            curbPrimaryHex: 0x06B6D4,
            curbSecondaryHex: 0xEC4899,
            accentHex: 0xFACC15,
            controlPoints: [
                SIMD3<Float>(0, 0, -130),
                SIMD3<Float>(95, 0, -110),
                SIMD3<Float>(150, 4, -45),
                SIMD3<Float>(80, 6, 15),
                SIMD3<Float>(135, 3, 85),
                SIMD3<Float>(40, 0, 125),
                SIMD3<Float>(-55, 2, 110),
                SIMD3<Float>(-140, 5, 45),
                SIMD3<Float>(-95, 0, -65)
            ]
        ),
        CircuitSpec(
            id: "forest",
            nameEn: "Marshmallow Woods",
            nameTr: "Şeker Ormanı",
            subtitleEn: "Enchanted giant-mushroom canopy with flowing S-curves & caramel river jumps",
            subtitleTr: "Dev mantar ağaçları, akıcı S-virajları ve karamel nehri geçişleri",
            lengthMeters: 1540,
            cornerCount: 10,
            difficultyRating: 2,
            isFreeInDemo: false,
            skyTopHex: 0x064E3B,
            skyBottomHex: 0x34D399,
            groundHex: 0x065F46,
            asphaltHex: 0x374151,
            curbPrimaryHex: 0x10B981,
            curbSecondaryHex: 0xFEF3C7,
            accentHex: 0xF59E0B,
            controlPoints: [
                SIMD3<Float>(0, 0, -115),
                SIMD3<Float>(80, 3, -95),
                SIMD3<Float>(120, 7, -25),
                SIMD3<Float>(95, 2, 65),
                SIMD3<Float>(15, 0, 115),
                SIMD3<Float>(-65, 4, 105),
                SIMD3<Float>(-125, 6, 35),
                SIMD3<Float>(-90, 2, -55)
            ]
        ),
        CircuitSpec(
            id: "glacier",
            nameEn: "Glacier Peak",
            nameTr: "Buzul Zirvesi",
            subtitleEn: "Alpine aurora ice circuit demanding precise counter-steering & long drift chains",
            subtitleTr: "Hassas kontra direksiyon ve uzun drift zincirleri gerektiren kutup ışığı pisti",
            lengthMeters: 1850,
            cornerCount: 14,
            difficultyRating: 4,
            isFreeInDemo: false,
            skyTopHex: 0x082F49,
            skyBottomHex: 0x7DD3FC,
            groundHex: 0xE0F2FE,
            asphaltHex: 0x334155,
            curbPrimaryHex: 0x38BDF8,
            curbSecondaryHex: 0xFFFFFF,
            accentHex: 0x818CF8,
            controlPoints: [
                SIMD3<Float>(0, 0, -135),
                SIMD3<Float>(110, 8, -105),
                SIMD3<Float>(155, 12, -20),
                SIMD3<Float>(105, 6, 65),
                SIMD3<Float>(25, 2, 130),
                SIMD3<Float>(-70, 5, 115),
                SIMD3<Float>(-145, 9, 40),
                SIMD3<Float>(-110, 3, -65)
            ]
        ),
        CircuitSpec(
            id: "lava",
            nameEn: "Lava Caldera",
            nameTr: "Lav Kalderası",
            subtitleEn: "Volcanic obsidian rim with extreme elevation drops & thermal boost vents",
            subtitleTr: "Keskin irtifa düşüşleri ve termal hızlandırma bacalarıyla volkanik obsidyen krateri",
            lengthMeters: 1920,
            cornerCount: 15,
            difficultyRating: 4,
            isFreeInDemo: false,
            skyTopHex: 0x450A0A,
            skyBottomHex: 0xF97316,
            groundHex: 0x7F1D1D,
            asphaltHex: 0x1C1917,
            curbPrimaryHex: 0xEF4444,
            curbSecondaryHex: 0xFACC15,
            accentHex: 0xFB923C,
            controlPoints: [
                SIMD3<Float>(0, 0, -140),
                SIMD3<Float>(115, 10, -110),
                SIMD3<Float>(160, 14, -15),
                SIMD3<Float>(95, 4, 55),
                SIMD3<Float>(130, 2, 115),
                SIMD3<Float>(10, 0, 135),
                SIMD3<Float>(-95, 8, 95),
                SIMD3<Float>(-150, 11, 15),
                SIMD3<Float>(-100, 4, -80)
            ]
        ),
        CircuitSpec(
            id: "sky",
            nameEn: "Sky Citadel",
            nameTr: "Gökyüzü Kalesi",
            subtitleEn: "Cloud-top celestial Causeway with rainbow speed ribbons & zero-margin hairpins",
            subtitleTr: "Gökkuşağı hız şeritleri ve bulutların üzerinde şampiyonluk final pisti",
            lengthMeters: 2100,
            cornerCount: 16,
            difficultyRating: 5,
            isFreeInDemo: false,
            skyTopHex: 0x1E1B4B,
            skyBottomHex: 0xC084FC,
            groundHex: 0xEDE9FE,
            asphaltHex: 0x312E81,
            curbPrimaryHex: 0xFBBF24,
            curbSecondaryHex: 0xEC4899,
            accentHex: 0x38BDF8,
            controlPoints: [
                SIMD3<Float>(0, 0, -145),
                SIMD3<Float>(120, 12, -115),
                SIMD3<Float>(165, 16, -25),
                SIMD3<Float>(115, 8, 55),
                SIMD3<Float>(45, 4, 135),
                SIMD3<Float>(-55, 6, 130),
                SIMD3<Float>(-145, 14, 65),
                SIMD3<Float>(-155, 8, -25),
                SIMD3<Float>(-95, 2, -95)
            ]
        )
    ]

    public static let drivers: [CritterDriverSpec] = [
        CritterDriverSpec(
            id: "luna",
            index: 0,
            name: "Luna Axolotl",
            titleEn: " Precision Drift Specialist",
            titleTr: "Hassas Drift Uzmanı",
            skillNameEn: "Bubble Slipstream Surge",
            skillNameTr: "Baloncuk Hava Koridoru Turbosu",
            isFreeInDemo: true,
            primaryColorHex: 0xFF66B2,
            secondaryColorHex: 0x38BDF8,
            helmetColorHex: 0xFFFFFF,
            baseSpeed: 0.84,
            baseAccel: 0.90,
            baseHandling: 0.95,
            baseDriftBoost: 0.92
        ),
        CritterDriverSpec(
            id: "mochi",
            index: 1,
            name: "Mochi Shiba",
            titleEn: "Apex Acceleration Ace",
            titleTr: "Apex İvmelenme Ustası",
            skillNameEn: "Golden Biscuit Overdrive",
            skillNameTr: "Altın Bisküvi Aşırı Yüklemesi",
            isFreeInDemo: false,
            primaryColorHex: 0xF59E0B,
            secondaryColorHex: 0xFEF3C7,
            helmetColorHex: 0xEF4444,
            baseSpeed: 0.88,
            baseAccel: 0.94,
            baseHandling: 0.86,
            baseDriftBoost: 0.88
        ),
        CritterDriverSpec(
            id: "pip",
            index: 2,
            name: "Pip Penguin",
            titleEn: "Ice-Line Cornering Tactician",
            titleTr: "Buz Çizgisi Viraj Taktisyeni",
            skillNameEn: "Subzero Cryo-Grip",
            skillNameTr: "Sıfır Altı Kriyo-Tutuş",
            isFreeInDemo: false,
            primaryColorHex: 0x0EA5E9,
            secondaryColorHex: 0xF8FAFC,
            helmetColorHex: 0xFACC15,
            baseSpeed: 0.82,
            baseAccel: 0.92,
            baseHandling: 0.98,
            baseDriftBoost: 0.90
        ),
        CritterDriverSpec(
            id: "blaze",
            index: 3,
            name: "Blaze Dragon",
            titleEn: "Heavyweight Top-Speed Titan",
            titleTr: "Ağır Siklet Son Hız Titanı",
            skillNameEn: "Twin-Afterburner Jet",
            skillNameTr: "Çift Art Yakıcı Jet İtişi",
            isFreeInDemo: false,
            primaryColorHex: 0xEF4444,
            secondaryColorHex: 0xF97316,
            helmetColorHex: 0x1E293B,
            baseSpeed: 0.98,
            baseAccel: 0.78,
            baseHandling: 0.80,
            baseDriftBoost: 0.95
        ),
        CritterDriverSpec(
            id: "koko",
            index: 4,
            name: "Koko Red Panda",
            titleEn: "Mini-Turbo Chain Virtuoso",
            titleTr: "Mini-Turbo Zincir Virtüözü",
            skillNameEn: "Bamboo Spark Cascade",
            skillNameTr: "Bambu Kıvılcım Şelalesi",
            isFreeInDemo: false,
            primaryColorHex: 0xEA580C,
            secondaryColorHex: 0xFED7AA,
            helmetColorHex: 0x10B981,
            baseSpeed: 0.86,
            baseAccel: 0.89,
            baseHandling: 0.91,
            baseDriftBoost: 0.98
        ),
        CritterDriverSpec(
            id: "astra",
            index: 5,
            name: "Astra Unicorn",
            titleEn: "Grand Prix All-Round Legend",
            titleTr: "Grand Prix Çok Yönlü Efsanesi",
            skillNameEn: "Starlight Nova Warp",
            skillNameTr: "Yıldız Işığı Nova Sıçraması",
            isFreeInDemo: false,
            primaryColorHex: 0xA855F7,
            secondaryColorHex: 0xF472B6,
            helmetColorHex: 0xFBBF24,
            baseSpeed: 0.94,
            baseAccel: 0.92,
            baseHandling: 0.93,
            baseDriftBoost: 0.96
        )
    ]

    public static let paints: [KartPaintOption] = [
        KartPaintOption(id: "candy_pink", nameEn: "Starlight Rose Metallic", nameTr: "Yıldız Pembesi Metalik", bodyHex: 0xFF4D94, trimHex: 0x38BDF8, metalness: 0.65, roughness: 0.22),
        KartPaintOption(id: "cyber_cyan", nameEn: "Neon Pulse Cyan", nameTr: "Neon Siyan", bodyHex: 0x06B6D4, trimHex: 0xF472B6, metalness: 0.75, roughness: 0.18),
        KartPaintOption(id: "solar_gold", nameEn: "Championship Gold Chrome", nameTr: "Şampiyonluk Altın Krom", bodyHex: 0xF59E0B, trimHex: 0xFEF3C7, metalness: 0.90, roughness: 0.12),
        KartPaintOption(id: "amethyst_pearl", nameEn: "Crystal Amethyst Pearl", nameTr: "Kristal Ametist Sedef", bodyHex: 0x8B5CF6, trimHex: 0x38BDF8, metalness: 0.60, roughness: 0.25),
        KartPaintOption(id: "emerald_mint", nameEn: "Glacier Mint Satin", nameTr: "Buzul Nanesi Saten", bodyHex: 0x10B981, trimHex: 0xFFFFFF, metalness: 0.50, roughness: 0.30),
        KartPaintOption(id: "crimson_lava", nameEn: "Caldera Magma Red", nameTr: "Kaldera Magma Kırmızısı", bodyHex: 0xEF4444, trimHex: 0xFACC15, metalness: 0.70, roughness: 0.20)
    ]

    public static let rims: [KartRimOption] = [
        KartRimOption(id: "aero_gold", nameEn: "Aero Forged Gold", nameTr: "Aero Dövme Altın", rimHex: 0xFBBF24, gripBonus: 0.04, spokeCount: 6),
        KartRimOption(id: "neon_turbine", nameEn: "Cyber Cyan Turbine", nameTr: "Siber Siyan Türbin", rimHex: 0x38BDF8, gripBonus: 0.06, spokeCount: 8),
        KartRimOption(id: "white_rally", nameEn: "Tarmac Rally White", nameTr: "Asfalt Ralli Beyazı", rimHex: 0xF8FAFC, gripBonus: 0.05, spokeCount: 10),
        KartRimOption(id: "rose_deep", nameEn: "Candy Dish Magenta", nameTr: "Şeker Pembe Ofset", rimHex: 0xEC4899, gripBonus: 0.07, spokeCount: 5)
    ]

    public static let wings: [KartWingOption] = [
        KartWingOption(id: "gt_swan", nameEn: "GT Swan-Neck Carbon", nameTr: "GT Kuğu Boyun Karbon", wingHex: 0x38BDF8, downforceBonus: 0.05, styleIndex: 0),
        KartWingOption(id: "twin_biplane", nameEn: "Twin-Deck Time Attack", nameTr: "Çift Katlı Time Attack", wingHex: 0xFF4D94, downforceBonus: 0.08, styleIndex: 1),
        KartWingOption(id: "halo_crown", nameEn: "Starlight Halo Fin", nameTr: "Yıldız Halesi Kanat", wingHex: 0xFBBF24, downforceBonus: 0.09, styleIndex: 2)
    ]

    public static let careerEvents: [CareerEventSpec] = {
        var list: [CareerEventSpec] = []
        let types: [CareerEventType] = [.grandPrix, .timeAttack, .driftChallenge, .elimination]
        for (cIdx, circuit) in circuits.enumerated() {
            for (eIdx, t) in types.enumerated() {
                let baseTime = Double(circuit.lengthMeters) / 22.0
                list.append(
                    CareerEventSpec(
                        id: "ch\(cIdx + 1)_ev\(eIdx + 1)",
                        chapterIndex: cIdx + 1,
                        eventIndex: eIdx + 1,
                        titleEn: "\(circuit.nameEn) • \(t.rawValue)",
                        titleTr: "\(circuit.nameTr) • \(t.rawValue)",
                        circuitId: circuit.id,
                        eventType: t,
                        laps: t == .timeAttack ? 2 : 3,
                        targetTimeSeconds: baseTime * (t == .timeAttack ? 1.85 : 2.75),
                        targetDriftPoints: 1200 + cIdx * 350 + eIdx * 200
                    )
                )
            }
        }
        return list
    }()

    public static let academyLessons: [AcademyLesson] = [
        AcademyLesson(
            id: "apex_entry",
            number: 1,
            titleEn: "Outside-Inside-Outside Apex Line",
            titleTr: "Dış-İç-Dış Apex Viraj Çizgisi",
            summaryEn: "Approach wide on entry, clip the inner candy curb at the geometric apex, and unwind steering toward the exit curb to carry +14% cornering speed.",
            summaryTr: "Viraja dıştan yaklaşın, tam orta noktada iç bordüre değin ve çıkışta direksiyonu düzleştirerek viraj hızınızı %14 artırın.",
            tipEn: "Increase Aero Wing Downforce in the 3D Garage if the rear steps out too early.",
            tipTr: "Arka kısım erken kayıyorsa 3B Garajda Arka Kanat Bastırma Kuvvetini artırın.",
            circuitId: "candy",
            iconName: "point.topleft.down.curvedto.point.bottomright.up"
        ),
        AcademyLesson(
            id: "three_stage_drift",
            number: 2,
            titleEn: "3-Stage Mini-Turbo Drift Charging",
            titleTr: "3 Kademeli Mini-Turbo Drift Şarjı",
            summaryEn: "Hold the DRIFT pedal while steering into a corner. Sparks evolve from Blue (Tier 1) to Orange (Tier 2) to Purple Ultra-Boost (Tier 3). Release to ignite!",
            summaryTr: "Viraja girerken DRİFT pedalını basılı tutun. Kıvılcımlar Mavi -> Turuncu -> Mor Ultra-Turbo'ya dönüşür. Bıraktığınızda roket gibi fırlarsınız!",
            tipEn: "Counter-steer toward the outside wall during a long drift to charge Tier 3 without hitting the inside barrier.",
            tipTr: "Uzun virajlarda iç bariyere çarpmadan 3. kademeyi doldurmak için dışa doğru kontra verin.",
            circuitId: "canyon",
            iconName: "flame.fill"
        ),
        AcademyLesson(
            id: "slipstream_draft",
            number: 3,
            titleEn: "Aerodynamic Slipstream Drafting",
            titleTr: "Aerodinamik Hava Koridoru (Slipstream)",
            summaryEn: "Tuck directly behind a rival kart within 18 meters for 1.2 seconds to enter their low-pressure wake and gain an automatic +18 km/h slingshot.",
            summaryTr: "Rakip aracın 18 metre arkasında 1.2 saniye kalarak düşük basınç koridoruna girin ve +18 km/s geçiş hızı kazanın.",
            tipEn: "Combine a Slipstream Slingshot with a Tier 2 Drift release exiting the final corner.",
            tipTr: "Son viraj çıkışında Hava Koridoru hızını 2. Kademe Drift turbosuyla birleştirin.",
            circuitId: "neon",
            iconName: "wind"
        ),
        AcademyLesson(
            id: "dyno_gearing",
            number: 4,
            titleEn: "Track-Specific Mechanical Dyno Setup",
            titleTr: "Piste Özel Mekanik Dyno Ayarı",
            summaryEn: "Tight technical tracks (Glacier Peak, Marshmallow Woods) reward a shorter Final Drive Ratio (0.35–0.45), while long straights (Sky Citadel) demand 0.75+.",
            summaryTr: "Bol virajlı teknik pistlerde kısa dişli oranı (0.35–0.45), uzun düzlüklerde ise 0.75 üzeri son dişli oranı kullanın.",
            tipEn: "Check the Telemetry Lab after each race to see where your speed plateaued.",
            tipTr: "Yarıştan sonra Telemetri Laboratuvarında hızınızın nerede tavana vurduğunu inceleyin.",
            circuitId: "glacier",
            iconName: "gauge.with.dots.needle.67percent"
        )
    ]
}
