import Foundation
import Combine

class LyricsViewModel: ObservableObject {
    @Published var lyrics: [LyricLine] = []
    @Published var currentLineIndex: Int = 0

    private var cancellable: AnyCancellable?

    func load(from url: URL) {
        lyrics = LyricsParser.parse(from: url)
        currentLineIndex = 0
    }

    func bindToPlayer(_ playerVM: PlayerViewModel) {
        // Cancel previous binding if any
        cancellable?.cancel()
        // Listen to playerVM's currentTime and update currentLineIndex
        cancellable = playerVM.$currentTime
            .sink { [weak self] time in
                self?.update(currentTime: time)
            }
    }

    func update(currentTime: TimeInterval) {
        guard !lyrics.isEmpty else { return }
        for (index, line) in lyrics.enumerated().reversed() {
            if currentTime >= line.time {
                if currentLineIndex != index {
                    print("🎯 Updating currentLineIndex: \(index) – \(line.text)")
                }
                currentLineIndex = index
                break
            }
        }
    }
}