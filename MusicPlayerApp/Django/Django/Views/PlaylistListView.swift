import SwiftUI

struct PlaylistListView: View {
    @ObservedObject var libraryVM: LibraryViewModel
    @ObservedObject var playerVM: PlayerViewModel

    var body: some View {
        List(libraryVM.playlists) { playlist in
            NavigationLink(destination: PlaylistDetailView(playlist: playlist, playerVM: playerVM)) {
                Text(playlist.name)
            }
        }
        .navigationTitle("Playlists")
    }
}

struct PlaylistDetailView: View {
    let playlist: Playlist
    @ObservedObject var playerVM: PlayerViewModel

    var body: some View {
        List(playlist.tracks) { track in
            HStack {
                Text(track.title)
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
        .navigationTitle(playlist.name)
    }
}

