import XCTest
@testable import CaptureAndEdit

final class AppConfigTests: XCTestCase {
    
    // MARK: - Default Values Tests
    
    func testDefaultConfig() {
        let config = AppConfig.default
        
        XCTAssertEqual(config.historyDisplayCount, 25)
        XCTAssertTrue(config.autoCloseAfterSave)
        XCTAssertTrue(config.historyDirectory.contains("CaptureAndEdit_history"))
    }
    
    func testDefaultHistoryDirectory() {
        let defaultDir = AppConfig.defaultHistoryDirectory
        
        XCTAssertTrue(defaultDir.contains("CaptureAndEdit_history"))
        XCTAssertTrue(defaultDir.hasPrefix("/Users/"))
    }
    
    func testConfigDirectory() {
        let configDir = AppConfig.configDirectory
        
        XCTAssertTrue(configDir.path.contains(".conf/CaptureAndEdit"))
    }
    
    func testConfigFilePath() {
        let configPath = AppConfig.configFilePath
        
        XCTAssertTrue(configPath.path.contains(".conf/CaptureAndEdit/config.toml"))
    }
    
    func testRecommendedMaxHistoryCount() {
        XCTAssertEqual(AppConfig.recommendedMaxHistoryCount, 25)
    }
    
    // MARK: - Equality Tests
    
    func testConfigEquality() {
        let config1 = AppConfig(
            historyDirectory: "/test/path",
            historyDisplayCount: 30,
            autoCloseAfterSave: false
        )
        
        let config2 = AppConfig(
            historyDirectory: "/test/path",
            historyDisplayCount: 30,
            autoCloseAfterSave: false
        )
        
        XCTAssertEqual(config1, config2)
    }
    
    func testConfigInequality() {
        let config1 = AppConfig(
            historyDirectory: "/test/path1",
            historyDisplayCount: 25,
            autoCloseAfterSave: true
        )
        
        let config2 = AppConfig(
            historyDirectory: "/test/path2",
            historyDisplayCount: 25,
            autoCloseAfterSave: true
        )
        
        XCTAssertNotEqual(config1, config2)
    }
}
