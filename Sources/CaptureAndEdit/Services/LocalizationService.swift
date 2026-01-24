import Foundation

/// サポートする言語
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case japanese = "ja"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return L10n.languageSystem
        case .japanese:
            return "日本語"
        case .english:
            return "English"
        }
    }
}

/// ローカライゼーションサービス
final class LocalizationService: ObservableObject {
    static let shared = LocalizationService()

    @Published private(set) var currentLanguage: AppLanguage = .system

    private init() {
        // ConfigServiceから言語設定を読み込む（初期化後）
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        objectWillChange.send()
    }

    /// 現在の言語コードを取得
    var effectiveLanguageCode: String {
        switch currentLanguage {
        case .system:
            return Locale.current.language.languageCode?.identifier ?? "en"
        case .japanese:
            return "ja"
        case .english:
            return "en"
        }
    }

    /// 日本語かどうか
    var isJapanese: Bool {
        effectiveLanguageCode == "ja"
    }
}

/// ローカライズ文字列
enum L10n {
    // MARK: - General
    static var ok: String { localized("OK") }
    static var cancel: String { localized("Cancel", ja: "キャンセル") }
    static var delete: String { localized("Delete", ja: "削除") }
    static var save: String { localized("Save", ja: "保存") }
    static var close: String { localized("Close", ja: "閉じる") }

    // MARK: - App
    static var appName: String { "Capture and Edit" }

    // MARK: - Menu
    static var menuShowWindow: String { localized("Show Window", ja: "ウィンドウを表示") }
    static var menuSettings: String { localized("Settings...", ja: "設定...") }
    static var menuAbout: String { localized("About This App", ja: "このアプリについて") }
    static var menuQuit: String { localized("Quit", ja: "終了") }
    static var menuCloseWindow: String { localized("Close Window", ja: "ウィンドウを閉じる") }
    static var menuUndo: String { localized("Undo", ja: "元に戻す") }
    static var menuRedo: String { localized("Redo", ja: "やり直す") }
    static var menuAboutApp: String { localized("About Capture and Edit", ja: "Capture and Edit について") }
    static var menuQuitApp: String { localized("Quit Capture and Edit", ja: "Capture and Edit を終了") }

    // MARK: - Settings
    static var settingsTitle: String { localized("Settings", ja: "設定") }
    static var settingsDescription: String { localized("Configure application behavior", ja: "アプリケーションの動作を設定します") }
    static var settingsBehavior: String { localized("Behavior", ja: "動作") }
    static var settingsAutoClose: String { localized("Auto close after save", ja: "保存後に自動で閉じる") }
    static var settingsAutoCloseDescription: String { localized("Automatically closes the window after saving to clipboard", ja: "クリップボードに保存後、自動でウィンドウを閉じます") }
    static var settingsHistoryLocation: String { localized("History Save Location", ja: "履歴の保存場所") }
    static var settingsSaveLocation: String { localized("Save Location", ja: "保存場所") }
    static var settingsSelect: String { localized("Select", ja: "選択") }
    static var settingsResetToDefault: String { localized("Reset to Default", ja: "デフォルトに戻す") }
    static var settingsDefaultLocation: String { localized("Default: ~/CaptureAndEdit_history", ja: "デフォルト: ~/CaptureAndEdit_history") }
    static var settingsHistoryCount: String { localized("History Display Count", ja: "履歴の表示枚数") }
    static var settingsDisplayCount: String { localized("Display Count:", ja: "表示枚数:") }
    static var settingsItems: String { localized("items", ja: "枚") }
    static var settingsDefaultCount: String { localized("Default: 25 items", ja: "デフォルト: 25枚") }
    static var settingsPerformanceWarning: String { localized("More than %d items may affect performance", ja: "%d枚以上はパフォーマンスに影響する可能性があります") }
    static var settingsLanguage: String { localized("Language", ja: "言語") }
    static var settingsLanguageDescription: String { localized("Changes will take effect immediately", ja: "変更は即座に反映されます") }

    // MARK: - Language
    static var languageSystem: String { localized("System Default", ja: "システムに従う") }

    // MARK: - Toolbar
    static var toolbarSaveToClipboard: String { localized("Save to Clipboard", ja: "クリップボードに保存") }
    static var toolbarUndo: String { localized("Undo (Ctrl+B)", ja: "元に戻す (Ctrl+B)") }
    static var toolbarRedo: String { localized("Redo (Ctrl+R)", ja: "やり直す (Ctrl+R)") }
    static var toolbarClear: String { localized("Clear All", ja: "すべてクリア") }
    static var toolbarHistory: String { localized("Show History", ja: "編集履歴を表示") }
    static var toolbarLayerPanel: String { localized("Show/Hide Layer Panel", ja: "レイヤーパネルを表示/非表示") }
    static var toolbarResetZoom: String { localized("Reset zoom to 100%", ja: "拡大率を100%にリセット") }
    static var toolbarAddCustomColor: String { localized("Add Custom Color", ja: "カスタムカラーを追加") }

    // MARK: - Drawing Tools
    static var toolSelect: String { localized("Select - Select and move objects", ja: "選択 - オブジェクトを選択して移動") }
    static var toolPen: String { localized("Pen - Draw freely (Shift for straight line)", ja: "ペン - 自由に線を描画（Shiftキーで直線）") }
    static var toolLine: String { localized("Line - Draw a straight line between two points", ja: "直線 - 2点間に直線を描画") }
    static var toolRectangle: String { localized("Rectangle - Draw a rectangular frame", ja: "矩形 - 四角形の枠を描画") }
    static var toolPixelate: String { localized("Fill - Fill area with black (for masking sensitive info)", ja: "塗りつぶし - 領域を黒で塗りつぶし（機密情報のマスキング用）") }
    static var toolArrow: String { localized("Arrow - Draw an arrow", ja: "矢印 - 矢印を描画") }
    static var toolText: String { localized("Text - Add text at clicked position", ja: "テキスト - クリックした位置にテキストを追加") }

    // MARK: - Colors
    static var colorRed: String { localized("Red", ja: "赤") }
    static var colorBlue: String { localized("Blue", ja: "青") }
    static var colorGreen: String { localized("Green", ja: "緑") }
    static var colorYellow: String { localized("Yellow", ja: "黄") }
    static var colorBlack: String { localized("Black", ja: "黒") }

    // MARK: - History
    static var historyTitle: String { localized("History", ja: "履歴") }
    static var historyDeleteAll: String { localized("Delete All", ja: "全削除") }
    static var historyEmpty: String { localized("No History", ja: "履歴がありません") }
    static var historyEmptyDescription: String { localized("Saved images will appear here", ja: "画像を保存すると、ここに履歴が表示されます") }
    static var historyDeleteAllTitle: String { localized("Delete All History", ja: "全履歴を削除") }
    static var historyDeleteAllMessage: String { localized("Are you sure you want to delete all history? This action cannot be undone.", ja: "すべての履歴を削除してもよろしいですか？この操作は取り消せません。") }
    static var historyDeleteTitle: String { localized("Delete History", ja: "履歴を削除") }
    static var historyDeleteMessage: String { localized("Are you sure you want to delete this history?", ja: "この履歴を削除してもよろしいですか？") }
    static var historyCopyToClipboard: String { localized("Copy to Clipboard", ja: "クリップボードにコピー") }

    // MARK: - Layer Panel
    static var layerTitle: String { localized("Layers", ja: "レイヤー") }
    static var layerAdd: String { localized("Add Layer", ja: "レイヤーを追加") }
    static var layerDelete: String { localized("Delete Layer", ja: "レイヤーを削除") }
    static var layerOpacity: String { localized("Opacity", ja: "不透明度") }
    static var layerMergeVisible: String { localized("Merge Visible", ja: "表示を統合") }
    static var layerFlatten: String { localized("Flatten", ja: "すべて統合") }

    // MARK: - Text Input
    static var textInputTitle: String { localized("Enter Text", ja: "テキストを入力") }
    static var textInputMessage: String { localized("Enter text to add to the image", ja: "画像に追加するテキストを入力してください") }
    static var textInputPlaceholder: String { localized("Enter text here", ja: "テキストを入力してください") }

    // MARK: - Main View
    static var mainViewPlaceholder: String { localized("Capture an image to clipboard to start editing", ja: "クリップボードに画像をキャプチャして編集を開始") }

    // MARK: - About
    static var aboutVersion: String { localized("Version", ja: "バージョン") }
    static var aboutAuthor: String { localized("Author:", ja: "作者:") }
    static var aboutSourceCode: String { localized("Source Code Repository", ja: "ソースコードレポジトリ") }
    static var aboutLatestRelease: String { localized("Latest Release", ja: "最新リリース") }
    static var aboutFeedback: String { localized("Submit Feedback...", ja: "フィードバック提出...") }
    static var aboutSupport: String { localized("Support This Project", ja: "このプロジェクトを支援する") }

    // MARK: - Private Helper
    private static func localized(_ english: String, ja japanese: String? = nil) -> String {
        let service = LocalizationService.shared
        if service.isJapanese {
            return japanese ?? english
        }
        return english
    }
}
