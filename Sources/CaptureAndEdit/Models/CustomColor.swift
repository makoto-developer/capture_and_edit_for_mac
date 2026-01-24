import Foundation
import AppKit

/// カスタムカラーモデル
struct CustomColor: Identifiable, Codable, Equatable {
    let id: UUID
    let hex: String

    init(id: UUID = UUID(), hex: String) {
        self.id = id
        self.hex = hex
    }

    init(id: UUID = UUID(), color: NSColor) {
        self.id = id
        self.hex = color.toHex()
    }

    var nsColor: NSColor {
        NSColor(hex: hex) ?? .black
    }

    var helpText: String {
        hex
    }
}

// MARK: - NSColor Extensions

extension NSColor {
    /// NSColorを16進数文字列に変換
    func toHex() -> String {
        guard let rgbColor = usingColorSpace(.sRGB) else {
            return "#000000"
        }

        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    /// 16進数文字列からNSColorを生成
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6 else {
            return nil
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(srgbRed: red, green: green, blue: blue, alpha: 1.0)
    }
}
