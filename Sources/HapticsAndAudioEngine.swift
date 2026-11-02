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
    private let audioEngine = AVAudioEngine()
    private let sfxPlayer = AVAudioPlayerNode()
    private let musicPlayer = AVAudioPlayerNode()
    private var audioFormat: AVAudioFormat?
    private var musicBuffers: [String: AVAudioPCMBuffer] = [:]
    private var currentTrackId: String = "candy"
    private var currentMusicVolume: Float = 0.85
    private var isMusicMuted: Bool = false
    private var isMusicPlaying: Bool = true
    private var activeScheduledTrack: String?

    private struct BarSpec {
        let bass: (Float, Float)
        let chord: [Float]
        let melody: [Float]
        let counter: [Float]
    }

    private struct SongPreset {
        let id: String
        let stepDur: Double
        let bars: [BarSpec]
    }

    private static let presets: [String: SongPreset] = [
        "candy": SongPreset(
            id: "candy",
            stepDur: 0.19,
            bars: [
                BarSpec(bass: (174.61, 233.08), chord: [349.23, 440.0, 523.25, 659.25], melody: [523.25, 587.33, 698.46, 880.0, 783.99, 698.46, 659.25, 587.33], counter: [1046.5, 1174.66, 1396.91, 1760.0, 1567.98, 1396.91, 1318.51, 1174.66]),
                BarSpec(bass: (196.0, 261.63), chord: [392.0, 493.88, 587.33, 698.46], melody: [659.25, 698.46, 783.99, 1046.5, 880.0, 783.99, 698.46, 783.99], counter: [1318.51, 1396.91, 1567.98, 2093.0, 1760.0, 1567.98, 1396.91, 1567.98]),
                BarSpec(bass: (220.0, 146.83), chord: [349.23, 440.0, 523.25, 698.46], melody: [880.0, 783.99, 698.46, 659.25, 587.33, 659.25, 698.46, 880.0], counter: [1760.0, 1567.98, 1396.91, 1318.51, 1174.66, 1318.51, 1396.91, 1760.0]),
                BarSpec(bass: (146.83, 196.0), chord: [293.66, 392.0, 493.88, 587.33], melody: [698.46, 587.33, 523.25, 587.33, 659.25, 698.46, 783.99, 880.0], counter: [1396.91, 1174.66, 1046.5, 1174.66, 1318.51, 1396.91, 1567.98, 1760.0]),
                BarSpec(bass: (233.08, 174.61), chord: [349.23, 466.16, 587.33, 698.46], melody: [783.99, 880.0, 932.33, 880.0, 783.99, 698.46, 659.25, 698.46], counter: [1567.98, 1760.0, 1864.66, 1760.0, 1567.98, 1396.91, 1318.51, 1396.91]),
                BarSpec(bass: (174.61, 220.0), chord: [349.23, 440.0, 523.25, 698.46], melody: [880.0, 1046.5, 880.0, 783.99, 698.46, 659.25, 587.33, 659.25], counter: [1760.0, 2093.0, 1760.0, 1567.98, 1396.91, 1318.51, 1174.66, 1318.51]),
                BarSpec(bass: (196.0, 233.08), chord: [392.0, 466.16, 587.33, 698.46], melody: [587.33, 698.46, 783.99, 880.0, 783.99, 698.46, 880.0, 1046.5], counter: [1174.66, 1396.91, 1567.98, 1760.0, 1567.98, 1396.91, 1760.0, 2093.0]),
                BarSpec(bass: (261.63, 174.61), chord: [349.23, 440.0, 523.25, 698.46], melody: [1046.5, 932.33, 880.0, 783.99, 698.46, 783.99, 880.0, 698.46], counter: [2093.0, 1864.66, 1760.0, 1567.98, 1396.91, 1567.98, 1760.0, 1396.91])
            ]
        ),
        "sunshine": SongPreset(
            id: "sunshine",
            stepDur: 0.195,
            bars: [
                BarSpec(bass: (130.81, 196.0), chord: [261.63, 329.63, 392.0, 523.25], melody: [523.25, 659.25, 783.99, 659.25, 880.0, 783.99, 659.25, 523.25], counter: [1046.5, 1318.51, 1567.98, 1318.51, 1760.0, 1567.98, 1318.51, 1046.5]),
                BarSpec(bass: (196.0, 146.83), chord: [293.66, 392.0, 493.88, 587.33], melody: [587.33, 659.25, 783.99, 987.77, 880.0, 783.99, 659.25, 587.33], counter: [1174.66, 1318.51, 1567.98, 1975.53, 1760.0, 1567.98, 1318.51, 1174.66]),
                BarSpec(bass: (220.0, 164.81), chord: [329.63, 440.0, 523.25, 659.25], melody: [880.0, 783.99, 659.25, 523.25, 587.33, 659.25, 783.99, 880.0], counter: [1760.0, 1567.98, 1318.51, 1046.5, 1174.66, 1318.51, 1567.98, 1760.0]),
                BarSpec(bass: (174.61, 196.0), chord: [349.23, 440.0, 523.25, 659.25], melody: [698.46, 783.99, 880.0, 698.46, 783.99, 880.0, 987.77, 1046.5], counter: [1396.91, 1567.98, 1760.0, 1396.91, 1567.98, 1760.0, 1975.53, 2093.0])
            ]
        ),
        "starlight": SongPreset(
            id: "starlight",
            stepDur: 0.21,
            bars: [
                BarSpec(bass: (196.0, 146.83), chord: [392.0, 493.88, 587.33, 783.99], melody: [783.99, 880.0, 987.77, 1174.66, 987.77, 880.0, 783.99, 659.25], counter: [1567.98, 1760.0, 1975.53, 2349.32, 1975.53, 1760.0, 1567.98, 1318.51]),
                BarSpec(bass: (146.83, 220.0), chord: [369.99, 440.0, 587.33, 739.99], melody: [739.99, 880.0, 987.77, 880.0, 739.99, 659.25, 587.33, 659.25], counter: [1479.98, 1760.0, 1975.53, 1760.0, 1479.98, 1318.51, 1174.66, 1318.51]),
                BarSpec(bass: (164.81, 196.0), chord: [329.63, 392.0, 493.88, 659.25], melody: [659.25, 783.99, 987.77, 880.0, 783.99, 659.25, 587.33, 659.25], counter: [1318.51, 1567.98, 1975.53, 1760.0, 1567.98, 1318.51, 1174.66, 1318.51]),
                BarSpec(bass: (130.81, 146.83), chord: [261.63, 329.63, 392.0, 523.25], melody: [523.25, 659.25, 783.99, 880.0, 739.99, 783.99, 880.0, 987.77], counter: [1046.5, 1318.51, 1567.98, 1760.0, 1479.98, 1567.98, 1760.0, 1975.53])
            ]
        ),
        "rainbow": SongPreset(
            id: "rainbow",
            stepDur: 0.155,
            bars: [
                BarSpec(bass: (146.83, 220.0), chord: [293.66, 369.99, 440.0, 587.33], melody: [587.33, 659.25, 739.99, 880.0, 987.77, 880.0, 739.99, 659.25], counter: [1174.66, 1318.51, 1479.98, 1760.0, 1975.53, 1760.0, 1479.98, 1318.51]),
                BarSpec(bass: (196.0, 164.81), chord: [392.0, 493.88, 587.33, 739.99], melody: [783.99, 880.0, 987.77, 1174.66, 987.77, 880.0, 783.99, 739.99], counter: [1567.98, 1760.0, 1975.53, 2349.32, 1975.53, 1760.0, 1567.98, 1479.98]),
                BarSpec(bass: (220.0, 146.83), chord: [329.63, 440.0, 554.37, 659.25], melody: [880.0, 739.99, 659.25, 587.33, 659.25, 739.99, 880.0, 987.77], counter: [1760.0, 1479.98, 1318.51, 1174.66, 1318.51, 1479.98, 1760.0, 1975.53]),
                BarSpec(bass: (246.94, 185.0), chord: [369.99, 493.88, 587.33, 739.99], melody: [739.99, 659.25, 587.33, 659.25, 739.99, 880.0, 987.77, 1174.66], counter: [1479.98, 1318.51, 1174.66, 1318.51, 1479.98, 1760.0, 1975.53, 2349.32])
            ]
        ),
        "island": SongPreset(
            id: "island",
            stepDur: 0.175,
            bars: [
                BarSpec(bass: (220.0, 164.81), chord: [329.63, 440.0, 554.37, 659.25], melody: [659.25, 554.37, 440.0, 554.37, 659.25, 739.99, 880.0, 739.99], counter: [1318.51, 1108.73, 880.0, 1108.73, 1318.51, 1479.98, 1760.0, 1479.98]),
                BarSpec(bass: (146.83, 220.0), chord: [293.66, 369.99, 440.0, 587.33], melody: [587.33, 659.25, 739.99, 880.0, 739.99, 659.25, 587.33, 659.25], counter: [1174.66, 1318.51, 1479.98, 1760.0, 1479.98, 1318.51, 1174.66, 1318.51]),
                BarSpec(bass: (164.81, 246.94), chord: [329.63, 415.3, 493.88, 659.25], melody: [659.25, 739.99, 830.61, 987.77, 880.0, 739.99, 659.25, 554.37], counter: [1318.51, 1479.98, 1661.22, 1975.53, 1760.0, 1479.98, 1318.51, 1108.73]),
                BarSpec(bass: (220.0, 164.81), chord: [329.63, 440.0, 554.37, 659.25], melody: [440.0, 554.37, 659.25, 739.99, 880.0, 739.99, 659.25, 880.0], counter: [880.0, 1108.73, 1318.51, 1479.98, 1760.0, 1479.98, 1318.51, 1760.0])
            ]
        )
    ]

    private init() {
        setupHaptics()
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
                    if let self = self {
                        if !self.audioEngine.isRunning {
                            try? self.audioEngine.start()
                        }
                        self.refreshMusicLoop(forceRestart: true)
                    }
                }
            }

            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
            self.audioFormat = format
            audioEngine.attach(sfxPlayer)
            audioEngine.attach(musicPlayer)
            audioEngine.connect(sfxPlayer, to: audioEngine.mainMixerNode, format: format)
            audioEngine.connect(musicPlayer, to: audioEngine.mainMixerNode, format: format)
            try audioEngine.start()
            sfxPlayer.play()
            refreshMusicLoop(forceRestart: true)
        } catch {
            // Audio engine fallback if simulator/device audio is unavailable
        }
    }

    public func updateMusicPlayback(track: String, volume: Float, muted: Bool, playing: Bool) {
        let validTrack = Self.presets[track] != nil ? track : "candy"
        let trackChanged = validTrack != currentTrackId
        currentTrackId = validTrack
        currentMusicVolume = max(0, min(1, volume))
        isMusicMuted = muted
        isMusicPlaying = playing
        soundEnabled = !muted
        refreshMusicLoop(forceRestart: trackChanged)
    }

    private func refreshMusicLoop(forceRestart: Bool) {
        guard let format = audioFormat else { return }
        if !audioEngine.isRunning {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try? AVAudioSession.sharedInstance().setActive(true)
            try? audioEngine.start()
        }

        let targetVol: Float = (isMusicMuted || !isMusicPlaying) ? 0.0 : (currentMusicVolume * 0.65)
        musicPlayer.volume = targetVol

        if !isMusicPlaying || isMusicMuted {
            return
        }

        if forceRestart || activeScheduledTrack != currentTrackId || !musicPlayer.isPlaying {
            let buffer = getOrBuildMusicBuffer(trackId: currentTrackId, format: format)
            musicPlayer.stop()
            musicPlayer.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            musicPlayer.play()
            activeScheduledTrack = currentTrackId
        }
    }

    private func getOrBuildMusicBuffer(trackId: String, format: AVAudioFormat) -> AVAudioPCMBuffer {
        if let cached = musicBuffers[trackId] {
            return cached
        }
        let preset = Self.presets[trackId] ?? Self.presets["candy"]!
        let sampleRate = Float(format.sampleRate)
        let stepSamples = Int(preset.stepDur * Double(sampleRate))
        let totalSteps = preset.bars.count * 8
        let totalFrames = AVAudioFrameCount(max(1, stepSamples * totalSteps))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames)!
        buffer.frameLength = totalFrames
        guard let channel = buffer.floatChannelData?[0] else { return buffer }

        let twoPi = Float.pi * 2.0
        var bassPhase: Float = 0
        var leadPhase: Float = 0
        var counterPhase: Float = 0
        var arpPhase: Float = 0
        var padPhases: [Float] = [0, 0, 0, 0]
        var noiseSeed: UInt32 = 0x12345678

        func nextNoise() -> Float {
            noiseSeed ^= noiseSeed << 13
            noiseSeed ^= noiseSeed >> 17
            noiseSeed ^= noiseSeed << 5
            return Float(noiseSeed & 0xFFFF) / 32768.0 - 1.0
        }

        for (barIdx, bar) in preset.bars.enumerated() {
            for s in 0..<8 {
                let globalStep = barIdx * 8 + s
                let stepStart = globalStep * stepSamples
                let bassRoot = s < 4 ? bar.bass.0 : bar.bass.1
                let bassFreq: Float
                if trackId == "starlight" {
                    bassFreq = (s % 2 == 0) ? bassRoot : (bassRoot * 1.5)
                } else if trackId == "island" {
                    bassFreq = (s == 3 || s == 6) ? (bassRoot * 1.5) : bassRoot
                } else {
                    bassFreq = (s % 2 == 0) ? bassRoot : (bassRoot * 2.0)
                }
                let leadFreq = bar.melody[s]
                let counterFreq = bar.counter[s]

                let hasKick = (trackId == "rainbow") ? (s % 2 == 0) : ((trackId == "starlight") ? (s == 0 || s == 4) : (s == 0 || s == 3 || s == 4 || (trackId != "candy" && s == 6)))
                let hasSnare = (trackId == "rainbow") ? (s % 2 == 1) : ((trackId == "sunshine") ? (s == 2 || s == 5 || s == 7) : (s == 2 || s == 6))
                let hasWoodblock = (trackId == "island") && (s == 0 || s == 3 || s == 6)
                let woodFreq: Float = (s == 0) ? 1580.0 : 2120.0

                var kickPhase: Float = 0
                var woodPhase: Float = 0

                for i in 0..<stepSamples {
                    let pos = Float(i) / Float(max(1, stepSamples))
                    let tSec = Float(i) / sampleRate
                    var sample: Float = 0

                    if hasKick && tSec < 0.12 {
                        let kFreq = 42.0 + 98.0 * exp(-tSec * 34.0)
                        kickPhase += (twoPi * kFreq) / sampleRate
                        sample += sin(kickPhase) * 0.26 * exp(-tSec * 22.0)
                    }
                    if hasSnare && tSec < 0.095 {
                        sample += nextNoise() * 0.13 * exp(-tSec * 32.0)
                    }
                    if tSec < 0.04 {
                        sample += nextNoise() * ((s % 2 == 1) ? 0.06 : 0.038) * exp(-tSec * 65.0)
                    }
                    if hasWoodblock && tSec < 0.05 {
                        woodPhase += (twoPi * woodFreq * (1.0 - tSec * 4.0)) / sampleRate
                        sample += sin(woodPhase) * 0.16 * exp(-tSec * 55.0)
                    }

                    bassPhase += (twoPi * bassFreq) / sampleRate
                    let bassEnv: Float = (pos < 0.04) ? (pos / 0.04) : max(0, 1.0 - (pos - 0.04) * 0.92)
                    let bassWave = sin(bassPhase) * 0.55 + sin(bassPhase * 2.0) * 0.32 + sin(bassPhase * 3.0) * 0.13
                    sample += bassWave * 0.23 * bassEnv

                    if trackId == "rainbow" {
                        let arpIdx = (pos < 0.33) ? 0 : ((pos < 0.66) ? 1 : 2)
                        let arpFreq = bar.chord[arpIdx % bar.chord.count]
                        arpPhase += (twoPi * arpFreq) / sampleRate
                        let sq: Float = sin(arpPhase) >= 0 ? 0.65 : -0.65
                        sample += sq * 0.10 * (1.0 - pos * 0.4)
                    } else {
                        let strumEnv: Float = (trackId == "sunshine") ? ((s % 2 == 1) ? exp(-pos * 2.4) * 1.2 : exp(-pos * 3.0) * 0.65) : 0.75
                        var padSum: Float = 0
                        for c in 0..<bar.chord.count {
                            padPhases[c] += (twoPi * bar.chord[c]) / sampleRate
                            padSum += sin(padPhases[c]) + sin(padPhases[c] * 2.0) * 0.25
                        }
                        sample += (padSum / Float(bar.chord.count)) * 0.11 * strumEnv
                    }

                    let vibrato: Float = (trackId == "sunshine") ? (1.0 + sin(twoPi * 5.8 * tSec) * 0.008) : 1.0
                    leadPhase += (twoPi * leadFreq * vibrato) / sampleRate
                    let leadEnv: Float
                    if pos < 0.035 {
                        leadEnv = pos / 0.035
                    } else if pos < 0.84 {
                        leadEnv = 1.0 - (pos - 0.035) * 0.22
                    } else {
                        leadEnv = max(0, ((1.0 - pos) / 0.16) * 0.82)
                    }

                    let leadWave: Float
                    if trackId == "rainbow" {
                        leadWave = (sin(leadPhase) >= 0 ? 0.62 : -0.62) + sin(leadPhase) * 0.38
                    } else if trackId == "island" {
                        leadWave = sin(leadPhase) * 0.62 + sin(leadPhase * 2.0) * 0.26 + sin(leadPhase * 2.98) * 0.12
                    } else if trackId == "starlight" {
                        leadWave = sin(leadPhase + sin(leadPhase * 2.0) * 0.45 * leadEnv) * 0.72 + sin(leadPhase * 0.5) * 0.28
                    } else {
                        leadWave = sin(leadPhase) * 0.64 + sin(leadPhase * 2.0) * 0.25 + sin(leadPhase * 3.0) * 0.11
                    }
                    sample += leadWave * 0.28 * leadEnv

                    if s % 2 == 0 {
                        counterPhase += (twoPi * counterFreq) / sampleRate
                        let cEnv: Float = (pos < 0.02) ? (pos / 0.02) : exp(-pos * 3.2)
                        sample += sin(counterPhase) * 0.10 * cEnv
                    }

                    channel[stepStart + i] = tanh(sample * 1.35) * 0.85
                }
            }
        }

        let fadeLen = min(512, Int(totalFrames) / 50)
        for i in 0..<fadeLen {
            let alpha = Float(i) / Float(max(1, fadeLen))
            channel[i] *= alpha
            channel[Int(totalFrames) - 1 - i] *= alpha
        }

        musicBuffers[trackId] = buffer
        return buffer
    }

    public func playTap() {
        triggerImpact(.light)
        playToneSequence(frequencies: [660, 880], durations: [0.035, 0.045], amplitude: 0.14)
    }

    public func playCountdownTick(finalGo: Bool) {
        if finalGo {
            triggerNotification(.success)
            playToneSequence(frequencies: [523.25, 659.25, 783.99, 1046.50], durations: [0.05, 0.05, 0.05, 0.18], amplitude: 0.24)
        } else {
            triggerImpact(.medium)
            playToneSequence(frequencies: [440.0], durations: [0.09], amplitude: 0.20)
        }
    }

    public func playDriftTierUp(tier: Int) {
        triggerImpact(tier >= 3 ? .heavy : .rigid)
        let baseFreq: Float = tier == 1 ? 587.33 : (tier == 2 ? 783.99 : 1046.50)
        playToneSequence(frequencies: [baseFreq, baseFreq * 1.25], durations: [0.04, 0.08], amplitude: 0.20)
    }

    public func playBoostBurst() {
        playCustomHapticBurst(intensity: 0.95, sharpness: 0.80, duration: 0.28)
        playToneSequence(frequencies: [330, 440, 659.25, 880, 1174.66], durations: [0.03, 0.03, 0.04, 0.05, 0.12], amplitude: 0.25)
    }

    public func playItemPickup() {
        triggerImpact(.medium)
        playToneSequence(frequencies: [523.25, 659.25, 783.99, 987.77], durations: [0.04, 0.04, 0.04, 0.09], amplitude: 0.20)
    }

    public func playLapComplete(isFinalLap: Bool) {
        triggerNotification(.success)
        if isFinalLap {
            playToneSequence(frequencies: [523.25, 659.25, 783.99, 1046.50, 1318.51], durations: [0.07, 0.07, 0.07, 0.09, 0.24], amplitude: 0.26)
        } else {
            playToneSequence(frequencies: [587.33, 783.99, 1174.66], durations: [0.06, 0.06, 0.14], amplitude: 0.22)
        }
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

    private func playToneSequence(frequencies: [Float], durations: [Double], amplitude: Float) {
        guard soundEnabled, let format = audioFormat, frequencies.count == durations.count else { return }
        let sampleRate = Float(format.sampleRate)
        let totalDuration = durations.reduce(0, +)
        let totalFrames = AVAudioFrameCount(max(1, Int(Double(sampleRate) * totalDuration)))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames),
              let channel = buffer.floatChannelData?[0] else { return }
        buffer.frameLength = totalFrames

        var writeIndex = 0
        var phase: Float = 0

        for (idx, freq) in frequencies.enumerated() {
            let noteFrames = Int(Double(sampleRate) * durations[idx])
            let step = (2.0 * Float.pi * freq) / sampleRate
            for f in 0..<noteFrames {
                if writeIndex >= Int(totalFrames) { break }
                let progress = Float(f) / Float(max(1, noteFrames))
                let env = sin(progress * Float.pi)
                let harmonic = sin(phase) * 0.75 + sin(phase * 2.0) * 0.25
                channel[writeIndex] = harmonic * amplitude * env
                phase += step
                writeIndex += 1
            }
        }

        if !audioEngine.isRunning {
            try? audioEngine.start()
        }
        if !sfxPlayer.isPlaying {
            sfxPlayer.play()
        }
        sfxPlayer.scheduleBuffer(buffer, completionHandler: nil)
    }
}
