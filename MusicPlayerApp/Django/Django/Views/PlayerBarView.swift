import SwiftUI

struct PlayerBarView: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var libraryVM: LibraryViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Artwork
            if let artwork = playerVM.currentArtwork {
                Image(nsImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .cornerRadius(8)
                    .overlay(Image(systemName: "music.note").font(.largeTitle))
            }
            // Song Info
            VStack(alignment: .leading) {
                Text(playerVM.currentTrack?.title ?? "No Song Playing")
                    .font(.headline)
                Text(playerVM.currentTrack?.artist ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // Controls
            HStack(spacing: 24) {
                Button(action: { playerVM.playPrevious(in: libraryVM) }) {
                    Image(systemName: "backward.fill")
                }
                Button(action: { playerVM.togglePlayPause() }) {
                    Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                Button(action: { playerVM.playNext(in: libraryVM) }) {
                    Image(systemName: "forward.fill")
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            // Progress
            Slider(value: $playerVM.currentTime, in: 0...playerVM.duration, onEditingChanged: { editing in
                if !editing {
                    playerVM.seek(to: playerVM.currentTime)
                }
            })
            .frame(width: 200)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

