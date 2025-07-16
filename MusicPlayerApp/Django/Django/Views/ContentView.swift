import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject var playerVM = PlayerViewModel()
    @StateObject var lyricsVM = LyricsViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("🎵 FLAC Lyrics Player")
                .font(.title2)
                .bold()

            if let track = playerVM.currentTrack {
                Text(track.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else {
                Text("Drop your FLAC + LRC files here!")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 30) {
                Button("🎶 Load Track") {
                    openFile()
                }

                Button(playerVM.isPlaying ? "⏸ Pause" : "▶️ Play") {
                    playerVM.isPlaying ? playerVM.pause() : playerVM.play()
                }

                Button("📝 Load LRC File") {
                    openLRC()
                }
            }

            ProgressView(value: playerVM.currentTime, total: playerVM.duration)
                .padding(.horizontal)

            LyricsView(viewModel: lyricsVM)
        }
        .frame(width: 500, height: 350)
        .padding()
        .onAppear {
            lyricsVM.bindToPlayer(playerVM)
        }
    }

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .audio,
            .mpeg4Audio,
            .mp3,
            .wav,
            .init(filenameExtension: "flac")!
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let audioURL = panel.url {
            let lyricsURL = audioURL.deletingPathExtension().appendingPathExtension("lrc")
            let lyricsExists = FileManager.default.fileExists(atPath: lyricsURL.path)

            print("Audio selected: \(audioURL.lastPathComponent)")
            print("Looking for lyrics at: \(lyricsURL.path)")
            print("Lyrics file exists: \(lyricsExists)")

            let track = Track(
                title: audioURL.lastPathComponent,
                artist: "Unknown",
                audioURL: audioURL,
                lyricsURL: lyricsExists ? lyricsURL : nil
            )

            playerVM.loadTrack(track)

            if let lrcURL = track.lyricsURL {
                lyricsVM.load(from: lrcURL)
                print("Lyrics loaded!")
            } else {
                print("No lyrics file found.")
            }
        }
    }

    func openLRC() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .init(filenameExtension: "lrc")!
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let lrcURL = panel.url {
            print("📥 Manually selected LRC: \(lrcURL.lastPathComponent)")
            lyricsVM.load(from: lrcURL)
        }
    }
}

#Preview {
    ContentView()
}