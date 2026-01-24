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
    private var historyDirectory: URL {
        URL(fileURLWithPath: ConfigService.shared.config.historyDirectory)
    }
    
    private var maxDisplayCount: Int {
        ConfigService.shared.config.historyDisplayCount
    }
    
    private let fileManager = FileManager.default

    init() {
        print("📁 HistoryService initialized. Directory: \(historyDirectory.path)")
        createHistoryDirectoryIfNeeded()
    }

    private func createHistoryDirectoryIfNeeded() {
        let directory = historyDirectory
        guard !fileManager.fileExists(atPath: directory.path) else {
            print("✅ History directory already exists: \(directory.path)")
            return
        }

        do {
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("✅ History directory created: \(directory.path)")
        } catch {
            print("❌ Failed to create history directory: \(error)")
        }
    }

    func saveImage(_ image: NSImage, timestamp: Date) throws -> HistoryItem {
        // 保存前にディレクトリを確認・作成
        createHistoryDirectoryIfNeeded()
        
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
        let directory = historyDirectory
        guard fileManager.fileExists(atPath: directory.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: directory,
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
            .prefix(maxDisplayCount) // 設定に基づいた表示枚数

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
