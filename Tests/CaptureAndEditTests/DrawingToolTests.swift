import XCTest
import AppKit
@testable import CaptureAndEdit

final class DrawingToolTests: XCTestCase {

    func testDrawingToolCases() {
        XCTAssertEqual(DrawingTool.allCases.count, 7)
        XCTAssertTrue(DrawingTool.allCases.contains(.select))
        XCTAssertTrue(DrawingTool.allCases.contains(.pen))
        XCTAssertTrue(DrawingTool.allCases.contains(.line))
        XCTAssertTrue(DrawingTool.allCases.contains(.rectangle))
        XCTAssertTrue(DrawingTool.allCases.contains(.pixelate))
        XCTAssertTrue(DrawingTool.allCases.contains(.arrow))
        XCTAssertTrue(DrawingTool.allCases.contains(.text))
    }

    func testDrawingToolRawValues() {
        XCTAssertEqual(DrawingTool.select.rawValue, "Select")
        XCTAssertEqual(DrawingTool.pen.rawValue, "Pen")
        XCTAssertEqual(DrawingTool.line.rawValue, "Line")
        XCTAssertEqual(DrawingTool.rectangle.rawValue, "Rectangle")
        XCTAssertEqual(DrawingTool.pixelate.rawValue, "Pixelate")
        XCTAssertEqual(DrawingTool.arrow.rawValue, "Arrow")
        XCTAssertEqual(DrawingTool.text.rawValue, "Text")
    }

    func testDrawingToolSystemImages() {
        XCTAssertEqual(DrawingTool.select.systemImage, "arrow.up.left.and.arrow.down.right")
        XCTAssertEqual(DrawingTool.pen.systemImage, "pencil.tip")
        XCTAssertEqual(DrawingTool.line.systemImage, "pencil.line")
        XCTAssertEqual(DrawingTool.rectangle.systemImage, "rectangle")
        XCTAssertEqual(DrawingTool.pixelate.systemImage, "square.grid.3x3.fill")
        XCTAssertEqual(DrawingTool.arrow.systemImage, "arrow.up.right")
        XCTAssertEqual(DrawingTool.text.systemImage, "textformat")
    }

    func testDrawingColorCases() {
        XCTAssertEqual(DrawingColor.allCases.count, 5)
    }

    func testDrawingColorNSColor() {
        XCTAssertEqual(DrawingColor.red.nsColor, NSColor.systemRed)
        XCTAssertEqual(DrawingColor.blue.nsColor, NSColor.systemBlue)
        XCTAssertEqual(DrawingColor.green.nsColor, NSColor.systemGreen)
        XCTAssertEqual(DrawingColor.yellow.nsColor, NSColor.systemYellow)
        XCTAssertEqual(DrawingColor.black.nsColor, NSColor.black)
    }
}
