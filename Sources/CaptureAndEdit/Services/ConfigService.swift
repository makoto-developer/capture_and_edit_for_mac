import Foundation

/// 設定管理サービス
final class ConfigService: ObservableObject {
    static let shared = ConfigService()
    
    @Published private(set) var config: AppConfig
    
    private let fileManager = FileManager.default
    
    init() {
        self.config = AppConfig.default
        loadConfig()
        // 言語設定をLocalizationServiceに反映
        if let language = AppLanguage(rawValue: config.language) {
            LocalizationService.shared.setLanguage(language)
        }
    }
    
    /// 設定をファイルから読み込む
    func loadConfig() {
        createConfigDirectoryIfNeeded()
        
        let configPath = AppConfig.configFilePath
        
        guard fileManager.fileExists(atPath: configPath.path) else {
            print("📁 Config file not found. Creating default config...")
            saveConfig()
            return
        }
        
        do {
            let content = try String(contentsOf: configPath, encoding: .utf8)
            config = parseToml(content)
            print("✅ Config loaded from: \(configPath.path)")
        } catch {
            print("❌ Failed to load config: \(error). Using defaults.")
            config = AppConfig.default
            saveConfig()
        }
    }
    
    /// 設定をファイルに保存する
    func saveConfig() {
        createConfigDirectoryIfNeeded()
        
        let configPath = AppConfig.configFilePath
        let tomlContent = generateToml(config)
        
        do {
            try tomlContent.write(to: configPath, atomically: true, encoding: .utf8)
            print("✅ Config saved to: \(configPath.path)")
        } catch {
            print("❌ Failed to save config: \(error)")
        }
    }
    
    /// 設定を更新する
    func updateConfig(_ newConfig: AppConfig) {
        config = newConfig
        saveConfig()
    }
    
    /// 履歴保存ディレクトリを更新する
    func updateHistoryDirectory(_ path: String) {
        var newConfig = config
        newConfig.historyDirectory = path.isEmpty ? AppConfig.defaultHistoryDirectory : path
        updateConfig(newConfig)
    }
    
    /// 履歴表示枚数を更新する
    func updateHistoryDisplayCount(_ count: Int) {
        var newConfig = config
        newConfig.historyDisplayCount = max(1, count)
        updateConfig(newConfig)
    }
    
    /// 保存後自動終了設定を更新する
    func updateAutoCloseAfterSave(_ enabled: Bool) {
        var newConfig = config
        newConfig.autoCloseAfterSave = enabled
        updateConfig(newConfig)
    }

    /// カスタムカラーを追加する
    func addCustomColor(_ color: CustomColor) {
        var newConfig = config
        newConfig.customColors.append(color)
        updateConfig(newConfig)
    }

    /// カスタムカラーを削除する
    func removeCustomColor(_ color: CustomColor) {
        var newConfig = config
        newConfig.customColors.removeAll { $0.id == color.id }
        updateConfig(newConfig)
    }

    /// 言語設定を更新する
    func updateLanguage(_ language: AppLanguage) {
        var newConfig = config
        newConfig.language = language.rawValue
        updateConfig(newConfig)
        LocalizationService.shared.setLanguage(language)
    }
    
    // MARK: - Private Methods
    
    private func createConfigDirectoryIfNeeded() {
        let configDir = AppConfig.configDirectory
        
        guard !fileManager.fileExists(atPath: configDir.path) else {
            return
        }
        
        do {
            try fileManager.createDirectory(
                at: configDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            print("✅ Config directory created: \(configDir.path)")
        } catch {
            print("❌ Failed to create config directory: \(error)")
        }
    }
    
    /// TOMLをパースする
    private func parseToml(_ content: String) -> AppConfig {
        var historyDirectory = AppConfig.defaultHistoryDirectory
        var historyDisplayCount = 25
        var autoCloseAfterSave = true
        var customColors: [CustomColor] = []
        var language = "system"

        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // コメントや空行をスキップ
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // キー=値の形式をパース
            let parts = trimmed.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }

            let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
            var value = String(parts[1]).trimmingCharacters(in: .whitespaces)

            // 文字列の引用符を削除
            if value.hasPrefix("\"") && value.hasSuffix("\"") {
                value = String(value.dropFirst().dropLast())
            }

            switch key {
            case "history_directory":
                historyDirectory = value.isEmpty ? AppConfig.defaultHistoryDirectory : value
            case "history_display_count":
                historyDisplayCount = Int(value) ?? 25
            case "auto_close_after_save":
                autoCloseAfterSave = value.lowercased() == "true"
            case "custom_colors":
                customColors = parseCustomColors(value)
            case "language":
                language = value.isEmpty ? "system" : value
            default:
                break
            }
        }

        return AppConfig(
            historyDirectory: historyDirectory,
            historyDisplayCount: historyDisplayCount,
            autoCloseAfterSave: autoCloseAfterSave,
            customColors: customColors,
            language: language
        )
    }

    /// カスタムカラー配列をパースする
    private func parseCustomColors(_ value: String) -> [CustomColor] {
        var colors: [CustomColor] = []

        // 配列形式 ["#FF0000", "#00FF00"] をパース
        let trimmed = value.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let colorStrings = trimmed.components(separatedBy: ",")

        for colorString in colorStrings {
            var hex = colorString.trimmingCharacters(in: .whitespaces)
            // 引用符を削除
            if hex.hasPrefix("\"") && hex.hasSuffix("\"") {
                hex = String(hex.dropFirst().dropLast())
            }
            if !hex.isEmpty && hex.hasPrefix("#") {
                colors.append(CustomColor(hex: hex))
            }
        }

        return colors
    }
    
    /// TOMLを生成する
    private func generateToml(_ config: AppConfig) -> String {
        let customColorsArray = config.customColors.map { "\"\($0.hex)\"" }.joined(separator: ", ")

        return """
        # Capture and Edit 設定ファイル
        # このファイルは自動生成されます

        # 履歴画像の保存場所
        history_directory = "\(config.historyDirectory)"

        # 履歴で表示する枚数（25枚以上はパフォーマンスに影響する可能性があります）
        history_display_count = \(config.historyDisplayCount)

        # 保存後に自動でウィンドウを閉じる
        auto_close_after_save = \(config.autoCloseAfterSave)

        # カスタムカラーパレット（16進数形式）
        custom_colors = [\(customColorsArray)]

        # 言語設定 (system, ja, en)
        language = "\(config.language)"
        """
    }
}
