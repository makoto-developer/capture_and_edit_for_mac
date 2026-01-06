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
            return "square.grid.3x3.fill"
        case .arrow:
            return "arrow.up.right"
        case .text:
            return "textformat"
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
}
