import Foundation
import Combine
import SwiftUI

class PlayerViewModel: ObservableObject {
    @Published var currentTrack: Track?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1

    let audioManager = AudioManager()
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        audioManager.$isPlaying
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        
        audioManager.$currentTime
            .assign(to: \.currentTime, on: self)
            .store(in: &cancellables)
        
        audioManager.$duration
            .assign(to: \.duration, on: self)
            .store(in: &cancellables)
    }

    func loadTrack(_ track: Track) {
        currentTrack = track
        audioManager.load(url: track.audioURL)
    }

    func play() {
        audioManager.play()
    }

    func pause() {
        audioManager.pause()
    }

    func stop() {
        audioManager.stop()
    }
}
