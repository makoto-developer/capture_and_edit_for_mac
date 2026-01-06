import XCTest
import AppKit
@testable import CaptureAndEdit

final class HistoryServiceTests: XCTestCase {
    var sut: HistoryService!
    var testHistoryDirectory: URL!

    override func setUp() {
        super.setUp()
        // テスト用の一時ディレクトリを使用
        let tempDir = FileManager.default.temporaryDirectory
        testHistoryDirectory = tempDir.appendingPathComponent("test_history_\(UUID().uuidString)")
        sut = HistoryService(historyDirectory: testHistoryDirectory)
    }

    override func tearDown() {
        // テスト用ディレクトリをクリーンアップ
        try? FileManager.default.removeItem(at: testHistoryDirectory)
        sut = nil
        super.tearDown()
    }

    func testInitializationCreatesHistoryDirectory() {
        // Act
        _ = HistoryService(historyDirectory: testHistoryDirectory)

        // Assert
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: testHistoryDirectory.path),
            "History directory should be created on initialization"
        )
    }

    func testSaveImageCreatesFileWithTimestamp() throws {
        // Arrange
        let image = createTestImage()
        let timestamp = Date()

        // Act
        let result = try sut.saveImage(image, timestamp: timestamp)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(FileManager.default.fileExists(atPath: result.filePath))
        XCTAssertEqual(result.timestamp, timestamp)
    }

    func testLoadHistoryReturnsItemsSortedNewestFirst() throws {
        // Arrange
        let image1 = createTestImage()
        let image2 = createTestImage()

        let timestamp1 = Date(timeIntervalSince1970: 1000)
        let timestamp2 = Date(timeIntervalSince1970: 2000)

        _ = try sut.saveImage(image1, timestamp: timestamp1)
        _ = try sut.saveImage(image2, timestamp: timestamp2)

        // Act
        let items = try sut.loadHistory()

        // Assert
        XCTAssertEqual(items.count, 2)
        XCTAssertTrue(items[0].timestamp > items[1].timestamp, "Items should be sorted newest first")
    }

    func testLoadHistoryLimitsTo25Items() throws {
        // Arrange: 30件の画像を保存
        let image = createTestImage()
        for i in 0..<30 {
            let timestamp = Date(timeIntervalSince1970: TimeInterval(i * 1000))
            _ = try sut.saveImage(image, timestamp: timestamp)
        }

        // Act
        let items = try sut.loadHistory()

        // Assert: 25件まで表示される
        XCTAssertEqual(items.count, 25, "Should limit to 25 items")
    }

    func testLoadHistoryReturnsMostRecent25Items() throws {
        // Arrange: 30件の画像を保存
        let image = createTestImage()
        var timestamps: [Date] = []
        for i in 0..<30 {
            let timestamp = Date(timeIntervalSince1970: TimeInterval(i * 1000))
            timestamps.append(timestamp)
            _ = try sut.saveImage(image, timestamp: timestamp)
        }

        // Act
        let items = try sut.loadHistory()

        // Assert: 最新の25件が返される（新しい順）
        XCTAssertEqual(items.count, 25)
        let expectedNewestTimestamp = timestamps[29] // 最後に保存したもの
        let expectedOldestInResultTimestamp = timestamps[5] // 6番目に保存したもの（0-indexedなので5）

        XCTAssertEqual(items.first?.timestamp, expectedNewestTimestamp, "First item should be the newest")
        XCTAssertEqual(items.last?.timestamp, expectedOldestInResultTimestamp, "Last item should be the 6th oldest")
    }

    func testDeleteItemRemovesFile() throws {
        // Arrange
        let image = createTestImage()
        let item = try sut.saveImage(image, timestamp: Date())

        // Act
        try sut.deleteItem(item)

        // Assert
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: item.filePath),
            "File should be deleted"
        )
    }

    func testDeleteAllRemovesAllFiles() throws {
        // Arrange
        let image1 = createTestImage()
        let image2 = createTestImage()

        _ = try sut.saveImage(image1, timestamp: Date())
        _ = try sut.saveImage(image2, timestamp: Date())

        // Act
        try sut.deleteAll()

        // Assert
        let items = try sut.loadHistory()
        XCTAssertEqual(items.count, 0, "All items should be deleted")
    }

    func testLoadImageReturnsCorrectImage() throws {
        // Arrange
        let originalImage = createTestImage()
        let item = try sut.saveImage(originalImage, timestamp: Date())

        // Act
        let loadedImage = try sut.loadImage(for: item)

        // Assert
        XCTAssertNotNil(loadedImage)
        XCTAssertEqual(loadedImage?.size, originalImage.size)
    }

    // MARK: - Helper Methods

    private func createTestImage() -> NSImage {
        let size = NSSize(width: 100, height: 100)
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.red.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
    }
}
