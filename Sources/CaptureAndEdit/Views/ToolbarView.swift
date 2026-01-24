import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var configService = ConfigService.shared
    @Binding var showHistory: Bool
    @Binding var showLayerPanel: Bool
    @State private var newColor: Color = .red

    var body: some View {
        HStack(spacing: 16) {
            // Drawing Tools
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
                .frame(height: 44)

            // Color Palette (2 rows)
            ColorPaletteView(
                viewModel: viewModel,
                configService: configService,
                newColor: $newColor
            )

            Divider()
                .frame(height: 44)

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
                .frame(height: 44)

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
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)

            Button(action: {
                viewModel.resetZoomScale()
            }) {
                Text("100%")
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.zoomScale == 1.0 ? .secondary : .blue)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .buttonStyle(.plain)
            .help(L10n.toolbarResetZoom)
            .disabled(viewModel.zoomScale == 1.0)

            Divider()
                .frame(height: 44)

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
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Color Palette View (2 Rows)

private struct ColorPaletteView: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var configService: ConfigService
    @Binding var newColor: Color

    private let colorSize: CGFloat = 20
    private let spacing: CGFloat = 8
    private let maxCustomColors = 4

    // Get last 4 custom colors (most recent)
    private var displayedCustomColors: [CustomColor] {
        let colors = configService.config.customColors
        if colors.count <= maxCustomColors {
            return colors
        }
        return Array(colors.suffix(maxCustomColors))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Row 1: Preset Colors
            HStack(spacing: spacing) {
                ForEach(DrawingColor.allCases) { color in
                    ColorButton(
                        color: Color(nsColor: color.nsColor),
                        isSelected: viewModel.isPresetColorSelected(color),
                        size: colorSize,
                        helpText: color.helpText
                    ) {
                        viewModel.selectPresetColor(color)
                    }
                }
            }

            // Row 2: Custom Colors (4) + Color Picker
            HStack(spacing: spacing) {
                // Custom Colors (up to 4)
                ForEach(displayedCustomColors) { customColor in
                    ColorButton(
                        color: Color(nsColor: customColor.nsColor),
                        isSelected: viewModel.isCustomColorSelected(customColor),
                        size: colorSize,
                        helpText: customColor.helpText
                    ) {
                        viewModel.selectCustomColor(customColor)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            configService.removeCustomColor(customColor)
                        } label: {
                            Label(L10n.delete, systemImage: "trash")
                        }
                    }
                }

                // Empty slots (if less than 4 custom colors)
                ForEach(0..<(maxCustomColors - displayedCustomColors.count), id: \.self) { _ in
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .frame(width: colorSize, height: colorSize)
                }

                // Color Picker
                ZStack {
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                        .frame(width: colorSize, height: colorSize)

                    ColorPicker("", selection: $newColor)
                        .labelsHidden()
                        .scaleEffect(0.8)
                }
                .frame(width: colorSize, height: colorSize)
                .help(L10n.toolbarAddCustomColor)
                .onChange(of: newColor) { newValue in
                    let nsColor = NSColor(newValue)
                    let customColor = CustomColor(color: nsColor)
                    configService.addCustomColor(customColor)
                    viewModel.selectCustomColor(customColor)
                }
            }
        }
    }
}

// MARK: - Color Button

private struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let size: CGFloat
    let helpText: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.15), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .help(helpText)
    }
}
