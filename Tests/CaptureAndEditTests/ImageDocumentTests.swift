import XCTest
import AppKit
@testable import CaptureAndEdit

final class ImageDocumentTests: XCTestCase {

    func testInitialization() {
        let document = ImageDocument()

        XCTAssertNil(document.originalImage)
        XCTAssertTrue(document.operations.isEmpty)
        XCTAssertFalse(document.canUndo)
        XCTAssertFalse(document.canRedo)
    }

    func testSetImage() {
        let document = ImageDocument()
        let image = createTestImage()

        document.setImage(image)

        XCTAssertNotNil(document.originalImage)
        XCTAssertTrue(document.operations.isEmpty)
    }

    func testAddOperation() {
        let document = ImageDocument()
        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        document.addOperation(operation)

        XCTAssertEqual(document.operations.count, 1)
        XCTAssertTrue(document.canUndo)
    }

    func testUndo() {
        let document = ImageDocument()
        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        document.addOperation(operation)
        document.undo()

        XCTAssertTrue(document.operations.isEmpty)
        XCTAssertTrue(document.canRedo)
    }

    func testRedo() {
        let document = ImageDocument()
        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        document.addOperation(operation)
        document.undo()
        document.redo()

        XCTAssertEqual(document.operations.count, 1)
        XCTAssertFalse(document.canRedo)
    }

    func testClear() {
        let document = ImageDocument()
        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        document.addOperation(operation)
        document.clear()

        XCTAssertTrue(document.operations.isEmpty)
        XCTAssertFalse(document.canUndo)
    }

    func testRenderImage() {
        let document = ImageDocument()
        let image = createTestImage()
        document.setImage(image)

        let rendered = document.renderImage()

        XCTAssertNotNil(rendered)
        XCTAssertEqual(rendered?.size, image.size)
    }

    private func createTestImage(size: CGSize = CGSize(width: 200, height: 200)) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
    }
}
