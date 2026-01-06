import XCTest
import AppKit
@testable import CaptureAndEdit

final class LayerTests: XCTestCase {

    // MARK: - Layer Model Tests

    func testLayerInitialization() {
        let layer = Layer(name: "Test Layer")

        XCTAssertNotNil(layer.id)
        XCTAssertEqual(layer.name, "Test Layer")
        XCTAssertTrue(layer.operations.isEmpty)
        XCTAssertTrue(layer.isVisible)
        XCTAssertFalse(layer.isLocked)
        XCTAssertEqual(layer.opacity, 1.0)
    }

    func testLayerWithOperations() {
        let layer = Layer(name: "Test")
        let operation = LineOperation(
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )

        let newLayer = layer.addingOperation(operation)

        XCTAssertEqual(newLayer.operations.count, 1)
        XCTAssertEqual(layer.id, newLayer.id)
    }

    func testLayerWithVisibility() {
        let layer = Layer(name: "Test")
        let hiddenLayer = layer.withVisibility(false)

        XCTAssertFalse(hiddenLayer.isVisible)
        XCTAssertEqual(layer.id, hiddenLayer.id)
    }

    func testLayerWithLocked() {
        let layer = Layer(name: "Test")
        let lockedLayer = layer.withLocked(true)

        XCTAssertTrue(lockedLayer.isLocked)
        XCTAssertEqual(layer.id, lockedLayer.id)
    }

    func testLayerWithOpacity() {
        let layer = Layer(name: "Test")
        let transparentLayer = layer.withOpacity(0.5)

        XCTAssertEqual(transparentLayer.opacity, 0.5)
        XCTAssertEqual(layer.id, transparentLayer.id)
    }

    func testLayerOpacityClamping() {
        let layer = Layer(name: "Test")

        let overflowLayer = layer.withOpacity(1.5)
        XCTAssertEqual(overflowLayer.opacity, 1.0)

        let underflowLayer = layer.withOpacity(-0.5)
        XCTAssertEqual(underflowLayer.opacity, 0.0)
    }

    func testLayerWithName() {
        let layer = Layer(name: "Original")
        let renamedLayer = layer.withName("Renamed")

        XCTAssertEqual(renamedLayer.name, "Renamed")
        XCTAssertEqual(layer.id, renamedLayer.id)
    }

    // MARK: - ImageDocument Layer Tests

    func testDocumentInitialLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        XCTAssertEqual(document.layers.count, 1)
        XCTAssertEqual(document.layers.first?.name, "Layer 1")
        XCTAssertNotNil(document.activeLayerId)
    }

    func testDocumentAddLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let newLayerId = document.addLayer(named: "New Layer")

        XCTAssertEqual(document.layers.count, 2)
        XCTAssertEqual(document.activeLayerId, newLayerId)
        XCTAssertEqual(document.layers.first?.name, "New Layer")
    }

    func testDocumentDeleteLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)
        document.addLayer(named: "Layer 2")

        let layerToDelete = document.layers.first!.id
        document.deleteLayer(withId: layerToDelete)

        XCTAssertEqual(document.layers.count, 1)
        XCTAssertNotEqual(document.layers.first?.id, layerToDelete)
    }

    func testDocumentCannotDeleteLastLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let onlyLayerId = document.layers.first!.id
        document.deleteLayer(withId: onlyLayerId)

        XCTAssertEqual(document.layers.count, 1)
    }

    func testDocumentMoveLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)
        document.addLayer(named: "Layer 2")
        document.addLayer(named: "Layer 3")

        let layer3Id = document.layers[0].id
        document.moveLayer(fromIndex: 0, toIndex: 2)

        XCTAssertEqual(document.layers[2].id, layer3Id)
    }

    func testDocumentSetLayerVisibility() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let layerId = document.layers.first!.id
        document.setLayerVisibility(layerId, isVisible: false)

        XCTAssertFalse(document.layers.first!.isVisible)
    }

    func testDocumentSetLayerOpacity() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let layerId = document.layers.first!.id
        document.setLayerOpacity(layerId, opacity: 0.5)

        XCTAssertEqual(document.layers.first!.opacity, 0.5)
    }

    func testDocumentRenameLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let layerId = document.layers.first!.id
        document.renameLayer(layerId, name: "Renamed Layer")

        XCTAssertEqual(document.layers.first!.name, "Renamed Layer")
    }

    func testDocumentSelectLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)
        document.addLayer(named: "Layer 2")

        let layer1Id = document.layers[1].id
        document.selectLayer(withId: layer1Id)

        XCTAssertEqual(document.activeLayerId, layer1Id)
    }

    func testDocumentAddOperationToActiveLayer() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let operation = LineOperation(
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )
        document.addOperation(operation)

        XCTAssertEqual(document.activeLayer?.operations.count, 1)
    }

    func testDocumentLockedLayerPreventsAddOperation() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let layerId = document.layers.first!.id
        document.setLayerLocked(layerId, isLocked: true)

        let operation = LineOperation(
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 100, y: 100),
            color: .red
        )
        document.addOperation(operation)

        XCTAssertTrue(document.activeLayer?.operations.isEmpty ?? false)
    }

    func testDocumentUndoRedo() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        document.addLayer(named: "Layer 2")
        XCTAssertEqual(document.layers.count, 2)

        document.undo()
        XCTAssertEqual(document.layers.count, 1)

        document.redo()
        XCTAssertEqual(document.layers.count, 2)
    }

    func testDocumentFlattenAllLayers() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        let op1 = LineOperation(startPoint: .zero, endPoint: CGPoint(x: 50, y: 50), color: .red)
        document.addOperation(op1)

        document.addLayer(named: "Layer 2")
        let op2 = LineOperation(startPoint: CGPoint(x: 50, y: 50), endPoint: CGPoint(x: 100, y: 100), color: .blue)
        document.addOperation(op2)

        document.flattenAllLayers()

        XCTAssertEqual(document.layers.count, 1)
        XCTAssertEqual(document.layers.first?.name, "Background")
        XCTAssertEqual(document.layers.first?.operations.count, 2)
    }

    func testDocumentClear() {
        let document = ImageDocument()
        let image = NSImage(size: NSSize(width: 100, height: 100))
        document.setImage(image)

        document.addLayer(named: "Layer 2")
        document.addLayer(named: "Layer 3")

        document.clear()

        XCTAssertEqual(document.layers.count, 1)
        XCTAssertEqual(document.layers.first?.name, "Layer 1")
    }
}
