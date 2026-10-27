import Foundation
import SceneKit
import SwiftUI
import CoreMotion
import GameController
import simd

public enum SteeringControlMode: String, CaseIterable, Codable {
    case touch = "touch"
    case tilt = "tilt"
    case gamepad = "gamepad"
}

public enum RaceItemType: String, CaseIterable {
    case starlightTurbo = "Starlight Turbo"
    case sugarRocket = "Sugar Rocket"
    case cryoPulse = "Cryo Shockwave"
    case bubbleShield = "Bubble Shield"

    public var iconName: String {
        switch self {
        case .starlightTurbo: return "bolt.fill"
        case .sugarRocket: return "paperplane.fill"
        case .cryoPulse: return "snowflake"
        case .bubbleShield: return "shield.lefthalf.filled"
        }
    }
}

public final class RacerInstance {
    public let driver: CritterDriverSpec
    public let isPlayer: Bool
    public let node: SCNNode
    public var normalizedT: Float
    public var lateralOffset: Float
    public var targetLateral: Float
    public var speedMetersPerSec: Float = 0
    public var currentLap: Int = 1
    public var totalProgress: Float = 0
    public var boostTimer: Float = 0

    public init(driver: CritterDriverSpec, isPlayer: Bool, node: SCNNode, startT: Float, lateral: Float) {
        self.driver = driver
        self.isPlayer = isPlayer
        self.node = node
        self.normalizedT = startT
        self.lateralOffset = lateral
        self.targetLateral = lateral
        self.totalProgress = startT
    }
}

@MainActor
public final class RaceSimulationEngine: NSObject, ObservableObject {
    // Published HUD State
    @Published public var isPaused: Bool = false
    @Published public var isRaceFinished: Bool = false
    @Published public var countdownValue: Int = 3
    @Published public var countdownText: String = "3"
    @Published public var speedKmh: Int = 0
    @Published public var currentLap: Int = 1
    @Published public var totalLaps: Int = 3
    @Published public var currentPlace: Int = 1
    @Published public var elapsedSeconds: Double = 0
    @Published public var currentLapSeconds: Double = 0
    @Published public var bestLapSeconds: Double = 0
    @Published public var sector1Split: Double = 0
    @Published public var sector2Split: Double = 0
    @Published public var sector3Split: Double = 0
    @Published public var driftTier: Int = 0
    @Published public var driftChargeProgress: Double = 0
    @Published public var boostActive: Bool = false
    @Published public var heldItem: RaceItemType? = nil
    @Published public var statusBanner: String = ""
    @Published public var minimapPoints: [CGPoint] = []
    @Published public var playerMinimapPoint: CGPoint = .zero
    @Published public var aiMinimapPoints: [CGPoint] = []
    @Published public var completedTelemetry: LapTelemetryRecord? = nil

    // Inputs
    public var touchSteerAxis: Float = 0 // -1 left, +1 right
    public var isDriftingInput: Bool = false
    public var isBrakingInput: Bool = false
    public var controlMode: SteeringControlMode = .touch

    // Scene & Simulation Objects
    public let scene: SCNScene
    public let cameraNode: SCNNode
    public let circuit: CircuitSpec
    public let playerDriver: CritterDriverSpec
    public let loadout: KartLoadout
    public let difficultyIndex: Int
    private let spline: TrackSpline
    private var racers: [RacerInstance] = []
    private var boostPadTs: [Float] = []
    private var itemBoxes: [(node: SCNNode, t: Float, lateral: Float, cooldown: Float)] = []

    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var countdownTimer: Double = 2.6
    private var driftAccumSeconds: Float = 0
    private var driftDirection: Float = 0
    private var peakSpeedRecorded: Double = 0
    private var miniTurboCount: Int = 0
    private var sectorStartElapsed: Double = 0
    private var currentSectorIndex: Int = 0
    private var recordedSamples: [TelemetryPoint] = []
    private var nextTelemetryBucket: Int = 0
    private let motionManager = CMMotionManager()

    public init(circuit: CircuitSpec, driver: CritterDriverSpec, loadout: KartLoadout, laps: Int, difficulty: Int, controlMode: SteeringControlMode) {
        self.circuit = circuit
        self.playerDriver = driver
        self.loadout = loadout
        self.totalLaps = max(1, laps)
        self.difficultyIndex = difficulty
        self.controlMode = controlMode

        let builtSpline = TrackSpline(controlPoints: circuit.controlPoints)
        self.spline = builtSpline

        let built = SceneKitMeshBuilder.buildCircuitScene(spec: circuit, spline: builtSpline)
        self.scene = built.scene
        self.boostPadTs = built.boostPadTs
        self.itemBoxes = built.itemBoxNodes.map { ($0.node, $0.t, $0.lateral, 0.0) }

        let camNode = SCNNode()
        let cam = SCNCamera()
        cam.fieldOfView = 68
        cam.zNear = 0.3
        cam.zFar = 420
        cam.wantsHDR = true
        camNode.camera = cam
        built.scene.rootNode.addChildNode(camNode)
        self.cameraNode = camNode

        super.init()
        setupGridRacers()
        buildMinimapPath()
        startSensorsIfNeeded()
    }

    private func setupGridRacers() {
        var gridDrivers: [CritterDriverSpec] = [playerDriver]
        for d in GameCatalog.drivers where d.id != playerDriver.id {
            gridDrivers.append(d)
        }

        for (idx, d) in gridDrivers.prefix(6).enumerated() {
            let isPlayer = (idx == 0)
            let kartLoadout = isPlayer ? loadout : KartLoadout(
                paintId: GameCatalog.paints[idx % GameCatalog.paints.count].id,
                rimId: GameCatalog.rims[idx % GameCatalog.rims.count].id,
                wingId: GameCatalog.wings[idx % GameCatalog.wings.count].id
            )
            let kartNode = SceneKitMeshBuilder.buildKartNode(driver: d, loadout: kartLoadout)
            scene.rootNode.addChildNode(kartNode)

            let startT: Float = 0.985 - Float(idx) * 0.006
            let lateral: Float = (idx % 2 == 0) ? -2.2 : 2.2
            let instance = RacerInstance(driver: d, isPlayer: isPlayer, node: kartNode, startT: startT, lateral: lateral)
            instance.totalProgress = Float(idx) * -0.006
            racers.append(instance)
        }
        updateKartTransforms(dt: 0.016)
    }

    private func buildMinimapPath() {
        var minX: Float = 9999, maxX: Float = -9999
        var minZ: Float = 9999, maxZ: Float = -9999
        for p in spline.samples {
            minX = min(minX, p.x); maxX = max(maxX, p.x)
            minZ = min(minZ, p.z); maxZ = max(maxZ, p.z)
        }
        let spanX = max(1.0, maxX - minX)
        let spanZ = max(1.0, maxZ - minZ)

        var pts: [CGPoint] = []
        for i in stride(from: 0, to: spline.samples.count, by: 3) {
            let p = spline.samples[i]
            let nx = CGFloat((p.x - minX) / spanX)
            let nz = CGFloat((p.z - minZ) / spanZ)
            pts.append(CGPoint(x: nx, y: nz))
        }
        self.minimapPoints = pts
    }

    private func normalizeMinimap(_ pos: SIMD3<Float>) -> CGPoint {
        var minX: Float = 9999, maxX: Float = -9999
        var minZ: Float = 9999, maxZ: Float = -9999
        for p in spline.samples {
            minX = min(minX, p.x); maxX = max(maxX, p.x)
            minZ = min(minZ, p.z); maxZ = max(maxZ, p.z)
        }
        let spanX = max(1.0, maxX - minX)
        let spanZ = max(1.0, maxZ - minZ)
        return CGPoint(
            x: CGFloat((pos.x - minX) / spanX),
            y: CGFloat((pos.z - minZ) / spanZ)
        )
    }

    public func startLoop() {
        stopLoop()
        lastTimestamp = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(stepFrame(_:)))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 60)
        link.add(to: .main, forMode: .common)
        self.displayLink = link
    }

    public func stopLoop() {
        displayLink?.invalidate()
        displayLink = nil
        motionManager.stopDeviceMotionUpdates()
    }

    private func startSensorsIfNeeded() {
        if controlMode == .tilt && motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates()
        }
    }

    public func triggerBoostButton() {
        guard countdownValue <= 0, !isPaused, !isRaceFinished else { return }
        guard let player = racers.first else { return }
        if let item = heldItem {
            heldItem = nil
            activateItem(item, for: player)
        } else if driftTier > 0 {
            releaseDriftBoost(for: player)
        } else if player.boostTimer <= 0 {
            player.boostTimer = 1.15
            boostActive = true
            statusBanner = "NITRO PULSE!"
            HapticsAndAudioEngine.shared.playBoostBurst()
        }
    }

    private func activateItem(_ item: RaceItemType, for player: RacerInstance) {
        HapticsAndAudioEngine.shared.playBoostBurst()
        switch item {
        case .starlightTurbo:
            player.boostTimer = 2.4
            boostActive = true
            statusBanner = "STARLIGHT OVERDRIVE!"
        case .sugarRocket:
            player.boostTimer = 1.6
            for ai in racers.dropFirst() where ai.totalProgress > player.totalProgress {
                ai.speedMetersPerSec *= 0.58
            }
            statusBanner = "SUGAR ROCKET HIT!"
        case .cryoPulse:
            for ai in racers.dropFirst() {
                ai.speedMetersPerSec *= 0.65
            }
            statusBanner = "CRYO SHOCKWAVE!"
        case .bubbleShield:
            player.boostTimer = 1.9
            boostActive = true
            statusBanner = "BUBBLE SLIPSTREAM!"
        }
    }

    private func releaseDriftBoost(for player: RacerInstance) {
        let boostDuration: Float = driftTier == 1 ? 0.9 : (driftTier == 2 ? 1.55 : 2.35)
        player.boostTimer = max(player.boostTimer, boostDuration * Float(0.85 + loadout.driftBoostMix * 0.35))
        boostActive = true
        miniTurboCount += 1
        statusBanner = driftTier >= 3 ? "ULTRA MINI-TURBO!" : (driftTier == 2 ? "SUPER DRIFT BOOST!" : "MINI-TURBO!")
        driftTier = 0
        driftAccumSeconds = 0
        driftChargeProgress = 0
        HapticsAndAudioEngine.shared.playBoostBurst()
    }

    @objc private func stepFrame(_ link: CADisplayLink) {
        let now = link.timestamp
        let rawDt = Float(max(0.001, min(0.05, now - lastTimestamp)))
        lastTimestamp = now

        guard !isPaused && !isRaceFinished else { return }

        // Countdown Sequence
        if countdownTimer > 0 {
            let prevSec = Int(ceil(countdownTimer))
            countdownTimer -= Double(rawDt)
            let newSec = Int(ceil(max(0, countdownTimer)))
            if newSec != prevSec {
                if newSec > 0 {
                    countdownValue = newSec
                    countdownText = "\(newSec)"
                    HapticsAndAudioEngine.shared.playCountdownTick(finalGo: false)
                } else {
                    countdownValue = 0
                    countdownText = "GO!"
                    HapticsAndAudioEngine.shared.playCountdownTick(finalGo: true)
                }
            }
            updateKartTransforms(dt: rawDt)
            return
        } else if countdownText == "GO!" && elapsedSeconds > 0.8 {
            countdownText = ""
        }

        elapsedSeconds += Double(rawDt)
        currentLapSeconds += Double(rawDt)

        stepPlayerPhysics(dt: rawDt)
        stepAIPhysics(dt: rawDt)
        updateItemBoxes(dt: rawDt)
        updateStandingsAndLapSplits()
        updateKartTransforms(dt: rawDt)
    }

    private func readActiveSteeringInput() -> Float {
        var steer = touchSteerAxis
        if let pad = GCController.current?.extendedGamepad {
            let stick = pad.leftThumbstick.xAxis.value
            if abs(stick) > 0.08 { steer = stick }
            if pad.rightTrigger.isPressed || pad.buttonA.isPressed {
                isDriftingInput = pad.leftTrigger.isPressed || pad.buttonB.isPressed
            }
        } else if controlMode == .tilt, let motion = motionManager.deviceMotion {
            let tilt = Float(motion.gravity.y) * 2.35
            steer = max(-1.0, min(1.0, tilt))
        }
        return max(-1.0, min(1.0, steer))
    }

    private func stepPlayerPhysics(dt: Float) {
        guard let player = racers.first else { return }
        let steer = readActiveSteeringInput()

        // Mechanical Dyno Computed Base Top Speed & Acceleration
        let baseTopSpeed: Float = 36.0 + Float(playerDriver.baseSpeed) * 8.5 + Float(loadout.finalDriveRatio) * 5.2 - Float(loadout.aeroDownforce) * 1.6
        let boostBonus: Float = player.boostTimer > 0 ? (11.5 + Float(loadout.driftBoostMix) * 4.5) : 0.0
        let offroadPenalty: Float = abs(player.lateralOffset) > (spline.trackHalfWidth - 0.6) ? 0.74 : 1.0
        let targetSpeed = (isBrakingInput ? baseTopSpeed * 0.45 : (baseTopSpeed + boostBonus)) * offroadPenalty

        let accelRate: Float = 16.5 + Float(playerDriver.baseAccel) * 7.5 + Float(1.0 - loadout.finalDriveRatio) * 4.5
        if player.speedMetersPerSec < targetSpeed {
            player.speedMetersPerSec = min(targetSpeed, player.speedMetersPerSec + accelRate * dt)
        } else {
            player.speedMetersPerSec = max(targetSpeed, player.speedMetersPerSec - 14.0 * dt)
        }

        if player.boostTimer > 0 {
            player.boostTimer = max(0, player.boostTimer - dt)
            boostActive = player.boostTimer > 0
        } else {
            boostActive = false
        }

        // Lateral Steering & 3-Stage Drift Charging
        let handlingFactor: Float = 8.4 + Float(playerDriver.baseHandling) * 3.2 + Float(loadout.aeroDownforce) * 2.6
        if isDriftingInput && abs(steer) > 0.15 && player.speedMetersPerSec > 18.0 {
            if driftDirection == 0 { driftDirection = steer > 0 ? 1.0 : -1.0 }
            let slideSteer = (steer + driftDirection * 0.55) * 0.75
            player.lateralOffset += slideSteer * handlingFactor * dt
            driftAccumSeconds += dt * Float(0.85 + loadout.suspensionStiffness * 0.35)
            driftChargeProgress = min(1.0, Double(driftAccumSeconds / 2.2))

            let newTier = driftAccumSeconds >= 2.1 ? 3 : (driftAccumSeconds >= 1.15 ? 2 : (driftAccumSeconds >= 0.45 ? 1 : 0))
            if newTier > driftTier {
                driftTier = newTier
                HapticsAndAudioEngine.shared.playDriftTierUp(tier: newTier)
            }
        } else {
            if driftTier > 0 {
                releaseDriftBoost(for: player)
            }
            driftDirection = 0
            driftAccumSeconds = 0
            driftChargeProgress = 0
            player.lateralOffset += steer * handlingFactor * dt
        }

        let maxLateral = spline.trackHalfWidth + 1.4
        player.lateralOffset = max(-maxLateral, min(maxLateral, player.lateralOffset))

        // Advance along closed spline
        let deltaT = (player.speedMetersPerSec * dt) / spline.totalLength
        player.normalizedT = (player.normalizedT + deltaT).truncatingRemainder(dividingBy: 1.0)
        player.totalProgress += deltaT

        // Boost Pad Check
        for padT in boostPadTs {
            let diff = abs(player.normalizedT - padT)
            if diff < 0.011 && abs(player.lateralOffset) < 3.6 && player.boostTimer < 0.8 {
                player.boostTimer = 1.35
                boostActive = true
                statusBanner = "BOOST PAD SURGE!"
                HapticsAndAudioEngine.shared.playBoostBurst()
            }
        }

        let currentKmh = Double(player.speedMetersPerSec * 3.45)
        speedKmh = Int(round(currentKmh))
        peakSpeedRecorded = max(peakSpeedRecorded, currentKmh)

        // Record Apple Charts Telemetry Sample every 2% of lap
        let lapFraction = Double( max(0, player.totalProgress).truncatingRemainder(dividingBy: 1.0) )
        let bucket = Int(lapFraction * 50.0)
        if bucket == nextTelemetryBucket && recordedSamples.count < 50 {
            let proSpeed = Double(baseTopSpeed * 3.45) * (0.91 + 0.08 * sin(lapFraction * Double.pi * 6.0))
            recordedSamples.append(
                TelemetryPoint(
                    sampleIndex: recordedSamples.count,
                    distanceNormalized: lapFraction * 100.0,
                    speedKmh: currentKmh,
                    proReferenceKmh: proSpeed,
                    driftAngleDeg: Double(abs(steer) * (isDriftingInput ? 34.0 : 11.0))
                )
            )
            nextTelemetryBucket = (bucket + 1) % 50
        }
    }

    private func stepAIPhysics(dt: Float) {
        let diffMult: Float = difficultyIndex == 0 ? 0.88 : (difficultyIndex == 1 ? 0.96 : 1.03)
        let playerProgress = racers.first?.totalProgress ?? 0

        for (idx, ai) in racers.dropFirst().enumerated() {
            let rubberBand: Float = (playerProgress - ai.totalProgress) * 4.2
            let clampedRubber = max(-2.8, min(3.8, rubberBand))
            let aiMaxSpeed = (34.2 + Float(ai.driver.baseSpeed) * 7.2) * diffMult + clampedRubber + (ai.boostTimer > 0 ? 8.0 : 0.0)

            if ai.speedMetersPerSec < aiMaxSpeed {
                ai.speedMetersPerSec = min(aiMaxSpeed, ai.speedMetersPerSec + 17.0 * dt)
            } else {
                ai.speedMetersPerSec = max(aiMaxSpeed, ai.speedMetersPerSec - 12.0 * dt)
            }

            if ai.boostTimer > 0 { ai.boostTimer -= dt }

            // Smooth lane weaving
            let wave = sin(ai.normalizedT * Float.pi * 6.0 + Float(idx) * 1.3) * 3.4
            ai.lateralOffset += (wave - ai.lateralOffset) * 2.5 * dt

            let deltaT = (ai.speedMetersPerSec * dt) / spline.totalLength
            ai.normalizedT = (ai.normalizedT + deltaT).truncatingRemainder(dividingBy: 1.0)
            ai.totalProgress += deltaT
        }
    }

    private func updateItemBoxes(dt: Float) {
        guard let player = racers.first else { return }
        for i in 0..<itemBoxes.count {
            if itemBoxes[i].cooldown > 0 {
                itemBoxes[i].cooldown -= dt
                if itemBoxes[i].cooldown <= 0 {
                    itemBoxes[i].node.isHidden = false
                }
                continue
            }
            let box = itemBoxes[i]
            let distT = abs(player.normalizedT - box.t)
            let distLat = abs(player.lateralOffset - box.lateral)
            if distT < 0.014 && distLat < 2.2 {
                itemBoxes[i].cooldown = 5.0
                itemBoxes[i].node.isHidden = true
                if heldItem == nil {
                    heldItem = RaceItemType.allCases.randomElement()
                    HapticsAndAudioEngine.shared.playItemPickup()
                }
            }
        }
    }

    private func updateStandingsAndLapSplits() {
        guard let player = racers.first else { return }

        // Sector timing (S1: 0..0.33, S2: 0.33..0.66, S3: 0.66..1.0)
        let lapProgress = max(0, player.totalProgress)
        let frac = lapProgress.truncatingRemainder(dividingBy: 1.0)
        let secIdx = frac < 0.333 ? 0 : (frac < 0.666 ? 1 : 2)
        if secIdx != currentSectorIndex {
            let splitDur = max(2.5, elapsedSeconds - sectorStartElapsed)
            if currentSectorIndex == 0 { sector1Split = splitDur }
            else if currentSectorIndex == 1 { sector2Split = splitDur }
            else if currentSectorIndex == 2 { sector3Split = splitDur }
            sectorStartElapsed = elapsedSeconds
            currentSectorIndex = secIdx
        }

        let newLap = min(totalLaps, Int(floor(max(0, player.totalProgress))) + 1)
        if newLap > currentLap {
            if bestLapSeconds == 0 || currentLapSeconds < bestLapSeconds {
                bestLapSeconds = currentLapSeconds
            }
            currentLapSeconds = 0
            currentLap = newLap
            statusBanner = "LAP \(currentLap) / \(totalLaps)"
            HapticsAndAudioEngine.shared.playLapComplete(isFinalLap: false)
        }

        // Standings Rank
        let sorted = racers.sorted { $0.totalProgress > $1.totalProgress }
        if let rank = sorted.firstIndex(where: { $0.isPlayer }) {
            currentPlace = rank + 1
        }

        // Finish Condition
        if player.totalProgress >= Float(totalLaps) && !isRaceFinished {
            if bestLapSeconds == 0 || currentLapSeconds < bestLapSeconds {
                bestLapSeconds = max(8.0, currentLapSeconds)
            }
            if sector1Split == 0 { sector1Split = bestLapSeconds * 0.32 }
            if sector2Split == 0 { sector2Split = bestLapSeconds * 0.35 }
            if sector3Split == 0 { sector3Split = bestLapSeconds * 0.33 }

            isRaceFinished = true
            HapticsAndAudioEngine.shared.playLapComplete(isFinalLap: true)

            let record = LapTelemetryRecord(
                id: UUID(),
                circuitId: circuit.id,
                driverId: playerDriver.id,
                timestamp: Date(),
                totalTimeSeconds: elapsedSeconds,
                bestLapSeconds: bestLapSeconds,
                sector1Seconds: sector1Split,
                sector2Seconds: sector2Split,
                sector3Seconds: sector3Split,
                peakSpeedKmh: max(115, peakSpeedRecorded),
                miniTurboCount: miniTurboCount,
                finishPosition: currentPlace,
                samples: recordedSamples
            )
            completedTelemetry = record
        }
    }

    private func updateKartTransforms(dt: Float) {
        let steer = readActiveSteeringInput()
        var aiPts: [CGPoint] = []

        for racer in racers {
            let ev = spline.evaluate(normalizedT: racer.normalizedT)
            let worldPos = ev.position + ev.right * racer.lateralOffset
            racer.node.position = SCNVector3(worldPos.x, worldPos.y, worldPos.z)

            let baseYaw = atan2(ev.tangent.x, ev.tangent.z)
            let driftYawOffset: Float = racer.isPlayer && isDriftingInput ? (steer * 0.34) : (racer.isPlayer ? steer * 0.10 : 0)
            racer.node.eulerAngles = SCNVector3(0, baseYaw + driftYawOffset, 0)

            if let tiltNode = racer.node.childNode(withName: "chassis_tilt", recursively: false) {
                let roll = racer.isPlayer ? (-steer * 0.14) : 0
                let pitch: Float = racer.boostTimer > 0 ? -0.06 : 0.0
                tiltNode.eulerAngles = SCNVector3(pitch, 0, roll)
            }

            if let flames = racer.node.childNode(withName: "boost_flames", recursively: true) {
                flames.isHidden = racer.boostTimer <= 0
            }

            if racer.isPlayer {
                playerMinimapPoint = normalizeMinimap(worldPos)

                // Smooth Spring-Damper 3D Chase Camera
                let camBackDist: Float = racer.boostTimer > 0 ? 7.8 : 6.8
                let camHeight: Float = 3.15
                let desiredCamPos = worldPos - ev.tangent * camBackDist + SIMD3<Float>(0, camHeight, 0)
                let curCam = SIMD3<Float>(cameraNode.position.x, cameraNode.position.y, cameraNode.position.z)
                let smoothCam = curCam == .zero ? desiredCamPos : simd_mix(curCam, desiredCamPos, SIMD3<Float>(repeating: min(1.0, dt * 10.5)))
                cameraNode.position = SCNVector3(smoothCam.x, smoothCam.y, smoothCam.z)

                let lookAhead = worldPos + ev.tangent * 9.5 + SIMD3<Float>(0, 1.0, 0)
                cameraNode.look(at: SCNVector3(lookAhead.x, lookAhead.y, lookAhead.z))
                cameraNode.camera?.fieldOfView = racer.boostTimer > 0 ? 78 : 68
            } else {
                aiPts.append(normalizeMinimap(worldPos))
            }
        }
        self.aiMinimapPoints = aiPts
    }
}

// MARK: - SwiftUI SceneKit 3D Viewport Wrapper

public struct SceneKitRaceViewport: UIViewRepresentable {
    @ObservedObject public var engine: RaceSimulationEngine

    public init(engine: RaceSimulationEngine) {
        self.engine = engine
    }

    public func makeUIView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.scene = engine.scene
        view.pointOfView = engine.cameraNode
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = 60
        view.isPlaying = true
        view.allowsCameraControl = false
        view.backgroundColor = .black
        return view
    }

    public func updateUIView(_ uiView: SCNView, context: Context) {
        if uiView.scene !== engine.scene {
            uiView.scene = engine.scene
            uiView.pointOfView = engine.cameraNode
        }
    }
}
