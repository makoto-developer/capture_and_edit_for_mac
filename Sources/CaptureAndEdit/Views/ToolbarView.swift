import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var configService = ConfigService.shared
    @Binding var showHistory: Bool
    @Binding var showLayerPanel: Bool
    @State private var newColor: Color = .red

    var body: some View {
        HStack(spacing: 16) {
            ForEach(DrawingTool.allCases) { tool in
                Button(action: {
                    viewModel.selectedTool = tool
                }) {
                    Image(systemName: tool.systemImage)
                        .foregroundColor(viewModel.selectedTool == tool ? .blue : .primary)
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
                .help(tool.helpText)
            }

            Divider()
                .frame(height: 20)

            // プリセットカラー
            ForEach(DrawingColor.allCases) { color in
                Button(action: {
                    viewModel.selectPresetColor(color)
                }) {
                    Circle()
                        .fill(Color(nsColor: color.nsColor))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(viewModel.isPresetColorSelected(color) ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .help(color.helpText)
            }

            // カスタムカラー
            ForEach(configService.config.customColors) { customColor in
                Button(action: {
                    viewModel.selectCustomColor(customColor)
                }) {
                    Circle()
                        .fill(Color(nsColor: customColor.nsColor))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(viewModel.isCustomColorSelected(customColor) ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .help(customColor.helpText)
                .contextMenu {
                    Button(role: .destructive) {
                        configService.removeCustomColor(customColor)
                    } label: {
                        Label(L10n.delete, systemImage: "trash")
                    }
                }
            }

            // カラー追加ボタン
            ColorPicker("", selection: $newColor)
                .labelsHidden()
                .frame(width: 24, height: 24)
                .help(L10n.toolbarAddCustomColor)
                .onChange(of: newColor) { newValue in
                    let nsColor = NSColor(newValue)
                    let customColor = CustomColor(color: nsColor)
                    configService.addCustomColor(customColor)
                    viewModel.selectCustomColor(customColor)
                }

            Divider()
                .frame(height: 20)

            Button(action: viewModel.undo) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 20))
            }
            .disabled(!viewModel.document.canUndo)
            .buttonStyle(.plain)
            .help(L10n.toolbarUndo)
            .keyboardShortcut("b", modifiers: .control)

            Button(action: viewModel.redo) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 20))
            }
            .disabled(!viewModel.document.canRedo)
            .buttonStyle(.plain)
            .help(L10n.toolbarRedo)
            .keyboardShortcut("r", modifiers: .control)

            Divider()
                .frame(height: 20)

            Button(action: viewModel.clear) {
                Image(systemName: "trash")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .help(L10n.toolbarClear)

            Spacer()

            // Zoom controls
            Text(viewModel.zoomScaleFormatted)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 50)

            Button(action: {
                viewModel.resetZoomScale()
            }) {
                Text("100%")
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.zoomScale == 1.0 ? .secondary : .blue)
            }
            .buttonStyle(.plain)
            .help(L10n.toolbarResetZoom)
            .disabled(viewModel.zoomScale == 1.0)

            Divider()
                .frame(height: 20)

            // Layer Panel Toggle
            Button(action: {
                showLayerPanel.toggle()
            }) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 20))
                    .foregroundColor(showLayerPanel ? .blue : .primary)
            }
            .buttonStyle(.plain)
            .help(L10n.toolbarLayerPanel)

            Button(action: {
                showHistory = true
            }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .help(L10n.toolbarHistory)

            Button(action: viewModel.saveToClipboard) {
                Text(L10n.toolbarSaveToClipboard)
                    .font(.system(size: 13))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .fixedSize()
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
