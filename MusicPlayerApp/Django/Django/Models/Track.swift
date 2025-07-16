import Foundation
import AppKit
import TagLibKit

struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String?
    let audioURL: URL
    let artwork: NSImage?

    static func from(url: URL) async -> Track {
        let tagInfo = TagLibKit.TaglibWrapper.tags(forFile: url.path)
        let title = tagInfo["TITLE"] as? String ?? url.deletingPathExtension().lastPathComponent
        let artist = tagInfo["ARTIST"] as? String

        var artwork: NSImage? = nil
        if let imageData = TagLibKit.TaglibWrapper.artwork(forFile: url.path) {
            artwork = NSImage(data: imageData)
        }

        return Track(title: title, artist: artist, audioURL: url, artwork: artwork)
    }
}
