import SwiftUI

struct ArtistListView: View {
    @ObservedObject var libraryVM: LibraryViewModel
    @ObservedObject var playerVM: PlayerViewModel

    var body: some View {
        List(libraryVM.artists, id: \.self) { artist in
            NavigationLink(destination: ArtistDetailView(artist: artist, libraryVM: libraryVM, playerVM: playerVM)) {
                Text(artist)
            }
        }
        .navigationTitle("Artists")
    }
}

struct ArtistDetailView: View {
    let artist: String
    @ObservedObject var libraryVM: LibraryViewModel
    @ObservedObject var playerVM: PlayerViewModel

    var body: some View {
        List(libraryVM.songs.filter { $0.artist == artist }) { track in
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
        .navigationTitle(artist)
    }
}

