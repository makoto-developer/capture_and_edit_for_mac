import Foundation
import AppKit

final class ClipboardService {
    static let shared = ClipboardService()

    private init() {}

    func copyImageToClipboard(_ image: NSImage) -> Bool {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return false
        }

        pasteboard.declareTypes([.png, .tiff], owner: nil)
        pasteboard.setData(pngData, forType: .png)
        pasteboard.setData(tiffData, forType: .tiff)

        return true
    }
}
