import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var libraryVM: LibraryViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Music Folder Settings")
                .font(.title2)
            if let url = libraryVM.musicFolderURL {
                Text("Current folder: \(url.path)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Button("Choose Music Folder") {
                chooseMusicFolder()
            }
        }
        .padding()
    }

    func chooseMusicFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            libraryVM.setMusicFolder(url)
        }
    }
}

