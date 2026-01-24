import Foundation
import AppKit
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var document = ImageDocument()
    @Published var selectedTool: DrawingTool = .line
    @Published var selectedPresetColor: DrawingColor = .red
    @Published var selectedCustomColorId: UUID?
    @Published var zoomScale: CGFloat = 1.0

    let clipboardMonitor = ClipboardMonitor()
    let historyService = HistoryService()
    var window: (() -> NSWindow?)?

    /// 保存後に自動終了するかどうか（ConfigServiceから取得）
    var autoCloseAfterSave: Bool {
        ConfigService.shared.config.autoCloseAfterSave
    }

    /// 現在選択中の色（NSColor）
    var selectedColor: NSColor {
        if let customColorId = selectedCustomColorId,
           let customColor = ConfigService.shared.config.customColors.first(where: { $0.id == customColorId }) {
            return customColor.nsColor
        }
        return selectedPresetColor.nsColor
    }

    /// プリセットカラーを選択
    func selectPresetColor(_ color: DrawingColor) {
        selectedPresetColor = color
        selectedCustomColorId = nil
    }

    /// カスタムカラーを選択
    func selectCustomColor(_ color: CustomColor) {
        selectedCustomColorId = color.id
    }

    /// プリセットカラーが選択されているか
    func isPresetColorSelected(_ color: DrawingColor) -> Bool {
        selectedCustomColorId == nil && selectedPresetColor == color
    }

    /// カスタムカラーが選択されているか
    func isCustomColorSelected(_ color: CustomColor) -> Bool {
        selectedCustomColorId == color.id
    }

    // Zoom constraints
    private let minZoomScale: CGFloat = 0.5  // 50%
    private let maxZoomScale: CGFloat = 3.0  // 300%

    init() {
        clipboardMonitor.onImageCaptured = { [weak self] image in
            self?.handleImageCaptured(image)
        }
    }

    func startMonitoring() {
        clipboardMonitor.startMonitoring()
    }

    func stopMonitoring() {
        clipboardMonitor.stopMonitoring()
    }

    private func handleImageCaptured(_ image: NSImage) {
        print("🖼️ handleImageCaptured called! Image size: \(image.size)")

        // キャプチャ時に自動的に履歴に保存
        do {
            _ = try historyService.saveImage(image, timestamp: Date())
            print("✅ キャプチャ画像を履歴に自動保存しました")
        } catch {
            print("❌ キャプチャ画像の履歴保存に失敗しました: \(error)")
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // メインスレッドで画像を設定（SwiftUIの@Publishedの更新）
            self.document.setImage(image)
            print("📄 Document image set on main thread")

            // SwiftUIに変更を通知
            self.objectWillChange.send()
            print("📢 objectWillChange sent")

            // アプリをアクティベート
            NSApp.activate(ignoringOtherApps: true)
            print("🎯 App activated")

            if let window = self.window?() {
                print("🪟 Window found via closure, making key and order front")

                // ウィンドウを最前列に表示
                window.level = .floating
                window.orderFrontRegardless()
                window.makeKeyAndOrderFront(nil)

                // 通常レベルに戻す（編集中は他のウィンドウの前にも出せるように）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    window.level = .normal
                }

                print("✅ Window brought to front")
            } else {
                print("❌ No window found via closure!")
            }
        }
    }

    func saveToClipboard() {
        guard let renderedImage = document.renderImage() else { return }

        let success = ClipboardService.shared.copyImageToClipboard(renderedImage)

        if success {
            // 編集後の画像を履歴に保存
            do {
                _ = try historyService.saveImage(renderedImage, timestamp: Date())
                print("✅ 編集後の画像を履歴に保存しました")
            } catch {
                print("❌ 編集後の画像の履歴保存に失敗しました: \(error)")
            }

            if autoCloseAfterSave {
                NSApp.terminate(nil)
            }
        }
    }

    func undo() {
        document.undo()
        objectWillChange.send()
    }

    func redo() {
        document.redo()
        objectWillChange.send()
    }

    func clear() {
        document.clear()
        objectWillChange.send()
    }

    // MARK: - Zoom Methods

    func setZoomScale(_ scale: CGFloat) {
        zoomScale = min(max(scale, minZoomScale), maxZoomScale)
    }

    func resetZoomScale() {
        zoomScale = 1.0
    }

    var zoomScaleFormatted: String {
        return "\(Int(zoomScale * 100))%"
    }
}
