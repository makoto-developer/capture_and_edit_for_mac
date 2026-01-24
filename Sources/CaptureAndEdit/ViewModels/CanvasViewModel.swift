import Foundation
import AppKit

final class CanvasViewModel: ObservableObject {
    @Published var currentOperation: (any EditOperation)?
    @Published var selectedOperationId: UUID?
    @Published var resizingHandle: ResizeHandle?

    private var startPoint: CGPoint?
    private var dragStartPoint: CGPoint?
    private var isDragging = false
    private var isResizing = false
    var onTextInputRequested: ((CGPoint, DrawingColor, @escaping (String) -> Void) -> Void)?
    var onOperationSelected: ((UUID?) -> Void)?

    func handleMouseDown(at point: CGPoint, tool: DrawingTool, operations: [any EditOperation]) {
        startPoint = point

        if tool == .select {
            // まず、選択されたオブジェクトのリサイズハンドルをチェック
            if let selectedId = selectedOperationId,
               let selectedOp = operations.first(where: { $0.id == selectedId }) {
                let handles = selectedOp.getResizeHandles()
                let handleThreshold: CGFloat = 8.0

                for (handle, handlePoint) in handles {
                    let distance = hypot(point.x - handlePoint.x, point.y - handlePoint.y)
                    if distance <= handleThreshold {
                        resizingHandle = handle
                        isResizing = true
                        print("🔲 Resizing started with handle: \(handle)")
                        return
                    }
                }
            }

            // リサイズハンドルに当たらなかった場合、オブジェクト選択またはドラッグ
            // 後ろから前に検索（新しいオブジェクトが優先）
            for operation in operations.reversed() {
                if operation.contains(point: point) {
                    selectedOperationId = operation.id
                    dragStartPoint = point
                    isDragging = true
                    onOperationSelected?(operation.id)
                    print("🎯 Selected operation: \(operation.id)")
                    return
                }
            }
            // 何も選択されなかった
            selectedOperationId = nil
            onOperationSelected?(nil)
            print("🎯 No operation selected")
        } else {
            // 描画モード：選択を解除
            selectedOperationId = nil
            onOperationSelected?(nil)
        }
    }

    func handleMouseDragged(to point: CGPoint, tool: DrawingTool, color: DrawingColor, shiftPressed: Bool = false) {
        guard let start = startPoint else { return }

        if tool == .select && (isDragging || isResizing) {
            // 選択モード：ドラッグまたはリサイズ中はcurrentOperationを更新しない（ImageDocumentで処理）
            return
        }

        switch tool {
        case .select:
            // 選択モードではオブジェクトは作成しない
            break
        case .pen:
            // Shiftキーが押されている場合は直線を描画
            if shiftPressed {
                currentOperation = LineOperation(
                    startPoint: start,
                    endPoint: point,
                    color: color.nsColor
                )
            } else {
                if let penOp = currentOperation as? PenOperation {
                    currentOperation = penOp.addPoint(point)
                } else {
                    currentOperation = PenOperation(
                        points: [start, point],
                        color: color.nsColor
                    )
                }
            }
        case .line:
            currentOperation = LineOperation(
                startPoint: start,
                endPoint: point,
                color: color.nsColor
            )
        case .rectangle:
            currentOperation = RectangleOperation(
                startPoint: start,
                endPoint: point,
                color: color.nsColor
            )
        case .pixelate:
            currentOperation = PixelateOperation(
                startPoint: start,
                endPoint: point
            )
        case .arrow:
            currentOperation = ArrowOperation(
                startPoint: start,
                endPoint: point,
                color: color.nsColor
            )
        case .text:
            // テキストはクリック時に入力ダイアログを表示
            break
        }
    }

    func getDragOffset(currentPoint: CGPoint) -> CGPoint? {
        guard isDragging, let dragStart = dragStartPoint else { return nil }
        return CGPoint(x: currentPoint.x - dragStart.x, y: currentPoint.y - dragStart.y)
    }

    func handleMouseUp(tool: DrawingTool, color: DrawingColor, completion: @escaping (any EditOperation) -> Void) {
        print("🖱️ handleMouseUp called with tool: \(tool)")

        if tool == .select {
            // 選択モード：ドラッグまたはリサイズを終了
            isDragging = false
            isResizing = false
            resizingHandle = nil
            dragStartPoint = nil
            startPoint = nil
            return
        }

        if tool == .text, let point = startPoint {
            // テキスト入力を要求
            print("📝 Text tool detected, requesting input at \(point)")
            onTextInputRequested?(point, color) { text in
                let operation = TextOperation(
                    position: point,
                    text: text,
                    color: color.nsColor
                )
                completion(operation)
            }
            print("📝 onTextInputRequested called")
        } else if let operation = currentOperation {
            completion(operation)
        }
        currentOperation = nil
        startPoint = nil
    }

    func cancelOperation() {
        currentOperation = nil
        startPoint = nil
        isDragging = false
        isResizing = false
        resizingHandle = nil
        dragStartPoint = nil
        selectedOperationId = nil
    }
}
