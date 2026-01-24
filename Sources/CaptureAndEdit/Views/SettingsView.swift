import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject private var configService = ConfigService.shared

    @State private var historyDirectory: String = ""
    @State private var historyDisplayCount: Int = 25
    @State private var showDirectoryPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("設定")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("アプリケーションの動作を設定します")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.bottom, 8)

                // 動作設定
                SettingsSection(
                    title: "動作",
                    icon: "play.circle.fill",
                    iconColor: .green
                ) {
                    SettingsRow(icon: "xmark.circle", iconColor: .orange) {
                        Toggle("保存後に自動で閉じる", isOn: Binding(
                            get: { configService.config.autoCloseAfterSave },
                            set: { configService.updateAutoCloseAfterSave($0) }
                        ))
                    }
                    Text("クリップボードに保存後、自動でウィンドウを閉じます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 28)
                }

                // 保存場所設定
                SettingsSection(
                    title: "履歴の保存場所",
                    icon: "folder.fill",
                    iconColor: .blue
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRow(icon: "doc.badge.gearshape", iconColor: .gray) {
                            HStack {
                                TextField("保存場所", text: $historyDirectory)
                                    .textFieldStyle(.roundedBorder)

                                Button(action: { showDirectoryPicker = true }) {
                                    Label("選択", systemImage: "folder.badge.plus")
                                }
                            }
                        }

                        HStack {
                            Button(action: {
                                historyDirectory = AppConfig.defaultHistoryDirectory
                                configService.updateHistoryDirectory(historyDirectory)
                            }) {
                                Label("デフォルトに戻す", systemImage: "arrow.counterclockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button(action: {
                                configService.updateHistoryDirectory(historyDirectory)
                            }) {
                                Label("保存", systemImage: "checkmark.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                            Text("デフォルト: ~/CaptureAndEdit_history")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                // 履歴表示枚数設定
                SettingsSection(
                    title: "履歴の表示枚数",
                    icon: "photo.stack.fill",
                    iconColor: .purple
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        SettingsRow(icon: "number", iconColor: .indigo) {
                            HStack {
                                Text("表示枚数:")
                                TextField("", value: $historyDisplayCount, formatter: NumberFormatter())
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                Text("枚")

                                Spacer()

                                Button(action: {
                                    configService.updateHistoryDisplayCount(historyDisplayCount)
                                }) {
                                    Label("保存", systemImage: "checkmark.circle.fill")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }

                        if historyDisplayCount > AppConfig.recommendedMaxHistoryCount {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("\(AppConfig.recommendedMaxHistoryCount)枚以上はパフォーマンスに影響する可能性があります")
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
                            Text("デフォルト: 25枚")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(width: 520, height: 480)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            historyDirectory = configService.config.historyDirectory
            historyDisplayCount = configService.config.historyDisplayCount
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
