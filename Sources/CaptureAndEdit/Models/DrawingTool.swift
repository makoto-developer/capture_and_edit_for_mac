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
            return L10n.toolSelect
        case .pen:
            return L10n.toolPen
        case .line:
            return L10n.toolLine
        case .rectangle:
            return L10n.toolRectangle
        case .pixelate:
            return L10n.toolPixelate
        case .arrow:
            return L10n.toolArrow
        case .text:
            return L10n.toolText
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
            return L10n.colorRed
        case .blue:
            return L10n.colorBlue
        case .green:
            return L10n.colorGreen
        case .yellow:
            return L10n.colorYellow
        case .black:
            return L10n.colorBlack
        }
    }
}
