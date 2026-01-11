import SwiftUI

public struct AboutView: View {
    @StateObject private var viewModel = AboutViewModel()
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // ヘッダー部分
            HStack(spacing: 20) {
                // アイコン（SF Symbolsを使用）
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.appName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("バージョン \(viewModel.version)")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        viewModel.openURL(viewModel.licenseURL)
                    }) {
                        Text(viewModel.license)
                            .font(.body)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .cursor(.pointingHand)
                }
                
                Spacer()
            }
            .padding(30)
            
            Divider()
            
            // リンク部分
            VStack(alignment: .leading, spacing: 12) {
                // ソースコードレポジトリ
                LinkButton(
                    title: "ソースコードレポジトリ",
                    systemImage: "chevron.left.forwardslash.chevron.right"
                ) {
                    viewModel.openURL(viewModel.repositoryURL)
                }
                
                // 最新リリース
                LinkButton(
                    title: "最新リリース",
                    systemImage: "arrow.down.circle"
                ) {
                    viewModel.openURL(viewModel.latestReleaseURL)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // ボタン部分
            VStack(spacing: 12) {
                // フィードバック提出
                ActionButton(
                    title: "フィードバック提出...",
                    systemImage: "bubble.left.and.bubble.right"
                ) {
                    viewModel.openURL(viewModel.feedbackURL)
                }
                
                // プロジェクトに貢献する
                ActionButton(
                    title: "このプロジェクトを支援する",
                    systemImage: "heart.fill",
                    iconColor: .red
                ) {
                    viewModel.openURL(viewModel.sponsorURL)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            
            Divider()
            
            // 終了ボタン
            HStack {
                Spacer()
                Button("終了") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .padding()
            }
        }
        .frame(width: 450, height: 450)
    }
}

// リンクボタン（下線付きテキスト）
private struct LinkButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                Text(title)
                    .font(.body)
                    .underline()
            }
            .foregroundColor(.blue)
        }
        .buttonStyle(.plain)
        .cursor(.pointingHand)
    }
}

// アクションボタン（枠付き）
private struct ActionButton: View {
    let title: String
    let systemImage: String
    var iconColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(iconColor)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

// カーソルをポインティングハンドに変更するためのモディファイア
extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self.onHover { hovering in
            if hovering {
                cursor.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}


