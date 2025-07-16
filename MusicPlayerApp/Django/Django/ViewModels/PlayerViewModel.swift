import Foundation
import AVFoundation
import AppKit

class PlayerViewModel: ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var currentArtwork: NSImage?
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    func loadTrack(_ track: Track) {
        stop()
        currentTrack = track
        let url = track.audioURL
        do {
            player = try AVAudioPlayer(contentsOf: url)
            duration = player?.duration ?? 1
            currentTime = 0
            currentArtwork = track.artwork
            player?.prepareToPlay()
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    func play() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }
    
    func playNext(in library: LibraryViewModel) {
        guard let current = currentTrack, let idx = library.songs.firstIndex(of: current), idx + 1 < library.songs.count else { return }
        loadTrack(library.songs[idx + 1])
        play()
    }
    
    func playPrevious(in library: LibraryViewModel) {
        guard let current = currentTrack, let idx = library.songs.firstIndex(of: current), idx > 0 else { return }
        loadTrack(library.songs[idx - 1])
        play()
    }
    
    func seek(to time: Double) {
        player?.currentTime = time
        currentTime = time
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTime = player.currentTime
            if player.currentTime >= player.duration {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        stopTimer()
    }
}
