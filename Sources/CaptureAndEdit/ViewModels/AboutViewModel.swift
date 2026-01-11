import Foundation
import AppKit

public final class AboutViewModel: ObservableObject {
    // アプリ情報
    public let appName = "Capture And Edit for macOS"
    public let version = "1.0.0" // リリース時に更新してください
    public let license = "CC BY-NC 4.0"
    
    // リンクURL
    public let repositoryURL = "https://github.com/makoto-developer/capture_and_edit_for_mac"
    public let latestReleaseURL = "https://github.com/makoto-developer/capture_and_edit_for_mac/releases/latest"
    public let feedbackURL = "https://github.com/makoto-developer/capture_and_edit_for_mac/issues/new?template=feedback.yml"
    public let sponsorURL = "https://github.com/sponsors/makoto-developer"
    public let licenseURL = "https://creativecommons.org/licenses/by-nc/4.0/deed.ja"
    
    public init() {}
    
    // URLを開く
    public func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }
}
