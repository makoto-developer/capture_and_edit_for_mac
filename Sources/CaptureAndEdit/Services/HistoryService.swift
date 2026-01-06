import Foundation
import AppKit

enum HistoryServiceError: Error {
    case directoryCreationFailed
    case imageSaveFailed
    case imageLoadFailed
    case itemNotFound
    case invalidImageData
}

final class HistoryService {
    private let historyDirectory: URL
    private let fileManager = FileManager.default

    init(historyDirectory: URL? = nil) {
        // ディレクトリパスを決定
        let directory: URL
        if let customDirectory = historyDirectory {
            directory = customDirectory
        } else {
            // デフォルトはホームディレクトリ直下
            let homeDirectory = fileManager.homeDirectoryForCurrentUser
            directory = homeDirectory.appendingPathComponent("CaptureAndEdit_history")
        }

        self.historyDirectory = directory
        print("📁 HistoryService initialized. Directory: \(self.historyDirectory.path)")
        createHistoryDirectoryIfNeeded()
    }

    private func createHistoryDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: historyDirectory.path) else {
            print("✅ History directory already exists: \(historyDirectory.path)")
            return
        }

        do {
            try fileManager.createDirectory(
                at: historyDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("✅ History directory created: \(historyDirectory.path)")
        } catch {
            print("❌ Failed to create history directory: \(error)")
        }
    }

    func saveImage(_ image: NSImage, timestamp: Date) throws -> HistoryItem {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            throw HistoryServiceError.imageSaveFailed
        }

        let item = HistoryItem(timestamp: timestamp, filePath: "")
        let fileURL = historyDirectory.appendingPathComponent(item.fileName)

        try pngData.write(to: fileURL)

        return HistoryItem(
            timestamp: timestamp,
            filePath: fileURL.path,
            id: item.id
        )
    }

    func loadHistory() throws -> [HistoryItem] {
        guard fileManager.fileExists(atPath: historyDirectory.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: historyDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )

        let items = fileURLs
            .filter { $0.pathExtension == "png" }
            .compactMap { url -> HistoryItem? in
                guard let attributes = try? fileManager.attributesOfItem(atPath: url.path),
                      let creationDate = attributes[.creationDate] as? Date else {
                    return nil
                }

                return HistoryItem(
                    timestamp: creationDate,
                    filePath: url.path
                )
            }
            .sorted(by: >) // 新しい順
            .prefix(25) // 最大25件まで表示（ファイルは削除しない）

        return Array(items)
    }

    func loadImage(for item: HistoryItem) throws -> NSImage {
        guard fileManager.fileExists(atPath: item.filePath) else {
            throw HistoryServiceError.itemNotFound
        }

        guard let image = NSImage(contentsOfFile: item.filePath) else {
            throw HistoryServiceError.imageLoadFailed
        }

        return image
    }

    func deleteItem(_ item: HistoryItem) throws {
        guard fileManager.fileExists(atPath: item.filePath) else {
            throw HistoryServiceError.itemNotFound
        }

        try fileManager.removeItem(atPath: item.filePath)
    }

    func deleteAll() throws {
        let items = try loadHistory()

        for item in items {
            try? deleteItem(item)
        }
    }
}
