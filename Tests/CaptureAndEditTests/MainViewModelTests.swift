import XCTest
import AppKit
@testable import CaptureAndEdit

final class MainViewModelTests: XCTestCase {

    var viewModel: MainViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MainViewModel()
    }

    override func tearDown() {
        viewModel?.stopMonitoring()
        viewModel = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(viewModel.document)
        XCTAssertEqual(viewModel.selectedTool, .line)
        XCTAssertEqual(viewModel.selectedColor, .red)
        XCTAssertFalse(viewModel.autoCloseAfterSave)
    }

    func testUndo() {
        let image = createTestImage()
        viewModel.document.setImage(image)

        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )
        viewModel.document.addOperation(operation)

        viewModel.undo()

        XCTAssertTrue(viewModel.document.operations.isEmpty)
    }

    func testRedo() {
        let image = createTestImage()
        viewModel.document.setImage(image)

        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )
        viewModel.document.addOperation(operation)
        viewModel.undo()
        viewModel.redo()

        XCTAssertEqual(viewModel.document.operations.count, 1)
    }

    func testClear() {
        let image = createTestImage()
        viewModel.document.setImage(image)

        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )
        viewModel.document.addOperation(operation)
        viewModel.clear()

        XCTAssertTrue(viewModel.document.operations.isEmpty)
    }

    // MARK: - Zoom Tests

    func testZoomScaleInitialization() {
        XCTAssertEqual(viewModel.zoomScale, 1.0, "Initial zoom scale should be 1.0 (100%)")
    }

    func testSetZoomScale() {
        viewModel.setZoomScale(1.5)
        XCTAssertEqual(viewModel.zoomScale, 1.5, "Zoom scale should be set to 1.5")

        viewModel.setZoomScale(0.8)
        XCTAssertEqual(viewModel.zoomScale, 0.8, "Zoom scale should be set to 0.8")
    }

    func testResetZoomScale() {
        viewModel.setZoomScale(2.0)
        XCTAssertEqual(viewModel.zoomScale, 2.0)

        viewModel.resetZoomScale()
        XCTAssertEqual(viewModel.zoomScale, 1.0, "Zoom scale should be reset to 1.0 (100%)")
    }

    func testZoomScaleConstraints() {
        // Test minimum constraint
        viewModel.setZoomScale(0.3)
        XCTAssertGreaterThanOrEqual(viewModel.zoomScale, 0.5, "Zoom scale should not be less than 0.5 (50%)")

        // Test maximum constraint
        viewModel.setZoomScale(5.0)
        XCTAssertLessThanOrEqual(viewModel.zoomScale, 3.0, "Zoom scale should not be greater than 3.0 (300%)")
    }

    func testZoomScaleFormatted() {
        viewModel.setZoomScale(1.0)
        XCTAssertEqual(viewModel.zoomScaleFormatted, "100%")

        viewModel.setZoomScale(1.5)
        XCTAssertEqual(viewModel.zoomScaleFormatted, "150%")

        viewModel.setZoomScale(0.75)
        XCTAssertEqual(viewModel.zoomScaleFormatted, "75%")
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
