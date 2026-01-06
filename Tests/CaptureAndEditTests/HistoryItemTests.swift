import XCTest
@testable import CaptureAndEdit

final class HistoryItemTests: XCTestCase {

    func testHistoryItemInitialization() {
        // Arrange
        let timestamp = Date()
        let filePath = "/path/to/image.png"

        // Act
        let item = HistoryItem(timestamp: timestamp, filePath: filePath)

        // Assert
        XCTAssertEqual(item.timestamp, timestamp)
        XCTAssertEqual(item.filePath, filePath)
        XCTAssertNotNil(item.id)
    }

    func testHistoryItemIdentifiable() {
        // Arrange & Act
        let item1 = HistoryItem(timestamp: Date(), filePath: "/path/1.png")
        let item2 = HistoryItem(timestamp: Date(), filePath: "/path/2.png")

        // Assert
        XCTAssertNotEqual(item1.id, item2.id, "Each HistoryItem should have unique ID")
    }

    func testHistoryItemComparable() {
        // Arrange
        let olderDate = Date(timeIntervalSince1970: 1000)
        let newerDate = Date(timeIntervalSince1970: 2000)

        let olderItem = HistoryItem(timestamp: olderDate, filePath: "/old.png")
        let newerItem = HistoryItem(timestamp: newerDate, filePath: "/new.png")

        // Act & Assert
        XCTAssertTrue(newerItem > olderItem, "Newer items should be greater than older items")
        XCTAssertTrue(olderItem < newerItem, "Older items should be less than newer items")
    }

    func testHistoryItemFileNameGeneration() {
        // Arrange
        let timestamp = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        let item = HistoryItem(timestamp: timestamp, filePath: "")

        // Act
        let fileName = item.fileName

        // Assert
        XCTAssertTrue(fileName.hasPrefix("capture_"), "File name should start with 'capture_'")
        XCTAssertTrue(fileName.hasSuffix(".png"), "File name should end with '.png'")
        XCTAssertTrue(fileName.contains("20210101"), "File name should contain date")
    }
}
