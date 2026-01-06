import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: MainViewModel
    @StateObject private var canvasViewModel: CanvasViewModel
    @State private var showHistory = false
    @State private var showLayerPanel = true
    @State private var lastMagnification: CGFloat = 1.0

    init() {
        let vm = CanvasViewModel()
        _canvasViewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Main Content Area
            VStack(spacing: 0) {
                ToolbarView(
                    viewModel: viewModel,
                    showHistory: $showHistory,
                    showLayerPanel: $showLayerPanel
                )

                if viewModel.document.originalImage != nil {
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        CanvasView(
                            document: viewModel.document,
                            canvasViewModel: canvasViewModel,
                            viewModel: viewModel
                        )
                        .frame(
                            width: viewModel.document.originalImage?.size.width ?? 800,
                            height: viewModel.document.originalImage?.size.height ?? 600
                        )
                        .scaleEffect(viewModel.zoomScale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    viewModel.setZoomScale(lastMagnification * value)
                                }
                                .onEnded { value in
                                    lastMagnification = viewModel.zoomScale
                                }
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        Spacer()
                        Text("Capture an image to clipboard to start editing")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // Layer Panel (Right Sidebar)
            if showLayerPanel && viewModel.document.originalImage != nil {
                Divider()

                LayerPanelView(document: viewModel.document)
                    .frame(width: 220)
            }
        }
        .onAppear {
            setupTextInputHandler()
        }
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
    }

    private func setupTextInputHandler() {
        canvasViewModel.onTextInputRequested = { [self] position, color, completion in
            DispatchQueue.main.async {
                self.showTextInputAlert(color: color, completion: completion)
            }
        }
    }

    private func showTextInputAlert(color: DrawingColor, completion: @escaping (String) -> Void) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "テキストを入力"
        alert.informativeText = "画像に追加するテキストを入力してください"
        alert.alertStyle = .informational

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 32))
        textField.placeholderString = "テキストを入力してください"
        textField.isEditable = true
        textField.isSelectable = true
        textField.bezelStyle = .roundedBezel
        textField.drawsBackground = true
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.isBordered = true
        textField.focusRingType = .default
        textField.font = NSFont.systemFont(ofSize: 14)
        alert.accessoryView = textField

        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "キャンセル")

        DispatchQueue.main.async {
            alert.window.level = .modalPanel
            alert.window.makeFirstResponder(textField)

            let response = alert.runModal()

            if response == .alertFirstButtonReturn {
                let text = textField.stringValue
                if !text.isEmpty {
                    completion(text)
                }
            }
        }
    }
}
