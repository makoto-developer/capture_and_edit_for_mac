import XCTest
@testable import CaptureAndEdit

final class AboutViewModelTests: XCTestCase {
    var viewModel: AboutViewModel!

    override func setUp() {
        super.setUp()
        viewModel = AboutViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - アプリ情報のテスト

    func testAppName() {
        // Given & When & Then
        XCTAssertEqual(viewModel.appName, "Capture And Edit for macOS")
    }

    func testVersion() {
        // Given & When & Then
        XCTAssertFalse(viewModel.version.isEmpty, "バージョン情報が空ではないこと")
        XCTAssertTrue(viewModel.version.contains("."), "バージョン情報がセマンティックバージョニング形式であること")
    }

    func testLicense() {
        // Given & When & Then
        XCTAssertEqual(viewModel.license, "CC BY-NC 4.0")
    }

    // MARK: - URLのテスト

    func testRepositoryURL() {
        // Given
        let expectedURL = "https://github.com/makoto-developer/capture_and_edit_for_mac"

        // When & Then
        XCTAssertEqual(viewModel.repositoryURL, expectedURL)
        XCTAssertNotNil(URL(string: viewModel.repositoryURL), "有効なURLであること")
    }

    func testLatestReleaseURL() {
        // Given
        let expectedURL = "https://github.com/makoto-developer/capture_and_edit_for_mac/releases/latest"

        // When & Then
        XCTAssertEqual(viewModel.latestReleaseURL, expectedURL)
        XCTAssertNotNil(URL(string: viewModel.latestReleaseURL), "有効なURLであること")
    }

    func testFeedbackURL() {
        // Given
        let expectedURL = "https://github.com/makoto-developer/capture_and_edit_for_mac/issues/new?template=feedback.yml"

        // When & Then
        XCTAssertEqual(viewModel.feedbackURL, expectedURL)
        XCTAssertNotNil(URL(string: viewModel.feedbackURL), "有効なURLであること")
        XCTAssertTrue(viewModel.feedbackURL.contains("template=feedback.yml"), "feedbackテンプレートが指定されていること")
    }

    func testSponsorURL() {
        // Given
        let expectedURL = "https://github.com/sponsors/makoto-developer"

        // When & Then
        XCTAssertEqual(viewModel.sponsorURL, expectedURL)
        XCTAssertNotNil(URL(string: viewModel.sponsorURL), "有効なURLであること")
        XCTAssertTrue(viewModel.sponsorURL.contains("sponsors"), "sponsorパスが含まれていること")
    }

    func testLicenseURL() {
        // Given
        let expectedURL = "https://creativecommons.org/licenses/by-nc/4.0/deed.ja"

        // When & Then
        XCTAssertEqual(viewModel.licenseURL, expectedURL)
        XCTAssertNotNil(URL(string: viewModel.licenseURL), "有効なURLであること")
        XCTAssertTrue(viewModel.licenseURL.contains("creativecommons.org"), "Creative CommonsのURLであること")
        XCTAssertTrue(viewModel.licenseURL.contains("by-nc/4.0"), "CC BY-NC 4.0ライセンスであること")
    }

    // MARK: - openURLメソッドのテスト

    func testOpenURLWithValidURL() {
        // Given
        let validURL = "https://github.com"

        // When & Then
        // 実際にURLを開くのではなく、無効なURLでクラッシュしないことを確認
        XCTAssertNoThrow(viewModel.openURL(validURL))
    }

    func testOpenURLWithInvalidURL() {
        // Given
        let invalidURL = "not a valid url"

        // When & Then
        // 無効なURLでもクラッシュしないことを確認
        XCTAssertNoThrow(viewModel.openURL(invalidURL))
    }
}
