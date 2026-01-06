import SwiftUI
import AppKit

struct CanvasView: NSViewRepresentable {
    @ObservedObject var document: ImageDocument
    @ObservedObject var canvasViewModel: CanvasViewModel
    @ObservedObject var viewModel: MainViewModel

    func makeNSView(context: Context) -> NSCanvasView {
        let view = NSCanvasView()
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: NSCanvasView, context: Context) {
        nsView.image = document.originalImage
        nsView.layers = document.layers
        nsView.currentOperation = canvasViewModel.currentOperation
        nsView.selectedOperationId = canvasViewModel.selectedOperationId
        nsView.activeLayerId = document.activeLayerId

        nsView.needsDisplay = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            canvasViewModel: canvasViewModel,
            viewModel: viewModel,
            onOperationCompleted: { operation in
                document.addOperation(operation)
            }
        )
    }

    final class Coordinator: NSObject, NSCanvasViewDelegate {
        let canvasViewModel: CanvasViewModel
        let viewModel: MainViewModel
        let onOperationCompleted: (any EditOperation) -> Void

        init(
            canvasViewModel: CanvasViewModel,
            viewModel: MainViewModel,
            onOperationCompleted: @escaping (any EditOperation) -> Void
        ) {
            self.canvasViewModel = canvasViewModel
            self.viewModel = viewModel
            self.onOperationCompleted = onOperationCompleted
        }

        func canvasView(_ view: NSCanvasView, mouseDownAt point: CGPoint) {
            let tool = viewModel.selectedTool
            let operations = viewModel.document.operations
            canvasViewModel.handleMouseDown(at: point, tool: tool, operations: operations)

            // 選択モードで、リサイズハンドルをクリックした場合
            if tool == .select, canvasViewModel.resizingHandle != nil, let selectedId = canvasViewModel.selectedOperationId {
                viewModel.document.startResizingOperation(withId: selectedId)
            }
            // 選択モードで、オブジェクトが選択された場合、移動を開始
            else if tool == .select, let selectedId = canvasViewModel.selectedOperationId {
                viewModel.document.startMovingOperation(withId: selectedId)
            }
        }

        func canvasView(_ view: NSCanvasView, mouseDraggedTo point: CGPoint) {
            let tool = viewModel.selectedTool
            let color = viewModel.selectedColor

            if tool == .select, let selectedId = canvasViewModel.selectedOperationId {
                // リサイズモード
                if let handle = canvasViewModel.resizingHandle {
                    viewModel.document.resizeOperation(withId: selectedId, handle: handle, to: point)
                }
                // 移動モード
                else if let offset = canvasViewModel.getDragOffset(currentPoint: point) {
                    viewModel.document.moveOperation(withId: selectedId, by: offset)
                }
            } else {
                canvasViewModel.handleMouseDragged(
                    to: point,
                    tool: tool,
                    color: color
                )
            }
        }

        func canvasView(_ view: NSCanvasView, mouseUpAt point: CGPoint) {
            let tool = viewModel.selectedTool
            let color = viewModel.selectedColor

            if tool == .select && canvasViewModel.selectedOperationId != nil {
                // リサイズまたは移動を確定
                if canvasViewModel.resizingHandle != nil {
                    viewModel.document.commitResize()
                } else {
                    viewModel.document.commitMove()
                }
            }

            canvasViewModel.handleMouseUp(tool: tool, color: color) { [self] operation in
                self.onOperationCompleted(operation)
            }
        }
    }
}

protocol NSCanvasViewDelegate: AnyObject {
    func canvasView(_ view: NSCanvasView, mouseDownAt point: CGPoint)
    func canvasView(_ view: NSCanvasView, mouseDraggedTo point: CGPoint)
    func canvasView(_ view: NSCanvasView, mouseUpAt point: CGPoint)
}

final class NSCanvasView: NSView {
    weak var delegate: NSCanvasViewDelegate?

    var image: NSImage?
    var layers: [Layer] = []
    var currentOperation: (any EditOperation)?
    var selectedOperationId: UUID?
    var activeLayerId: UUID?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let context = NSGraphicsContext.current?.cgContext else { return }

        if let image = image {
            let rect = NSRect(origin: .zero, size: image.size)
            image.draw(in: rect)

            // レイヤーを下から上に描画（reversed で配列の最後から描画）
            for layer in layers.reversed() where layer.isVisible {
                context.saveGState()
                context.setAlpha(layer.opacity)

                for operation in layer.operations {
                    operation.draw(in: context)
                }

                context.restoreGState()
            }

            // 現在描画中のオペレーション
            if let current = currentOperation {
                current.draw(in: context)
            }

            // 選択されたオブジェクトのリサイズハンドル（アクティブレイヤーのみ）
            if let selectedId = selectedOperationId,
               let activeId = activeLayerId,
               let activeLayer = layers.first(where: { $0.id == activeId }),
               let selectedOp = activeLayer.operations.first(where: { $0.id == selectedId }) {
                drawResizeHandles(for: selectedOp, in: context)
            }
        }
    }

    private func drawResizeHandles(for operation: any EditOperation, in context: CGContext) {
        let handles = operation.getResizeHandles()
        let handleSize: CGFloat = 8.0

        context.saveGState()

        for (_, point) in handles {
            let handleRect = CGRect(
                x: point.x - handleSize / 2,
                y: point.y - handleSize / 2,
                width: handleSize,
                height: handleSize
            )

            // ハンドルの塗りつぶし（白）
            context.setFillColor(NSColor.white.cgColor)
            context.fill(handleRect)

            // ハンドルの枠線（青）
            context.setStrokeColor(NSColor.blue.cgColor)
            context.setLineWidth(2.0)
            context.stroke(handleRect)
        }

        context.restoreGState()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        delegate?.canvasView(self, mouseDownAt: point)
    }

    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        delegate?.canvasView(self, mouseDraggedTo: point)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        delegate?.canvasView(self, mouseUpAt: point)
        needsDisplay = true
    }
}
