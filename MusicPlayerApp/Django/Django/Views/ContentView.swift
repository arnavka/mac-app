import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum SidebarItem: String, CaseIterable, Hashable, Identifiable {
    case songs, playlists, artists, settings
    var id: Self { self }
    var label: String {
        switch self {
        case .songs: return "Songs"
        case .playlists: return "Playlists"
        case .artists: return "Artists"
        case .settings: return "Settings"
        }
    }
    var systemImage: String {
        switch self {
        case .songs: return "music.note"
        case .playlists: return "music.note.list"
        case .artists: return "person.2.fill"
        case .settings: return "gearshape"
        }
    }
}

struct ContentView: View {
    @StateObject var playerVM = PlayerViewModel()
    @StateObject var libraryVM = LibraryViewModel() // Handles songs, playlists, artists, etc.
    @StateObject var lyricsVM = LyricsViewModel()

    @State private var selection: SidebarItem? = .songs

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SidebarItem.allCases, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.label, systemImage: item.systemImage)
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 180)
        } detail: {
            // Main Content
            Group {
                switch selection {
                case .songs:
                    SongListView(libraryVM: libraryVM, playerVM: playerVM)
                case .playlists:
                    PlaylistListView(libraryVM: libraryVM, playerVM: playerVM)
                case .artists:
                    ArtistListView(libraryVM: libraryVM, playerVM: playerVM)
                case .settings:
                    SettingsView(libraryVM: libraryVM)
                case .none:
                    Text("Select a section")
                }
            }
        }
        .frame(minWidth: 800, minHeight: 500)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
        }
        .overlay(alignment: .bottom) {
            PlayerBarView(playerVM: playerVM, libraryVM: libraryVM)
                .background(.ultraThinMaterial)
                .frame(height: 80)
                .shadow(radius: 4)
        }
        .onAppear {
            libraryVM.loadLibrary()
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
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
            Task {
                let track = await Track.from(url: audioURL)
                await MainActor.run {
                    playerVM.loadTrack(track)
                    // Optionally, load lyrics if you want:
                    let lyricsURL = audioURL.deletingPathExtension().appendingPathExtension("lrc")
                    if FileManager.default.fileExists(atPath: lyricsURL.path) {
                        lyricsVM.load(from: lyricsURL)
                        print("Lyrics loaded!")
                    } else {
                        print("No lyrics file found.")
                    }
                }
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
