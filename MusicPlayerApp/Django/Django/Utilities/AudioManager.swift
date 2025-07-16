import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var timer: Timer?
    
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1

    init() {
        setup()
    }

    private func setup() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)

        do {
            try engine.start()
        } catch {
            print("Audio engine start error: \(error)")
        }
    }

    func load(url: URL) {
        stop()
        do {
            audioFile = try AVAudioFile(forReading: url)
            if let audioFile = audioFile {
                // 👇 FIX: Calculate duration manually
                duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate
                player.scheduleFile(audioFile, at: nil)
            }
        } catch {
            print("Failed to load audio: \(error)")
        }
    }

    func play() {
        guard !player.isPlaying else { return }
        player.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        guard player.isPlaying else { return }
        player.pause()
        isPlaying = false
        stopTimer()
    }

    func stop() {
        player.stop()
        isPlaying = false
        stopTimer()
        currentTime = 0
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.updateTime()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTime() {
        if let nodeTime = player.lastRenderTime,
           let playerTime = player.playerTime(forNodeTime: nodeTime),
           let format = audioFile?.processingFormat {
            let seconds = Double(playerTime.sampleTime) / format.sampleRate
            self.currentTime = seconds
        }
    }
}
