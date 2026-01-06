import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var showHistory: Bool
    @Binding var showLayerPanel: Bool

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
                .help(tool.rawValue)
            }

            Divider()
                .frame(height: 20)

            ForEach(DrawingColor.allCases) { color in
                Button(action: {
                    viewModel.selectedColor = color
                }) {
                    Circle()
                        .fill(Color(nsColor: color.nsColor))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(viewModel.selectedColor == color ? Color.blue : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .help(color.rawValue)
            }

            Divider()
                .frame(height: 20)

            Button(action: viewModel.undo) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 20))
            }
            .disabled(!viewModel.document.canUndo)
            .buttonStyle(.plain)
            .help("Undo (Ctrl+B)")
            .keyboardShortcut("b", modifiers: .control)

            Button(action: viewModel.redo) {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 20))
            }
            .disabled(!viewModel.document.canRedo)
            .buttonStyle(.plain)
            .help("Redo (Ctrl+R)")
            .keyboardShortcut("r", modifiers: .control)

            Divider()
                .frame(height: 20)

            Button(action: viewModel.clear) {
                Image(systemName: "trash")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .help("Clear All")

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
            .help("拡大率を100%にリセット")
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
            .help("レイヤーパネルを表示/非表示")

            Button(action: {
                showHistory = true
            }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20))
            }
            .buttonStyle(.plain)
            .help("履歴を表示")

            Button(action: viewModel.saveToClipboard) {
                Text("Save to Clipboard")
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
