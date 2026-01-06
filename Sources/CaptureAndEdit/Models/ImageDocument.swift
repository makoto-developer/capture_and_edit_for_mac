import Foundation
import AppKit

final class ImageDocument: ObservableObject {
    @Published private(set) var originalImage: NSImage?
    @Published private(set) var layers: [Layer] = []
    @Published var activeLayerId: UUID?

    private var undoStack: [[Layer]] = []
    private var redoStack: [[Layer]] = []
    private var originalOperationBeingMoved: (any EditOperation)?
    private var movingOperationIndex: Int?
    private var layerCount: Int = 0

    // MARK: - Computed Properties

    var operations: [any EditOperation] {
        activeLayer?.operations ?? []
    }

    var activeLayer: Layer? {
        guard let id = activeLayerId else { return layers.first }
        return layers.first { $0.id == id }
    }

    var activeLayerIndex: Int? {
        guard let id = activeLayerId else { return layers.isEmpty ? nil : 0 }
        return layers.firstIndex { $0.id == id }
    }

    var canUndo: Bool {
        undoStack.count > 1
    }

    var canRedo: Bool {
        !redoStack.isEmpty
    }

    // MARK: - Initialization

    init(image: NSImage? = nil) {
        self.originalImage = image
    }

    // MARK: - Image Management

    func setImage(_ image: NSImage) {
        self.originalImage = image
        self.layerCount = 1
        let defaultLayer = Layer(name: "Layer 1")
        self.layers = [defaultLayer]
        self.activeLayerId = defaultLayer.id
        self.undoStack = [[defaultLayer]]
        self.redoStack = []
    }

    // MARK: - Layer Management

    @discardableResult
    func addLayer(named name: String? = nil) -> UUID {
        layerCount += 1
        let layerName = name ?? "Layer \(layerCount)"
        let newLayer = Layer(name: layerName)

        saveStateForUndo()
        layers.insert(newLayer, at: 0)
        activeLayerId = newLayer.id
        redoStack.removeAll()
        objectWillChange.send()

        return newLayer.id
    }

    func deleteLayer(withId id: UUID) {
        guard layers.count > 1 else { return }
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return }

        saveStateForUndo()
        layers.remove(at: index)

        if activeLayerId == id {
            activeLayerId = layers.first?.id
        }
        redoStack.removeAll()
        objectWillChange.send()
    }

    func duplicateLayer(withId id: UUID) -> UUID? {
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return nil }
        let original = layers[index]

        layerCount += 1
        let duplicate = Layer(
            name: "\(original.name) copy",
            operations: original.operations,
            isVisible: original.isVisible,
            isLocked: original.isLocked,
            opacity: original.opacity
        )

        saveStateForUndo()
        layers.insert(duplicate, at: index)
        activeLayerId = duplicate.id
        redoStack.removeAll()
        objectWillChange.send()

        return duplicate.id
    }

    func moveLayer(fromIndex: Int, toIndex: Int) {
        guard fromIndex != toIndex,
              fromIndex >= 0, fromIndex < layers.count,
              toIndex >= 0, toIndex < layers.count else { return }

        saveStateForUndo()
        let layer = layers.remove(at: fromIndex)
        layers.insert(layer, at: toIndex)
        redoStack.removeAll()
        objectWillChange.send()
    }

    func setLayerVisibility(_ id: UUID, isVisible: Bool) {
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return }
        saveStateForUndo()
        layers[index] = layers[index].withVisibility(isVisible)
        redoStack.removeAll()
        objectWillChange.send()
    }

    func setLayerLocked(_ id: UUID, isLocked: Bool) {
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return }
        saveStateForUndo()
        layers[index] = layers[index].withLocked(isLocked)
        redoStack.removeAll()
        objectWillChange.send()
    }

    func setLayerOpacity(_ id: UUID, opacity: CGFloat) {
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return }
        saveStateForUndo()
        layers[index] = layers[index].withOpacity(opacity)
        redoStack.removeAll()
        objectWillChange.send()
    }

    func renameLayer(_ id: UUID, name: String) {
        guard let index = layers.firstIndex(where: { $0.id == id }) else { return }
        saveStateForUndo()
        layers[index] = layers[index].withName(name)
        redoStack.removeAll()
        objectWillChange.send()
    }

    func selectLayer(withId id: UUID) {
        guard layers.contains(where: { $0.id == id }) else { return }
        activeLayerId = id
    }

    func mergeVisibleLayers() {
        let visibleLayers = layers.filter { $0.isVisible }
        guard visibleLayers.count > 1 else { return }

        saveStateForUndo()

        var mergedOperations: [any EditOperation] = []
        for layer in visibleLayers.reversed() {
            mergedOperations.append(contentsOf: layer.operations)
        }

        layerCount += 1
        let mergedLayer = Layer(name: "Merged Layer", operations: mergedOperations)

        layers.removeAll { $0.isVisible }
        layers.insert(mergedLayer, at: 0)
        activeLayerId = mergedLayer.id
        redoStack.removeAll()
        objectWillChange.send()
    }

    func flattenAllLayers() {
        guard layers.count > 1 else { return }

        saveStateForUndo()

        var allOperations: [any EditOperation] = []
        for layer in layers.reversed() where layer.isVisible {
            allOperations.append(contentsOf: layer.operations)
        }

        let flattenedLayer = Layer(name: "Background", operations: allOperations)
        layers = [flattenedLayer]
        activeLayerId = flattenedLayer.id
        redoStack.removeAll()
        objectWillChange.send()
    }

    // MARK: - Operation Management

    func addOperation(_ operation: any EditOperation) {
        guard let index = activeLayerIndex else { return }
        guard !layers[index].isLocked else { return }

        saveStateForUndo()
        layers[index] = layers[index].addingOperation(operation)
        redoStack.removeAll()
        objectWillChange.send()
    }

    func startMovingOperation(withId id: UUID) {
        guard let layerIndex = activeLayerIndex else { return }
        guard !layers[layerIndex].isLocked else { return }
        guard let opIndex = layers[layerIndex].operations.firstIndex(where: { $0.id == id }) else { return }

        originalOperationBeingMoved = layers[layerIndex].operations[opIndex]
        movingOperationIndex = opIndex
    }

    func moveOperation(withId id: UUID, by delta: CGPoint) {
        guard let layerIndex = activeLayerIndex,
              let opIndex = movingOperationIndex,
              let original = originalOperationBeingMoved else { return }

        let movedOperation = original.offset(by: delta)
        var ops = layers[layerIndex].operations
        ops[opIndex] = movedOperation
        layers[layerIndex] = layers[layerIndex].withOperations(ops)
        objectWillChange.send()
    }

    func commitMove() {
        originalOperationBeingMoved = nil
        movingOperationIndex = nil
        saveStateForUndo()
        redoStack.removeAll()
        objectWillChange.send()
    }

    func cancelMove() {
        if let layerIndex = activeLayerIndex,
           let opIndex = movingOperationIndex,
           let original = originalOperationBeingMoved {
            var ops = layers[layerIndex].operations
            ops[opIndex] = original
            layers[layerIndex] = layers[layerIndex].withOperations(ops)
        }
        originalOperationBeingMoved = nil
        movingOperationIndex = nil
    }

    func startResizingOperation(withId id: UUID) {
        guard let layerIndex = activeLayerIndex else { return }
        guard !layers[layerIndex].isLocked else { return }
        guard let opIndex = layers[layerIndex].operations.firstIndex(where: { $0.id == id }) else { return }

        originalOperationBeingMoved = layers[layerIndex].operations[opIndex]
        movingOperationIndex = opIndex
    }

    func resizeOperation(withId id: UUID, handle: ResizeHandle, to point: CGPoint) {
        guard let layerIndex = activeLayerIndex,
              let opIndex = movingOperationIndex,
              let original = originalOperationBeingMoved else { return }

        let resizedOperation = original.resize(handle: handle, to: point)
        var ops = layers[layerIndex].operations
        ops[opIndex] = resizedOperation
        layers[layerIndex] = layers[layerIndex].withOperations(ops)
        objectWillChange.send()
    }

    func commitResize() {
        originalOperationBeingMoved = nil
        movingOperationIndex = nil
        saveStateForUndo()
        redoStack.removeAll()
        objectWillChange.send()
    }

    func cancelResize() {
        if let layerIndex = activeLayerIndex,
           let opIndex = movingOperationIndex,
           let original = originalOperationBeingMoved {
            var ops = layers[layerIndex].operations
            ops[opIndex] = original
            layers[layerIndex] = layers[layerIndex].withOperations(ops)
        }
        originalOperationBeingMoved = nil
        movingOperationIndex = nil
    }

    // MARK: - Undo/Redo

    private func saveStateForUndo() {
        undoStack.append(layers)
        print("📝 saveState: undoStack=\(undoStack.count), ops=\(layers.first?.operations.count ?? 0)")
    }

    func undo() {
        print("⏪ UNDO: undoStack=\(undoStack.count), redoStack=\(redoStack.count), ops=\(layers.first?.operations.count ?? 0)")

        guard undoStack.count > 1 else {
            print("❌ UNDO: stack too small")
            return
        }

        // 現在の状態をredoStackに保存
        redoStack.append(layers)

        // undoStackから前の状態を取り出して復元
        undoStack.removeLast()
        if let previousState = undoStack.last {
            layers = previousState
            if let activeId = activeLayerId, !layers.contains(where: { $0.id == activeId }) {
                activeLayerId = layers.first?.id
            }
        }

        print("⏪ UNDO done: undoStack=\(undoStack.count), redoStack=\(redoStack.count), ops=\(layers.first?.operations.count ?? 0)")
        objectWillChange.send()
    }

    func redo() {
        print("⏩ REDO: undoStack=\(undoStack.count), redoStack=\(redoStack.count), ops=\(layers.first?.operations.count ?? 0)")

        guard let nextState = redoStack.popLast() else {
            print("❌ REDO: stack empty")
            return
        }

        undoStack.append(nextState)
        layers = nextState

        if let activeId = activeLayerId, !layers.contains(where: { $0.id == activeId }) {
            activeLayerId = layers.first?.id
        }

        print("⏩ REDO done: undoStack=\(undoStack.count), redoStack=\(redoStack.count), ops=\(layers.first?.operations.count ?? 0)")
        objectWillChange.send()
    }

    func clear() {
        layerCount = 1
        let defaultLayer = Layer(name: "Layer 1")
        layers = [defaultLayer]
        activeLayerId = defaultLayer.id
        undoStack = [[defaultLayer]]
        redoStack = []
    }

    // MARK: - Rendering

    func renderImage() -> NSImage? {
        guard let original = originalImage else { return nil }

        let size = original.size
        let resultImage = NSImage(size: size)

        resultImage.lockFocus()
        original.draw(in: NSRect(origin: .zero, size: size))

        if let context = NSGraphicsContext.current?.cgContext {
            for layer in layers.reversed() where layer.isVisible {
                context.saveGState()
                context.setAlpha(layer.opacity)
                for operation in layer.operations {
                    operation.draw(in: context)
                }
                context.restoreGState()
            }
        }

        resultImage.unlockFocus()
        return resultImage
    }
}
