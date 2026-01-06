import Foundation
import SwiftUI

final class HistoryViewModel: ObservableObject {
    @Published var items: [HistoryItem] = []
    @Published var errorMessage: String?

    private let historyService: HistoryService

    init(historyService: HistoryService = HistoryService()) {
        self.historyService = historyService
        loadHistory()
    }

    func loadHistory() {
        do {
            items = try historyService.loadHistory()
            errorMessage = nil
        } catch {
            errorMessage = "履歴の読み込みに失敗しました: \(error.localizedDescription)"
            items = []
        }
    }

    func deleteItem(_ item: HistoryItem) {
        do {
            try historyService.deleteItem(item)
            loadHistory()
            errorMessage = nil
        } catch {
            errorMessage = "削除に失敗しました: \(error.localizedDescription)"
        }
    }

    func deleteAll() {
        do {
            try historyService.deleteAll()
            loadHistory()
            errorMessage = nil
        } catch {
            errorMessage = "全削除に失敗しました: \(error.localizedDescription)"
        }
    }

    func copyToClipboard(_ item: HistoryItem) -> Bool {
        do {
            let image = try historyService.loadImage(for: item)
            let success = ClipboardService.shared.copyImageToClipboard(image)

            if !success {
                errorMessage = "クリップボードへのコピーに失敗しました"
            }

            return success
        } catch {
            errorMessage = "画像の読み込みに失敗しました: \(error.localizedDescription)"
            return false
        }
    }
}
