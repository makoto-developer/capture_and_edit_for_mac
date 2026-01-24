import Foundation
import AppKit

enum DrawingTool: String, CaseIterable, Identifiable {
    case select = "Select"
    case pen = "Pen"
    case line = "Line"
    case rectangle = "Rectangle"
    case pixelate = "Pixelate"
    case arrow = "Arrow"
    case text = "Text"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .select:
            return "arrow.up.left.and.arrow.down.right"
        case .pen:
            return "pencil.tip"
        case .line:
            return "pencil.line"
        case .rectangle:
            return "rectangle"
        case .pixelate:
            return "rectangle.inset.filled"
        case .arrow:
            return "arrow.up.right"
        case .text:
            return "textformat"
        }
    }

    var helpText: String {
        switch self {
        case .select:
            return "選択 - オブジェクトを選択して移動"
        case .pen:
            return "ペン - 自由に線を描画（Shiftキーで直線）"
        case .line:
            return "直線 - 2点間に直線を描画"
        case .rectangle:
            return "矩形 - 四角形の枠を描画"
        case .pixelate:
            return "塗りつぶし - 領域を黒で塗りつぶし（機密情報のマスキング用）"
        case .arrow:
            return "矢印 - 矢印を描画"
        case .text:
            return "テキスト - クリックした位置にテキストを追加"
        }
    }
}

enum DrawingColor: String, CaseIterable, Identifiable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    case black = "Black"

    var id: String { rawValue }

    var nsColor: NSColor {
        switch self {
        case .red:
            return .systemRed
        case .blue:
            return .systemBlue
        case .green:
            return .systemGreen
        case .yellow:
            return .systemYellow
        case .black:
            return .black
        }
    }

    var helpText: String {
        switch self {
        case .red:
            return "赤"
        case .blue:
            return "青"
        case .green:
            return "緑"
        case .yellow:
            return "黄"
        case .black:
            return "黒"
        }
    }
}
