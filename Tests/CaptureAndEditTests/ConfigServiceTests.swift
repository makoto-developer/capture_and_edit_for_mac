import XCTest
@testable import CaptureAndEdit

final class ConfigServiceTests: XCTestCase {
    
    // MARK: - Singleton Tests
    
    func testSharedInstance() {
        let instance1 = ConfigService.shared
        let instance2 = ConfigService.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Config Loading Tests
    
    func testInitialConfigHasDefaultValues() {
        let service = ConfigService.shared
        
        // デフォルト値または保存された値が読み込まれる
        XCTAssertGreaterThan(service.config.historyDisplayCount, 0)
        XCTAssertFalse(service.config.historyDirectory.isEmpty)
    }
    
    // MARK: - Config Update Tests
    
    func testUpdateHistoryDirectory() {
        let service = ConfigService.shared
        let originalDirectory = service.config.historyDirectory
        
        let testDirectory = "/tmp/test_capture_edit"
        service.updateHistoryDirectory(testDirectory)
        
        XCTAssertEqual(service.config.historyDirectory, testDirectory)
        
        // 元に戻す
        service.updateHistoryDirectory(originalDirectory)
    }
    
    func testUpdateHistoryDirectoryWithEmptyString() {
        let service = ConfigService.shared
        let originalDirectory = service.config.historyDirectory
        
        // 空文字列を設定するとデフォルトに戻る
        service.updateHistoryDirectory("")
        
        XCTAssertEqual(service.config.historyDirectory, AppConfig.defaultHistoryDirectory)
        
        // 元に戻す
        service.updateHistoryDirectory(originalDirectory)
    }
    
    func testUpdateHistoryDisplayCount() {
        let service = ConfigService.shared
        let originalCount = service.config.historyDisplayCount
        
        service.updateHistoryDisplayCount(50)
        XCTAssertEqual(service.config.historyDisplayCount, 50)
        
        // 元に戻す
        service.updateHistoryDisplayCount(originalCount)
    }
    
    func testUpdateHistoryDisplayCountMinimum() {
        let service = ConfigService.shared
        let originalCount = service.config.historyDisplayCount
        
        // 0以下を設定すると1になる
        service.updateHistoryDisplayCount(0)
        XCTAssertEqual(service.config.historyDisplayCount, 1)
        
        service.updateHistoryDisplayCount(-5)
        XCTAssertEqual(service.config.historyDisplayCount, 1)
        
        // 元に戻す
        service.updateHistoryDisplayCount(originalCount)
    }
    
    func testUpdateAutoCloseAfterSave() {
        let service = ConfigService.shared
        let originalValue = service.config.autoCloseAfterSave
        
        service.updateAutoCloseAfterSave(true)
        XCTAssertTrue(service.config.autoCloseAfterSave)
        
        service.updateAutoCloseAfterSave(false)
        XCTAssertFalse(service.config.autoCloseAfterSave)
        
        // 元に戻す
        service.updateAutoCloseAfterSave(originalValue)
    }
    
    // MARK: - Full Config Update Tests
    
    func testUpdateConfig() {
        let service = ConfigService.shared
        let originalConfig = service.config
        
        let newConfig = AppConfig(
            historyDirectory: "/tmp/test",
            historyDisplayCount: 100,
            autoCloseAfterSave: false
        )
        
        service.updateConfig(newConfig)
        
        XCTAssertEqual(service.config.historyDirectory, "/tmp/test")
        XCTAssertEqual(service.config.historyDisplayCount, 100)
        XCTAssertFalse(service.config.autoCloseAfterSave)
        
        // 元に戻す
        service.updateConfig(originalConfig)
    }
}
