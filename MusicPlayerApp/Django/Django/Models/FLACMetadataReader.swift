import Foundation
import AppKit

struct FLACMetadata {
    var title: String?
    var artist: String?
    var album: String?
    var coverImage: NSImage?
}

struct FLACMetadataReader {

    static func parse(url: URL) throws -> FLACMetadata {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }

        let signature = fileHandle.readData(ofLength: 4)
        guard let sigStr = String(data: signature, encoding: .ascii), sigStr == "fLaC" else {
            throw NSError(domain: "FLACParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not a valid FLAC file"])
        }

        var metadata = FLACMetadata()
        var isLastBlock = false

        while !isLastBlock {
            let header = try fileHandle.read(upToCount: 4) ?? Data()
            guard header.count == 4 else { break }

            let isLast = (header[0] & 0x80) != 0
            let type = header[0] & 0x7F
            let length = Int(header[1]) << 16 | Int(header[2]) << 8 | Int(header[3])

            let blockData = try fileHandle.read(upToCount: length) ?? Data()
            guard blockData.count == length else { break }

            switch type {
            case 4: // VORBIS_COMMENT
                parseVorbisComment(blockData, into: &metadata)
            case 6: // PICTURE
                metadata.coverImage = parsePictureBlock(blockData)
            default:
                break
            }

            isLastBlock = isLast
        }

        return metadata
    }

    private static func parseVorbisComment(_ data: Data, into meta: inout FLACMetadata) {
        var offset = 0

        func readInt32LE() -> Int {
            let slice = data[offset..<offset+4]
            offset += 4
            return Int(UInt32(littleEndian: slice.withUnsafeBytes { $0.load(as: UInt32.self) }))
        }

        func readString(_ len: Int) -> String {
            let strData = data[offset..<offset+len]
            offset += len
            return String(data: strData, encoding: .utf8) ?? ""
        }

        _ = readInt32LE() // vendor length
        offset += readInt32LE() // skip vendor string
        let commentCount = readInt32LE()

        for _ in 0..<commentCount {
            let length = readInt32LE()
            let comment = readString(length)
            let parts = comment.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = parts[0].uppercased()
                let value = String(parts[1])

                switch key {
                case "TITLE": meta.title = value
                case "ARTIST": meta.artist = value
                case "ALBUM": meta.album = value
                default: break
                }
            }
        }
    }

    private static func parsePictureBlock(_ data: Data) -> NSImage? {
        var offset = 0

        func readInt32BE() -> Int {
            let val = data[offset..<offset+4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            offset += 4
            return Int(val)
        }

        offset += 4 // picture type
        let mimeLen = readInt32BE()
        offset += mimeLen // skip mime

        let descLen = readInt32BE()
        offset += descLen // skip description

        offset += 4 * 4 // skip width, height, color depth, indexed colors
        let dataLen = readInt32BE()

        let imgData = data[offset..<offset+dataLen]
        return NSImage(data: imgData)
    }
}
