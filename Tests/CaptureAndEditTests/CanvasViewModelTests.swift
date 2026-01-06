import XCTest
import AppKit
@testable import CaptureAndEdit

final class CanvasViewModelTests: XCTestCase {

    var viewModel: CanvasViewModel!

    override func setUp() {
        super.setUp()
        viewModel = CanvasViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNil(viewModel.currentOperation)
    }

    func testHandleMouseDownAndDrag() {
        let startPoint = CGPoint(x: 10, y: 20)
        let dragPoint = CGPoint(x: 100, y: 200)

        viewModel.handleMouseDown(at: startPoint)
        viewModel.handleMouseDragged(to: dragPoint, tool: .line, color: .red)

        XCTAssertNotNil(viewModel.currentOperation)
    }

    func testHandleMouseUp() {
        let startPoint = CGPoint(x: 10, y: 20)
        let endPoint = CGPoint(x: 100, y: 200)
        var completedOperation: (any EditOperation)?

        viewModel.handleMouseDown(at: startPoint)
        viewModel.handleMouseDragged(to: endPoint, tool: .line, color: .red)
        viewModel.handleMouseUp { operation in
            completedOperation = operation
        }

        XCTAssertNotNil(completedOperation)
        XCTAssertNil(viewModel.currentOperation)
    }

    func testCancelOperation() {
        let startPoint = CGPoint(x: 10, y: 20)
        let dragPoint = CGPoint(x: 100, y: 200)

        viewModel.handleMouseDown(at: startPoint)
        viewModel.handleMouseDragged(to: dragPoint, tool: .line, color: .red)
        viewModel.cancelOperation()

        XCTAssertNil(viewModel.currentOperation)
    }
}
