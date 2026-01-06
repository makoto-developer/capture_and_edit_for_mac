import XCTest
import AppKit
@testable import CaptureAndEdit

final class IntegrationTests: XCTestCase {

    func testCompleteEditingWorkflow() {
        let mainViewModel = MainViewModel()
        let canvasViewModel = CanvasViewModel()

        let image = createTestImage()
        mainViewModel.document.setImage(image)

        XCTAssertNotNil(mainViewModel.document.originalImage)

        canvasViewModel.handleMouseDown(at: CGPoint(x: 10, y: 10))
        canvasViewModel.handleMouseDragged(to: CGPoint(x: 100, y: 100), tool: .line, color: .red)

        canvasViewModel.handleMouseUp { operation in
            mainViewModel.document.addOperation(operation)
        }

        XCTAssertEqual(mainViewModel.document.operations.count, 1)

        let renderedImage = mainViewModel.document.renderImage()
        XCTAssertNotNil(renderedImage)
    }

    func testUndoRedoWorkflow() {
        let mainViewModel = MainViewModel()
        let canvasViewModel = CanvasViewModel()

        let image = createTestImage()
        mainViewModel.document.setImage(image)

        canvasViewModel.handleMouseDown(at: CGPoint(x: 10, y: 10))
        canvasViewModel.handleMouseDragged(to: CGPoint(x: 100, y: 100), tool: .line, color: .red)
        canvasViewModel.handleMouseUp { operation in
            mainViewModel.document.addOperation(operation)
        }

        canvasViewModel.handleMouseDown(at: CGPoint(x: 20, y: 20))
        canvasViewModel.handleMouseDragged(to: CGPoint(x: 120, y: 120), tool: .rectangle, color: .blue)
        canvasViewModel.handleMouseUp { operation in
            mainViewModel.document.addOperation(operation)
        }

        XCTAssertEqual(mainViewModel.document.operations.count, 2)

        mainViewModel.undo()
        XCTAssertEqual(mainViewModel.document.operations.count, 1)

        mainViewModel.redo()
        XCTAssertEqual(mainViewModel.document.operations.count, 2)
    }

    func testClearAndRestartWorkflow() {
        let mainViewModel = MainViewModel()
        let canvasViewModel = CanvasViewModel()

        let image = createTestImage()
        mainViewModel.document.setImage(image)

        canvasViewModel.handleMouseDown(at: CGPoint(x: 10, y: 10))
        canvasViewModel.handleMouseDragged(to: CGPoint(x: 100, y: 100), tool: .line, color: .red)
        canvasViewModel.handleMouseUp { operation in
            mainViewModel.document.addOperation(operation)
        }

        mainViewModel.clear()

        XCTAssertTrue(mainViewModel.document.operations.isEmpty)
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
