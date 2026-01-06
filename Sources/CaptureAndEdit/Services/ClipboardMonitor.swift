import Foundation
import AppKit

final class ClipboardMonitor: ObservableObject {
    @Published private(set) var latestImage: NSImage?

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let pasteboard = NSPasteboard.general

    var onImageCaptured: ((NSImage) -> Void)?

    init() {
        lastChangeCount = pasteboard.changeCount
    }

    func startMonitoring() {
        print("🚀 ClipboardMonitor: startMonitoring() called")
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        print("✅ ClipboardMonitor: Timer started with 0.5s interval")
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }

        lastChangeCount = currentChangeCount

        print("📋 Clipboard changed! Count: \(currentChangeCount)")
        print("📋 Types: \(pasteboard.types ?? [])")

        if let image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            print("✅ Image detected: \(image.size)")
            latestImage = image
            onImageCaptured?(image)
        } else {
            print("❌ No image found")
        }
    }

    deinit {
        stopMonitoring()
    }
}
