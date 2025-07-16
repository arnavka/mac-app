import Foundation

struct LyricLine: Identifiable {
    let id = UUID()
    let time: TimeInterval
    let text: String
}

class LyricsParser {
    static func parse(from url: URL) -> [LyricLine] {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            print("🔍 LRC file loaded successfully")
            print("Raw contents:\n\(content)")

            var lines: [LyricLine] = []

            let pattern = #"\[(\d+):(\d+).(\d+)](.*)"#
            let regex = try! NSRegularExpression(pattern: pattern)

            for line in content.split(separator: "\n") {
                let lineStr = String(line)
                if let match = regex.firstMatch(in: lineStr, range: NSRange(location: 0, length: lineStr.utf16.count)) {
                    let min = Double((lineStr as NSString).substring(with: match.range(at: 1))) ?? 0
                    let sec = Double((lineStr as NSString).substring(with: match.range(at: 2))) ?? 0
                    let ms = Double((lineStr as NSString).substring(with: match.range(at: 3))) ?? 0
                    let time = min * 60 + sec + ms / 100
                    let text = (lineStr as NSString).substring(with: match.range(at: 4)).trimmingCharacters(in: .whitespaces)
                    lines.append(LyricLine(time: time, text: text))
                }
            }

            print("✅ Parsed \(lines.count) lyric lines")
            return lines.sorted { $0.time < $1.time }

        } catch {
            print("❌ Failed to load LRC: \(error)")
            return []
        }
    }
}
