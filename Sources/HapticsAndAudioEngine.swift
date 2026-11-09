import Foundation
import AVFoundation
import CoreHaptics
import UIKit

@MainActor
public final class HapticsAndAudioEngine: ObservableObject {
    public static let shared = HapticsAndAudioEngine()

    @Published public var soundEnabled: Bool = true
    @Published public var hapticsEnabled: Bool = true

    private var hapticEngine: CHHapticEngine?
    private var bgMusicPlayer: AVAudioPlayer?
    private var engineLoopPlayer: AVAudioPlayer?
    private var activeSfxPlayers: [AVAudioPlayer] = []
    private var sfxWavCache: [String: Data] = [:]

    private var currentTrackId: String = "candy"
    private var currentMusicVolume: Float = 0.85
    private var currentSfxVolume: Float = 0.95
    private var isMusicMuted: Bool = false
    private var isMusicPlaying: Bool = true
    private var activeScheduledTrack: String?

    private static let validTracks: Set<String> = [
        "candy",
        "sunshine",
        "starlight",
        "rainbow",
        "island"
    ]

    private struct SynthLayer {
        let startFreq: Float
        let endFreq: Float
        let duration: Float
        let delay: Float
        let wave: Int // 0 = sine, 1 = triangle, 2 = sawtooth
        let gain: Float
        let pan: Float // -1.0 .. 1.0
    }

    private init() {
        setupHaptics()
        buildSfxWavBank()
        setupAudio()
    }

    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let engine = try CHHapticEngine()
            try engine.start()
            engine.resetHandler = { [weak self] in
                try? self?.hapticEngine?.start()
            }
            self.hapticEngine = engine
        } catch {
            self.hapticEngine = nil
        }
    }

    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            NotificationCenter.default.addObserver(
                forName: AVAudioSession.interruptionNotification,
                object: session,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                    try? AVAudioSession.sharedInstance().setActive(true)
                    self?.refreshMusicLoop(forceRestart: false)
                }
            }

            if let engData = sfxWavCache["engine"],
               let engPlayer = try? AVAudioPlayer(data: engData) {
                engPlayer.numberOfLoops = -1
                engPlayer.enableRate = true
                engPlayer.rate = 1.0
                engPlayer.volume = 0.0
                engPlayer.prepareToPlay()
                self.engineLoopPlayer = engPlayer
            }

            refreshMusicLoop(forceRestart: true)
        } catch {
            // Audio fallback if device audio is temporarily unavailable
        }
    }

    private func buildSfxWavBank() {
        sfxWavCache["ui"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 783.99, endFreq: 1046.50, duration: 0.065, delay: 0.0, wave: 1, gain: 0.72, pan: 0.0),
            SynthLayer(startFreq: 1567.98, endFreq: 2093.00, duration: 0.050, delay: 0.01, wave: 0, gain: 0.35, pan: 0.0)
        ])

        sfxWavCache["pickup"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 659.25, endFreq: 987.77, duration: 0.095, delay: 0.0, wave: 1, gain: 0.75, pan: -0.25),
            SynthLayer(startFreq: 987.77, endFreq: 1318.51, duration: 0.115, delay: 0.045, wave: 1, gain: 0.75, pan: 0.0),
            SynthLayer(startFreq: 1318.51, endFreq: 1975.53, duration: 0.165, delay: 0.090, wave: 0, gain: 0.78, pan: 0.25)
        ])

        sfxWavCache["jump"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 330.0, endFreq: 660.0, duration: 0.135, delay: 0.0, wave: 1, gain: 0.70, pan: 0.0),
            SynthLayer(startFreq: 660.0, endFreq: 990.0, duration: 0.105, delay: 0.03, wave: 0, gain: 0.52, pan: 0.0)
        ])

        sfxWavCache["land"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 185.0, endFreq: 68.0, duration: 0.115, delay: 0.0, wave: 0, gain: 0.82, pan: 0.0),
            SynthLayer(startFreq: 120.0, endFreq: 52.0, duration: 0.095, delay: 0.0, wave: 1, gain: 0.55, pan: 0.0)
        ])

        sfxWavCache["hurt"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 260.0, endFreq: 92.0, duration: 0.26, delay: 0.0, wave: 2, gain: 0.72, pan: -0.2),
            SynthLayer(startFreq: 195.0, endFreq: 72.0, duration: 0.28, delay: 0.04, wave: 1, gain: 0.68, pan: 0.2)
        ])

        sfxWavCache["dash"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 587.33, endFreq: 240.0, duration: 0.16, delay: 0.0, wave: 2, gain: 0.62, pan: -0.15),
            SynthLayer(startFreq: 880.0, endFreq: 1320.0, duration: 0.13, delay: 0.02, wave: 1, gain: 0.68, pan: 0.15)
        ])

        sfxWavCache["boost"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 349.23, endFreq: 880.0, duration: 0.22, delay: 0.0, wave: 2, gain: 0.65, pan: -0.25),
            SynthLayer(startFreq: 523.25, endFreq: 1318.51, duration: 0.24, delay: 0.03, wave: 1, gain: 0.75, pan: 0.25),
            SynthLayer(startFreq: 1046.50, endFreq: 2093.0, duration: 0.21, delay: 0.06, wave: 0, gain: 0.65, pan: 0.0)
        ])

        sfxWavCache["drift"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 587.33, endFreq: 880.0, duration: 0.105, delay: 0.0, wave: 1, gain: 0.68, pan: -0.15),
            SynthLayer(startFreq: 880.0, endFreq: 1174.66, duration: 0.095, delay: 0.02, wave: 0, gain: 0.60, pan: 0.15)
        ])

        sfxWavCache["beep"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 587.33, endFreq: 587.33, duration: 0.135, delay: 0.0, wave: 1, gain: 0.78, pan: 0.0),
            SynthLayer(startFreq: 1174.66, endFreq: 1174.66, duration: 0.090, delay: 0.0, wave: 0, gain: 0.45, pan: 0.0)
        ])

        sfxWavCache["go"] = Self.renderWav(layers: [
            SynthLayer(startFreq: 880.0, endFreq: 1174.66, duration: 0.28, delay: 0.0, wave: 1, gain: 0.80, pan: -0.2),
            SynthLayer(startFreq: 1174.66, endFreq: 1760.0, duration: 0.34, delay: 0.03, wave: 1, gain: 0.82, pan: 0.2)
        ])

        let lapNotes: [Float] = [587.33, 783.99, 987.77, 1174.66, 1567.98]
        sfxWavCache["lap"] = Self.renderWav(layers: lapNotes.enumerated().map { idx, f in
            SynthLayer(
                startFreq: f,
                endFreq: f * 1.02,
                duration: 0.155,
                delay: Float(idx) * 0.06,
                wave: 1,
                gain: 0.74,
                pan: Float(idx - 2) * 0.15
            )
        })

        let winNotes: [Float] = [587.33, 698.46, 880.0, 1174.66, 1396.91, 1760.0]
        sfxWavCache["win"] = Self.renderWav(layers: winNotes.enumerated().map { idx, f in
            SynthLayer(
                startFreq: f,
                endFreq: f * 1.01,
                duration: 0.28,
                delay: Float(idx) * 0.09,
                wave: 1,
                gain: 0.78,
                pan: (idx % 2 == 0 ? -1.0 : 1.0) * 0.2
            )
        })

        let loseNotes: [Float] = [440.0, 392.0, 349.23, 293.66]
        sfxWavCache["lose"] = Self.renderWav(layers: loseNotes.enumerated().map { idx, f in
            SynthLayer(
                startFreq: f,
                endFreq: f * 0.98,
                duration: 0.34,
                delay: Float(idx) * 0.14,
                wave: 0,
                gain: 0.72,
                pan: 0.0
            )
        })

        sfxWavCache["engine"] = Self.renderEngineLoopWav()
    }

    private static func renderWav(layers: [SynthLayer]) -> Data {
        let sampleRate = 44100
        let sr = Float(sampleRate)
        let maxEnd = layers.map { $0.delay + $0.duration }.max() ?? 0.1
        let totalSamples = max(64, Int((maxEnd + 0.02) * sr))
        var left = [Float](repeating: 0, count: totalSamples)
        var right = [Float](repeating: 0, count: totalSamples)

        for layer in layers {
            let startIdx = max(0, Int(layer.delay * sr))
            let len = max(1, Int(layer.duration * sr))
            let attackSamples = max(1, Int(0.010 * sr))
            var phase: Float = 0
            let ratio = max(20.0, layer.endFreq) / max(20.0, layer.startFreq)
            let panAngle = (layer.pan + 1.0) * 0.25 * Float.pi
            let lGain = cos(panAngle) * layer.gain
            let rGain = sin(panAngle) * layer.gain

            for i in 0..<len {
                let dst = startIdx + i
                if dst >= totalSamples { break }
                let tNorm = Float(i) / Float(len)
                let freq = layer.startFreq * pow(ratio, tNorm)
                phase += (2.0 * Float.pi * freq) / sr
                if phase > 2.0 * Float.pi { phase -= 2.0 * Float.pi }

                let raw: Float
                switch layer.wave {
                case 1: // Triangle + subtle 2nd harmonic
                    let pNorm = phase / (2.0 * Float.pi)
                    let tri = 1.0 - 4.0 * abs(round(pNorm - 0.25) - (pNorm - 0.25))
                    raw = tri * 0.82 + sin(phase * 2.0) * 0.18
                case 2: // Warm filtered sawtooth
                    let pNorm = phase / (2.0 * Float.pi)
                    let saw = 2.0 * (pNorm - floor(pNorm + 0.5))
                    raw = saw * 0.55 + sin(phase) * 0.45
                default: // Sine + warm harmonic
                    raw = sin(phase) * 0.85 + sin(phase * 2.0) * 0.15
                }

                let env: Float
                if i < attackSamples {
                    env = Float(i) / Float(attackSamples)
                } else {
                    let decProgress = Float(i - attackSamples) / Float(max(1, len - attackSamples))
                    env = pow(1.0 - decProgress, 1.65)
                }

                let sample = raw * env
                left[dst] += sample * lGain
                right[dst] += sample * rGain
            }
        }

        return encodeStereoPcm16Wav(left: left, right: right, sampleRate: sampleRate)
    }

    private static func renderEngineLoopWav() -> Data {
        let sampleRate = 44100
        let sr = Float(sampleRate)
        // Cute, kid-friendly toy-kart / candy-cruiser purr:
        // Warm mid-register (220 Hz + 330 Hz fifth + 440 Hz soft octave) with a playful 10 Hz bubbly "putt-putt" pulse.
        // All frequencies are exact integer cycles per 1.0s buffer for seamless click-free looping.
        let totalSamples = sampleRate
        var left = [Float](repeating: 0, count: totalSamples)
        var right = [Float](repeating: 0, count: totalSamples)
        let baseFreq: Float = 220.0

        for i in 0..<totalSamples {
            let t = Float(i) / sr
            let chugPhase = 2.0 * Float.pi * 10.0 * t
            let bubbleBounce = 0.16 * sin(chugPhase)
            let p1 = 2.0 * Float.pi * baseFreq * t + bubbleBounce
            let p2 = 2.0 * Float.pi * (baseFreq * 1.5) * t + bubbleBounce * 1.5
            let p3 = 2.0 * Float.pi * (baseFreq * 2.0) * t + bubbleBounce * 2.0

            // Rounded triangle-like fundamental + warm fifth + gentle octave
            let p1Norm = (p1 / (2.0 * Float.pi)).truncatingRemainder(dividingBy: 1.0)
            let p1Pos = p1Norm < 0 ? p1Norm + 1.0 : p1Norm
            let tri = 1.0 - 4.0 * abs(round(p1Pos - 0.25) - (p1Pos - 0.25))

            let chugEnv = 0.78 + 0.22 * sin(chugPhase)
            let sig = (tri * 0.48 + sin(p1) * 0.24 + sin(p2) * 0.18 + sin(p3) * 0.10) * chugEnv * 0.36
            left[i] = sig
            right[i] = sig
        }
        return encodeStereoPcm16Wav(left: left, right: right, sampleRate: sampleRate)
    }

    private static func encodeStereoPcm16Wav(left: [Float], right: [Float], sampleRate: Int) -> Data {
        let frameCount = min(left.count, right.count)
        let dataByteCount = frameCount * 4
        var data = Data(capacity: 44 + dataByteCount)

        func appendASCII(_ s: String) {
            data.append(contentsOf: s.utf8)
        }
        func appendUInt32(_ v: UInt32) {
            var le = v.littleEndian
            withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
        }
        func appendUInt16(_ v: UInt16) {
            var le = v.littleEndian
            withUnsafeBytes(of: &le) { data.append(contentsOf: $0) }
        }

        appendASCII("RIFF")
        appendUInt32(UInt32(36 + dataByteCount))
        appendASCII("WAVE")
        appendASCII("fmt ")
        appendUInt32(16)
        appendUInt16(1) // PCM
        appendUInt16(2) // Stereo
        appendUInt32(UInt32(sampleRate))
        appendUInt32(UInt32(sampleRate * 4))
        appendUInt16(4)
        appendUInt16(16)
        appendASCII("data")
        appendUInt32(UInt32(dataByteCount))

        for i in 0..<frameCount {
            let lClamped = max(-0.98, min(0.98, left[i]))
            let rClamped = max(-0.98, min(0.98, right[i]))
            var lInt = Int16(lClamped * 32767.0).littleEndian
            var rInt = Int16(rClamped * 32767.0).littleEndian
            withUnsafeBytes(of: &lInt) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: &rInt) { data.append(contentsOf: $0) }
        }
        return data
    }

    public func updateMusicPlayback(track: String, volume: Float, sfxVolume: Float = -1, muted: Bool, playing: Bool) {
        let validTrack = Self.validTracks.contains(track) ? track : "candy"
        let trackChanged = validTrack != currentTrackId
        currentTrackId = validTrack
        currentMusicVolume = max(0, min(1, volume))
        if sfxVolume >= 0 {
            currentSfxVolume = max(0, min(1, sfxVolume))
        }
        isMusicMuted = muted
        isMusicPlaying = playing
        soundEnabled = !muted
        if muted || currentSfxVolume <= 0.001 {
            engineLoopPlayer?.volume = 0.0
            engineLoopPlayer?.pause()
        }
        refreshMusicLoop(forceRestart: trackChanged)
    }

    private func refreshMusicLoop(forceRestart: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)

        // Balanced at 58% of slider so SFX cut through the soundtrack clearly
        let targetVol: Float = (isMusicMuted || !isMusicPlaying) ? 0.0 : (currentMusicVolume * 0.58)

        if !isMusicPlaying || isMusicMuted {
            bgMusicPlayer?.volume = 0.0
            bgMusicPlayer?.pause()
            return
        }

        if forceRestart || activeScheduledTrack != currentTrackId || bgMusicPlayer == nil {
            bgMusicPlayer?.stop()
            bgMusicPlayer = nil
            if let url = Bundle.main.resourceURL?.appendingPathComponent("webapp/music/\(currentTrackId).mp3"),
               FileManager.default.fileExists(atPath: url.path),
               let player = try? AVAudioPlayer(contentsOf: url) {
                player.numberOfLoops = -1
                player.volume = targetVol
                player.prepareToPlay()
                player.play()
                bgMusicPlayer = player
                activeScheduledTrack = currentTrackId
            }
        } else if let player = bgMusicPlayer {
            player.volume = targetVol
            if !player.isPlaying {
                player.play()
            }
        }
    }

    public func playSfx(name: String, sfxVolume: Float? = nil, muted: Bool? = nil) {
        if let sfxVolume = sfxVolume {
            currentSfxVolume = max(0, min(1, sfxVolume))
        }
        if let muted = muted {
            isMusicMuted = muted
            soundEnabled = !muted
        }

        // Trigger haptics synced to SFX type
        switch name {
        case "ui":
            triggerImpact(.light)
        case "beep":
            triggerImpact(.medium)
        case "go":
            triggerNotification(.success)
        case "drift":
            triggerImpact(.rigid)
        case "boost", "dash":
            playCustomHapticBurst(intensity: 0.92, sharpness: 0.80, duration: 0.24)
        case "pickup":
            triggerImpact(.medium)
        case "jump", "land":
            triggerImpact(.soft)
        case "hurt":
            triggerImpact(.heavy)
        case "lap", "win":
            triggerNotification(.success)
        case "lose":
            triggerNotification(.warning)
        default:
            break
        }

        guard soundEnabled, !isMusicMuted, currentSfxVolume > 0.005 else { return }
        guard let wavData = sfxWavCache[name] ?? sfxWavCache["ui"] else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)

        activeSfxPlayers.removeAll { !$0.isPlaying }
        if activeSfxPlayers.count > 10 {
            activeSfxPlayers.first?.stop()
            activeSfxPlayers.removeFirst()
        }

        if let player = try? AVAudioPlayer(data: wavData) {
            player.volume = min(1.0, currentSfxVolume * 1.0)
            player.prepareToPlay()
            player.play()
            activeSfxPlayers.append(player)
        }
    }

    public func updateEngineSound(speedRatio: Float, driftTier: Int, boosting: Bool, active: Bool) {
        guard let engPlayer = engineLoopPlayer else { return }
        if !active || !soundEnabled || isMusicMuted || currentSfxVolume <= 0.01 {
            if engPlayer.isPlaying {
                engPlayer.volume = 0.0
                engPlayer.pause()
            }
            return
        }

        let clamped = max(0.0, min(1.3, speedRatio))
        // Kid-friendly playful pitch range and soft, cozy background volume
        let targetRate = 0.82 + clamped * 0.56 + (boosting ? 0.16 : 0.0) + Float(driftTier) * 0.05
        let targetVol = (0.065 + clamped * 0.075 + (boosting ? 0.035 : 0.0)) * currentSfxVolume

        engPlayer.rate = max(0.65, min(1.75, targetRate))
        engPlayer.volume = max(0.0, min(0.22, targetVol))
        if !engPlayer.isPlaying {
            engPlayer.play()
        }
    }

    public func playTap() {
        playSfx(name: "ui")
    }

    public func playCountdownTick(finalGo: Bool) {
        playSfx(name: finalGo ? "go" : "beep")
    }

    public func playDriftTierUp(tier: Int) {
        playSfx(name: "drift")
    }

    public func playBoostBurst() {
        playSfx(name: "boost")
    }

    public func playItemPickup() {
        playSfx(name: "pickup")
    }

    public func playLapComplete(isFinalLap: Bool) {
        playSfx(name: isFinalLap ? "win" : "lap")
    }

    private func triggerImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticsEnabled else { return }
        let gen = UIImpactFeedbackGenerator(style: style)
        gen.impactOccurred()
    }

    private func triggerNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticsEnabled else { return }
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(type)
    }

    private func playCustomHapticBurst(intensity: Float, sharpness: Float, duration: TimeInterval) {
        guard hapticsEnabled, let engine = hapticEngine else {
            triggerImpact(.heavy)
            return
        }
        do {
            let iParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            let sParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [iParam, sParam], relativeTime: 0, duration: duration)
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            triggerImpact(.heavy)
        }
    }
}
