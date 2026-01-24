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
        VStack(spacing: 0) {
            // ヘッダー
            headerView
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 16)

            // コンテンツ
            ScrollView {
                VStack(spacing: 20) {
                    // 言語設定
                    languageSection

                    // 動作設定
                    behaviorSection

                    // 保存場所設定
                    storageSection

                    // 履歴表示枚数設定
                    historyCountSection
                }
                .padding(24)
            }
        }
        .frame(width: 500, height: 580)
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

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)

                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.settingsTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(L10n.settingsDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSectionHeader(
                    icon: "globe",
                    iconColor: .purple,
                    title: L10n.settingsLanguage
                )

                VStack(alignment: .leading, spacing: 10) {
                    Picker("", selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedLanguage) { newValue in
                        configService.updateLanguage(newValue)
                    }

                    SettingsHint(text: L10n.settingsLanguageDescription)
                }
            }
        }
    }

    // MARK: - Behavior Section

    private var behaviorSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSectionHeader(
                    icon: "gearshape.2.fill",
                    iconColor: .green,
                    title: L10n.settingsBehavior
                )

                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: Binding(
                        get: { configService.config.autoCloseAfterSave },
                        set: { configService.updateAutoCloseAfterSave($0) }
                    )) {
                        HStack(spacing: 10) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 16))
                            Text(L10n.settingsAutoClose)
                        }
                    }
                    .toggleStyle(.switch)

                    SettingsHint(text: L10n.settingsAutoCloseDescription)
                }
            }
        }
    }

    // MARK: - Storage Section

    private var storageSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSectionHeader(
                    icon: "folder.fill",
                    iconColor: .blue,
                    title: L10n.settingsHistoryLocation
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.badge.gearshape")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .frame(width: 20)

                        TextField(L10n.settingsSaveLocation, text: $historyDirectory)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12))

                        Button(action: { showDirectoryPicker = true }) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }

                    HStack(spacing: 8) {
                        Button(action: {
                            historyDirectory = AppConfig.defaultHistoryDirectory
                            configService.updateHistoryDirectory(historyDirectory)
                        }) {
                            Label(L10n.settingsResetToDefault, systemImage: "arrow.counterclockwise")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                        Spacer()

                        Button(action: {
                            configService.updateHistoryDirectory(historyDirectory)
                        }) {
                            Label(L10n.save, systemImage: "checkmark.circle.fill")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }

                    SettingsHint(text: L10n.settingsDefaultLocation)
                }
            }
        }
    }

    // MARK: - History Count Section

    private var historyCountSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                SettingsSectionHeader(
                    icon: "photo.stack.fill",
                    iconColor: .indigo,
                    title: L10n.settingsHistoryCount
                )

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "number")
                            .foregroundColor(.indigo)
                            .font(.system(size: 14))
                            .frame(width: 20)

                        Text(L10n.settingsDisplayCount)
                            .font(.system(size: 13))

                        TextField("", value: $historyDisplayCount, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .font(.system(size: 12))

                        Text(L10n.settingsItems)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)

                        Spacer()

                        Button(action: {
                            configService.updateHistoryDisplayCount(historyDisplayCount)
                        }) {
                            Label(L10n.save, systemImage: "checkmark.circle.fill")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }

                    if historyDisplayCount > AppConfig.recommendedMaxHistoryCount {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                            Text(String(format: L10n.settingsPerformanceWarning, AppConfig.recommendedMaxHistoryCount))
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }

                    SettingsHint(text: L10n.settingsDefaultCount)
                }
            }
        }
    }
}

// MARK: - Components

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 1)
            )
    }
}

private struct SettingsSectionHeader: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.system(size: 14, weight: .semibold))
        }
    }
}

private struct SettingsHint: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundColor(.secondary)
    }
}
