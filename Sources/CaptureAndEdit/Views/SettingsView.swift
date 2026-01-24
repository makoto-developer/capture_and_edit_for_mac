import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject private var configService = ConfigService.shared
    @ObservedObject private var localizationService = LocalizationService.shared

    @State private var historyDirectory: String = ""
    @State private var historyDisplayCount: Int = 25
    @State private var showDirectoryPicker = false
    @State private var selectedLanguage: AppLanguage = .system

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(L10n.settingsTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(L10n.settingsDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.bottom, 8)

                // 言語設定
                SettingsSection(
                    title: L10n.settingsLanguage,
                    icon: "globe",
                    iconColor: .purple
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRow(icon: "character.bubble", iconColor: .purple) {
                            Picker("", selection: $selectedLanguage) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.displayName).tag(language)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedLanguage) { newValue in
                                configService.updateLanguage(newValue)
                            }
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                            Text(L10n.settingsLanguageDescription)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                // 動作設定
                SettingsSection(
                    title: L10n.settingsBehavior,
                    icon: "play.circle.fill",
                    iconColor: .green
                ) {
                    SettingsRow(icon: "xmark.circle", iconColor: .orange) {
                        Toggle(L10n.settingsAutoClose, isOn: Binding(
                            get: { configService.config.autoCloseAfterSave },
                            set: { configService.updateAutoCloseAfterSave($0) }
                        ))
                    }
                    Text(L10n.settingsAutoCloseDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }

                // 保存場所設定
                SettingsSection(
                    title: L10n.settingsHistoryLocation,
                    icon: "folder.fill",
                    iconColor: .blue
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRow(icon: "doc.badge.gearshape", iconColor: .gray) {
                            HStack {
                                TextField(L10n.settingsSaveLocation, text: $historyDirectory)
                                    .textFieldStyle(.roundedBorder)

                                Button(action: { showDirectoryPicker = true }) {
                                    Label(L10n.settingsSelect, systemImage: "folder.badge.plus")
                                }
                            }
                        }

                        HStack {
                            Button(action: {
                                historyDirectory = AppConfig.defaultHistoryDirectory
                                configService.updateHistoryDirectory(historyDirectory)
                            }) {
                                Label(L10n.settingsResetToDefault, systemImage: "arrow.counterclockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button(action: {
                                configService.updateHistoryDirectory(historyDirectory)
                            }) {
                                Label(L10n.save, systemImage: "checkmark.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                            Text(L10n.settingsDefaultLocation)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                // 履歴表示枚数設定
                SettingsSection(
                    title: L10n.settingsHistoryCount,
                    icon: "photo.stack.fill",
                    iconColor: .purple
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRow(icon: "number", iconColor: .indigo) {
                            HStack {
                                Text(L10n.settingsDisplayCount)
                                TextField("", value: $historyDisplayCount, formatter: NumberFormatter())
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                Text(L10n.settingsItems)

                                Spacer()

                                Button(action: {
                                    configService.updateHistoryDisplayCount(historyDisplayCount)
                                }) {
                                    Label(L10n.save, systemImage: "checkmark.circle.fill")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }

                        if historyDisplayCount > AppConfig.recommendedMaxHistoryCount {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(String(format: L10n.settingsPerformanceWarning, AppConfig.recommendedMaxHistoryCount))
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(6)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                            Text(L10n.settingsDefaultCount)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(width: 520, height: 550)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            historyDirectory = configService.config.historyDirectory
            historyDisplayCount = configService.config.historyDisplayCount
            selectedLanguage = AppLanguage(rawValue: configService.config.language) ?? .system
        }
        .fileImporter(
            isPresented: $showDirectoryPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    historyDirectory = url.path
                    configService.updateHistoryDirectory(historyDirectory)
                }
            case .failure(let error):
                print("❌ Failed to select directory: \(error)")
            }
        }
    }
}

// セクションコンポーネント
private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}

// 行コンポーネント
private struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(iconColor)
                .frame(width: 20)
            content()
        }
    }
}
