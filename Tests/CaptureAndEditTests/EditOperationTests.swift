import XCTest
import AppKit
@testable import CaptureAndEdit

final class EditOperationTests: XCTestCase {

    // MARK: - LineOperation Tests

    func testLineOperationInitialization() {
        let startPoint = CGPoint(x: 10, y: 20)
        let endPoint = CGPoint(x: 100, y: 200)
        let color = NSColor.red
        let lineWidth: CGFloat = 5.0

        let operation = LineOperation(
            startPoint: startPoint,
            endPoint: endPoint,
            color: color,
            lineWidth: lineWidth
        )

        XCTAssertEqual(operation.startPoint, startPoint)
        XCTAssertEqual(operation.endPoint, endPoint)
        XCTAssertEqual(operation.color, color)
        XCTAssertEqual(operation.lineWidth, lineWidth)
        XCTAssertNotNil(operation.id)
    }

    func testLineOperationDefaultLineWidth() {
        let operation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .black
        )

        XCTAssertEqual(operation.lineWidth, 3.0)
    }

    func testLineOperationDraw() {
        let size = CGSize(width: 200, height: 200)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            XCTFail("Failed to create CGContext")
            return
        }

        let operation = LineOperation(
            startPoint: CGPoint(x: 10, y: 10),
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        XCTAssertNoThrow(operation.draw(in: context))
    }

    // MARK: - RectangleOperation Tests

    func testRectangleOperationInitialization() {
        let startPoint = CGPoint(x: 10, y: 20)
        let endPoint = CGPoint(x: 100, y: 200)
        let color = NSColor.blue
        let lineWidth: CGFloat = 4.0

        let operation = RectangleOperation(
            startPoint: startPoint,
            endPoint: endPoint,
            color: color,
            lineWidth: lineWidth
        )

        XCTAssertEqual(operation.startPoint, startPoint)
        XCTAssertEqual(operation.endPoint, endPoint)
        XCTAssertEqual(operation.color, color)
        XCTAssertEqual(operation.lineWidth, lineWidth)
        XCTAssertNotNil(operation.id)
    }

    func testRectangleOperationDefaultLineWidth() {
        let operation = RectangleOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .black
        )

        XCTAssertEqual(operation.lineWidth, 3.0)
    }

    func testRectangleOperationDraw() {
        let size = CGSize(width: 200, height: 200)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            XCTFail("Failed to create CGContext")
            return
        }

        let operation = RectangleOperation(
            startPoint: CGPoint(x: 10, y: 10),
            endPoint: CGPoint(x: 100, y: 100),
            color: .blue
        )

        XCTAssertNoThrow(operation.draw(in: context))
    }

    // MARK: - PixelateOperation Tests

    func testPixelateOperationInitialization() {
        let startPoint = CGPoint(x: 10, y: 20)
        let endPoint = CGPoint(x: 100, y: 200)

        let operation = PixelateOperation(
            startPoint: startPoint,
            endPoint: endPoint
        )

        XCTAssertEqual(operation.startPoint, startPoint)
        XCTAssertEqual(operation.endPoint, endPoint)
        XCTAssertNotNil(operation.id)
    }

    func testPixelateOperationDraw() {
        let size = CGSize(width: 200, height: 200)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            XCTFail("Failed to create CGContext")
            return
        }

        let operation = PixelateOperation(
            startPoint: CGPoint(x: 10, y: 10),
            endPoint: CGPoint(x: 100, y: 100)
        )

        XCTAssertNoThrow(operation.draw(in: context))
    }

    // MARK: - PenOperation Tests

    func testPenOperationInitialization() {
        let points = [
            CGPoint(x: 10, y: 20),
            CGPoint(x: 30, y: 40),
            CGPoint(x: 50, y: 60)
        ]
        let color = NSColor.green
        let lineWidth: CGFloat = 5.0

        let operation = PenOperation(
            points: points,
            color: color,
            lineWidth: lineWidth
        )

        XCTAssertEqual(operation.points.count, 3)
        XCTAssertEqual(operation.points[0], CGPoint(x: 10, y: 20))
        XCTAssertEqual(operation.points[1], CGPoint(x: 30, y: 40))
        XCTAssertEqual(operation.points[2], CGPoint(x: 50, y: 60))
        XCTAssertEqual(operation.color, color)
        XCTAssertEqual(operation.lineWidth, lineWidth)
        XCTAssertNotNil(operation.id)
    }

    func testPenOperationDefaultLineWidth() {
        let operation = PenOperation(
            points: [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 100)],
            color: .black
        )

        XCTAssertEqual(operation.lineWidth, 3.0)
    }

    func testPenOperationAddPoint() {
        let operation = PenOperation(
            points: [CGPoint(x: 10, y: 20)],
            color: .red
        )

        let newOperation = operation.addPoint(CGPoint(x: 30, y: 40))

        XCTAssertEqual(newOperation.points.count, 2)
        XCTAssertEqual(newOperation.points[0], CGPoint(x: 10, y: 20))
        XCTAssertEqual(newOperation.points[1], CGPoint(x: 30, y: 40))
        XCTAssertEqual(newOperation.id, operation.id)
    }

    func testPenOperationDraw() {
        let size = CGSize(width: 200, height: 200)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            XCTFail("Failed to create CGContext")
            return
        }

        let operation = PenOperation(
            points: [
                CGPoint(x: 10, y: 10),
                CGPoint(x: 50, y: 50),
                CGPoint(x: 100, y: 100)
            ],
            color: .green
        )

        XCTAssertNoThrow(operation.draw(in: context))
    }

    func testPenOperationContainsPoint() {
        let operation = PenOperation(
            points: [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 100, y: 0),
                CGPoint(x: 100, y: 100)
            ],
            color: .red
        )

        // ポイントが線の近くにある
        XCTAssertTrue(operation.contains(point: CGPoint(x: 50, y: 0)))
        XCTAssertTrue(operation.contains(point: CGPoint(x: 100, y: 50)))

        // ポイントが線から遠い
        XCTAssertFalse(operation.contains(point: CGPoint(x: 50, y: 50)))
    }

    func testPenOperationOffset() {
        let operation = PenOperation(
            points: [
                CGPoint(x: 10, y: 20),
                CGPoint(x: 30, y: 40)
            ],
            color: .red
        )

        let offsetOperation = operation.offset(by: CGPoint(x: 5, y: 10)) as! PenOperation

        XCTAssertEqual(offsetOperation.points[0], CGPoint(x: 15, y: 30))
        XCTAssertEqual(offsetOperation.points[1], CGPoint(x: 35, y: 50))
        XCTAssertEqual(offsetOperation.id, operation.id)
    }

    func testPenOperationGetResizeHandles() {
        let operation = PenOperation(
            points: [
                CGPoint(x: 10, y: 20),
                CGPoint(x: 100, y: 20),
                CGPoint(x: 100, y: 80)
            ],
            color: .red
        )

        let handles = operation.getResizeHandles()

        XCTAssertEqual(handles.count, 8)
        XCTAssertNotNil(handles[.topLeft])
        XCTAssertNotNil(handles[.topRight])
        XCTAssertNotNil(handles[.bottomLeft])
        XCTAssertNotNil(handles[.bottomRight])
    }

    // MARK: - Protocol Conformance Tests

    func testEditOperationProtocolConformance() {
        let lineOp: any EditOperation = LineOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        let rectOp: any EditOperation = RectangleOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100),
            color: .blue
        )

        let pixelOp: any EditOperation = PixelateOperation(
            startPoint: .zero,
            endPoint: CGPoint(x: 100, y: 100)
        )

        let penOp: any EditOperation = PenOperation(
            points: [.zero, CGPoint(x: 100, y: 100)],
            color: .green
        )

        XCTAssertNotNil(lineOp.id)
        XCTAssertNotNil(rectOp.id)
        XCTAssertNotNil(pixelOp.id)
        XCTAssertNotNil(penOp.id)
    }
}
