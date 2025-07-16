import Foundation
import SwiftUI
import AVFoundation

class LibraryViewModel: ObservableObject {
    @Published var songs: [Track] = []
    @Published var playlists: [Playlist] = []
    @Published var artists: [String] = []
    @AppStorage("musicFolderBookmark") private var musicFolderBookmark: Data?
    @Published var musicFolderURL: URL?
    
    func loadLibrary() {
        guard let bookmark = musicFolderBookmark else { return }
        var isStale = false
        if let url = try? URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
            musicFolderURL = url
            fetchSongs()
        }
    }
    
    func setMusicFolder(_ url: URL) {
        if let bookmark = try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
            musicFolderBookmark = bookmark
            musicFolderURL = url
            fetchSongs()
        }
    }
    
    func fetchSongs() {
        guard let folderURL = musicFolderURL else { return }
        _ = folderURL.startAccessingSecurityScopedResource()
        let allowedExtensions = ["flac", "mp3", "wav", "m4a"]
        let fileManager = FileManager.default
        if let files = try? fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
            let audioFiles = files.filter { allowedExtensions.contains($0.pathExtension.lowercased()) }
            Task {
                let loadedTracks = await withTaskGroup(of: Track.self) { group in
                    for file in audioFiles {
                        group.addTask { await Track.from(url: file) }
                    }
                    return await group.reduce(into: [Track]()) { $0.append($1) }
                }
                await MainActor.run {
                    self.songs = loadedTracks
                    self.artists = Array(Set(loadedTracks.compactMap { $0.artist })).sorted()
                }
            }
        }
        // Do NOT call stopAccessingSecurityScopedResource() until app closes or you no longer need access
    }
}
