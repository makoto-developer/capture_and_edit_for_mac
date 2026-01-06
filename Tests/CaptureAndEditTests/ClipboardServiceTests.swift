import XCTest
import AppKit
@testable import CaptureAndEdit

final class ClipboardServiceTests: XCTestCase {

    var service: ClipboardService!

    override func setUp() {
        super.setUp()
        service = ClipboardService.shared
        NSPasteboard.general.clearContents()
    }

    override func tearDown() {
        NSPasteboard.general.clearContents()
        service = nil
        super.tearDown()
    }

    func testSharedInstance() {
        let instance1 = ClipboardService.shared
        let instance2 = ClipboardService.shared

        XCTAssertTrue(instance1 === instance2, "ClipboardService should be a singleton")
    }

    func testCopyImageToClipboard() {
        let image = createTestImage()

        let result = service.copyImageToClipboard(image)

        XCTAssertTrue(result)
    }

    func testCopyImageVerifyPasteboardContents() {
        let image = createTestImage()

        let result = service.copyImageToClipboard(image)

        XCTAssertTrue(result)

        let pasteboard = NSPasteboard.general
        let types = pasteboard.types

        XCTAssertNotNil(types)
        XCTAssertTrue(types?.contains(.png) ?? false)
        XCTAssertTrue(types?.contains(.tiff) ?? false)
    }

    func testCopyEmptyImage() {
        let emptyImage = NSImage()

        let result = service.copyImageToClipboard(emptyImage)

        XCTAssertFalse(result)
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
