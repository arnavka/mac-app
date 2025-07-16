import SwiftUI

struct SongListView: View {
    @ObservedObject var libraryVM: LibraryViewModel
    @ObservedObject var playerVM: PlayerViewModel

    var body: some View {
        List(libraryVM.songs) { track in
            HStack {
                if let artwork = track.artwork {
                    Image(nsImage: artwork)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                        .overlay(Image(systemName: "music.note"))
                }
                VStack(alignment: .leading) {
                    Text(track.title)
                        .font(.headline)
                    Text(track.artist ?? "Unknown Artist")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if playerVM.currentTrack == track && playerVM.isPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                playerVM.loadTrack(track)
                playerVM.play()
            }
        }
        .navigationTitle("Songs")
    }
}
