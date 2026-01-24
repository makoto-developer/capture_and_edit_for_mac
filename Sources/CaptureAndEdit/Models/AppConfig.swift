import Foundation

/// アプリケーション設定モデル
struct AppConfig: Equatable {
    /// 履歴画像の保存場所
    var historyDirectory: String

    /// 履歴で表示する枚数
    var historyDisplayCount: Int

    /// 保存後に自動で閉じる
    var autoCloseAfterSave: Bool

    /// カスタムカラーパレット
    var customColors: [CustomColor]

    /// 言語設定
    var language: String

    /// デフォルト設定
    static let `default` = AppConfig(
        historyDirectory: defaultHistoryDirectory,
        historyDisplayCount: 25,
        autoCloseAfterSave: true,
        customColors: [],
        language: "system"
    )
    
    /// デフォルトの履歴保存ディレクトリ
    static var defaultHistoryDirectory: String {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        return homeDirectory.appendingPathComponent("CaptureAndEdit_history").path
    }
    
    /// 設定ディレクトリパス
    static var configDirectory: URL {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        return homeDirectory.appendingPathComponent(".conf/CaptureAndEdit")
    }
    
    /// 設定ファイルパス
    static var configFilePath: URL {
        configDirectory.appendingPathComponent("config.toml")
    }
    
    /// 履歴表示枚数の推奨最大値
    static let recommendedMaxHistoryCount = 25
}
