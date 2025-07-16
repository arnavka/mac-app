import Foundation
import AVFoundation
import AppKit

struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String?
    let audioURL: URL
    let artwork: NSImage?
    
    // Use a static async factory method for modern metadata loading
    static func from(url: URL) async -> Track {
        let asset = AVURLAsset(url: url)
        var title: String = url.deletingPathExtension().lastPathComponent
        var artist: String? = nil
        var artwork: NSImage? = nil
        
        do {
            let metadata = try await asset.load(.commonMetadata)
            for meta in metadata {
                if meta.commonKey?.rawValue == "title" {
                    if let value = try? await meta.load(.value) as? String {
                        title = value
                    }
                }
                if meta.commonKey?.rawValue == "artist" {
                    if let value = try? await meta.load(.value) as? String {
                        artist = value
                    }
                }
                if meta.commonKey?.rawValue == "artwork" {
                    if let data = try? await meta.load(.value) as? Data,
                       let image = NSImage(data: data) {
                        artwork = image
                    }
                }
            }
        } catch {
            // Fallback to filename and nils if metadata fails
        }
        return Track(title: title, artist: artist, audioURL: url, artwork: artwork)
    }
}
