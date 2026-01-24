import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject private var configService = ConfigService.shared
    
    @State private var historyDirectory: String = ""
    @State private var historyDisplayCount: Int = 25
    @State private var showDirectoryPicker = false
    
    var body: some View {
        Form {
            // 動作設定セクション
            Section {
                Toggle("保存後に自動で閉じる", isOn: Binding(
                    get: { configService.config.autoCloseAfterSave },
                    set: { configService.updateAutoCloseAfterSave($0) }
                ))
                .help("クリップボードに保存後、自動でウィンドウを閉じます")
            } header: {
                Text("動作")
            }
            
            // 保存場所セクション
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("現在のパス:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("保存場所", text: $historyDirectory)
                            .textFieldStyle(.roundedBorder)
                            .help("キャプチャ画像の履歴を保存するディレクトリ")
                        
                        Button("選択...") {
                            showDirectoryPicker = true
                        }
                        .help("フォルダを選択")
                    }
                    
                    HStack {
                        Button("デフォルトに戻す") {
                            historyDirectory = AppConfig.defaultHistoryDirectory
                            configService.updateHistoryDirectory(historyDirectory)
                        }
                        .font(.caption)
                        
                        Spacer()
                        
                        Button("保存") {
                            configService.updateHistoryDirectory(historyDirectory)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Text("デフォルト: ~/CaptureAndEdit_history")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("保存場所")
            }
            
            // 履歴表示枚数セクション
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("表示枚数:")
                        
                        TextField("", value: $historyDisplayCount, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .help("履歴に表示する画像の最大枚数")
                        
                        Text("枚")
                        
                        Spacer()
                        
                        Button("保存") {
                            configService.updateHistoryDisplayCount(historyDisplayCount)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if historyDisplayCount > AppConfig.recommendedMaxHistoryCount {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("\(AppConfig.recommendedMaxHistoryCount)枚以上を設定するとパフォーマンスに影響が出る可能性があります")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("デフォルト: 25枚")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("履歴で表示する枚数")
            }
        }
        .padding()
        .frame(width: 500, height: 400)
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
