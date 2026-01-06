import XCTest
import AppKit
@testable import CaptureAndEdit

final class HistoryViewModelTests: XCTestCase {
    var sut: HistoryViewModel!
    var testHistoryDirectory: URL!
    var historyService: HistoryService!

    override func setUp() {
        super.setUp()
        let tempDir = FileManager.default.temporaryDirectory
        testHistoryDirectory = tempDir.appendingPathComponent("test_history_vm_\(UUID().uuidString)")
        historyService = HistoryService(historyDirectory: testHistoryDirectory)
        sut = HistoryViewModel(historyService: historyService)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: testHistoryDirectory)
        sut = nil
        historyService = nil
        super.tearDown()
    }

    func testLoadHistoryPopulatesItems() throws {
        // Arrange
        let image = createTestImage()
        _ = try historyService.saveImage(image, timestamp: Date())

        // Act
        sut.loadHistory()

        // Assert
        XCTAssertEqual(sut.items.count, 1)
    }

    func testDeleteItemRemovesFromList() throws {
        // Arrange
        let image = createTestImage()
        let item = try historyService.saveImage(image, timestamp: Date())
        sut.loadHistory()

        XCTAssertEqual(sut.items.count, 1)

        // Act
        sut.deleteItem(item)

        // Assert
        XCTAssertEqual(sut.items.count, 0)
    }

    func testDeleteAllClearsAllItems() throws {
        // Arrange
        let image1 = createTestImage()
        let image2 = createTestImage()

        _ = try historyService.saveImage(image1, timestamp: Date())
        _ = try historyService.saveImage(image2, timestamp: Date())

        sut.loadHistory()
        XCTAssertEqual(sut.items.count, 2)

        // Act
        sut.deleteAll()

        // Assert
        XCTAssertEqual(sut.items.count, 0)
    }

    func testCopyToClipboardLoadsAndCopiesImage() throws {
        // Arrange
        let image = createTestImage()
        let item = try historyService.saveImage(image, timestamp: Date())
        sut.loadHistory()

        // Act
        let success = sut.copyToClipboard(item)

        // Assert
        XCTAssertTrue(success)
    }

    // MARK: - Helper Methods

    private func createTestImage() -> NSImage {
        let size = NSSize(width: 100, height: 100)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.blue.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
    }
}
