import SwiftUI
import CaptureAndEdit

@main
struct CaptureAndEditApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
