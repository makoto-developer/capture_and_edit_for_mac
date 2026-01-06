import SwiftUI

struct LayerPanelView: View {
    @ObservedObject var document: ImageDocument
    @State private var editingLayerId: UUID?
    @State private var editingName: String = ""
    @State private var draggedLayerId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Layers")
                    .font(.headline)

                Spacer()

                Button(action: {
                    document.addLayer()
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                .help("Add Layer")

                Button(action: {
                    if let activeId = document.activeLayerId {
                        document.deleteLayer(withId: activeId)
                    }
                }) {
                    Image(systemName: "minus")
                }
                .buttonStyle(.plain)
                .disabled(document.layers.count <= 1)
                .help("Delete Layer")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Layer List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(document.layers) { layer in
                        LayerRowView(
                            layer: layer,
                            isActive: document.activeLayerId == layer.id,
                            isEditing: editingLayerId == layer.id,
                            editingName: $editingName,
                            onSelect: {
                                document.selectLayer(withId: layer.id)
                            },
                            onToggleVisibility: {
                                document.setLayerVisibility(layer.id, isVisible: !layer.isVisible)
                            },
                            onToggleLock: {
                                document.setLayerLocked(layer.id, isLocked: !layer.isLocked)
                            },
                            onStartEditing: {
                                editingLayerId = layer.id
                                editingName = layer.name
                            },
                            onEndEditing: {
                                if !editingName.isEmpty {
                                    document.renameLayer(layer.id, name: editingName)
                                }
                                editingLayerId = nil
                            }
                        )
                        .onDrag {
                            draggedLayerId = layer.id
                            return NSItemProvider(object: layer.id.uuidString as NSString)
                        }
                        .onDrop(of: [.text], delegate: LayerDropDelegate(
                            document: document,
                            targetLayerId: layer.id,
                            draggedLayerId: $draggedLayerId
                        ))
                    }
                }
            }
            .frame(maxHeight: .infinity)

            Divider()

            // Opacity Slider
            if let activeLayer = document.activeLayer {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Opacity")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(activeLayer.opacity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Slider(
                        value: Binding(
                            get: { activeLayer.opacity },
                            set: { newValue in
                                document.setLayerOpacity(activeLayer.id, opacity: newValue)
                            }
                        ),
                        in: 0...1
                    )
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            Divider()

            // Action Buttons
            HStack(spacing: 8) {
                Button("Merge Visible") {
                    document.mergeVisibleLayers()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .disabled(document.layers.filter { $0.isVisible }.count <= 1)

                Button("Flatten") {
                    document.flattenAllLayers()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .disabled(document.layers.count <= 1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct LayerRowView: View {
    let layer: Layer
    let isActive: Bool
    let isEditing: Bool
    @Binding var editingName: String
    let onSelect: () -> Void
    let onToggleVisibility: () -> Void
    let onToggleLock: () -> Void
    let onStartEditing: () -> Void
    let onEndEditing: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Visibility Toggle
            Button(action: onToggleVisibility) {
                Image(systemName: layer.isVisible ? "eye" : "eye.slash")
                    .foregroundColor(layer.isVisible ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 20)

            // Lock Toggle
            Button(action: onToggleLock) {
                Image(systemName: layer.isLocked ? "lock.fill" : "lock.open")
                    .foregroundColor(layer.isLocked ? .orange : .secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 20)

            // Layer Name
            if isEditing {
                TextField("", text: $editingName, onCommit: onEndEditing)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
            } else {
                Text(layer.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .onTapGesture(count: 2) {
                        onStartEditing()
                    }
            }

            Spacer()

            // Opacity Indicator
            OpacityIndicatorView(opacity: layer.opacity)
                .frame(width: 30, height: 12)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isActive ? Color.accentColor.opacity(0.2) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct OpacityIndicatorView: View {
    let opacity: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))

                Rectangle()
                    .fill(Color.primary.opacity(0.6))
                    .frame(width: geometry.size.width * opacity)
            }
        }
        .cornerRadius(2)
    }
}

struct LayerDropDelegate: DropDelegate {
    let document: ImageDocument
    let targetLayerId: UUID
    @Binding var draggedLayerId: UUID?

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedId = draggedLayerId,
              let fromIndex = document.layers.firstIndex(where: { $0.id == draggedId }),
              let toIndex = document.layers.firstIndex(where: { $0.id == targetLayerId }) else {
            return false
        }

        document.moveLayer(fromIndex: fromIndex, toIndex: toIndex)
        draggedLayerId = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        // ドロップ時のビジュアルフィードバック
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
