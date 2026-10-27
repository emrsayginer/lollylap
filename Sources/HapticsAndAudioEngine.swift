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
    private var audioFormat: AVAudioFormat?

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
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)

            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
            self.audioFormat = format
            audioEngine.attach(sfxPlayer)
            audioEngine.connect(sfxPlayer, to: audioEngine.mainMixerNode, format: format)
            try audioEngine.start()
            sfxPlayer.play()
        } catch {
            // Audio engine fallback if simulator/device audio is unavailable
        }
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
                let env = sin(progress * Float.pi) // smooth attack & decay envelope
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
