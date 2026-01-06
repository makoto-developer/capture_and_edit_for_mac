import Foundation
import AppKit

struct Layer: Identifiable {
    let id: UUID
    var name: String
    var operations: [any EditOperation]
    var isVisible: Bool
    var isLocked: Bool
    var opacity: CGFloat

    init(
        id: UUID = UUID(),
        name: String,
        operations: [any EditOperation] = [],
        isVisible: Bool = true,
        isLocked: Bool = false,
        opacity: CGFloat = 1.0
    ) {
        self.id = id
        self.name = name
        self.operations = operations
        self.isVisible = isVisible
        self.isLocked = isLocked
        self.opacity = opacity
    }

    func withOperations(_ operations: [any EditOperation]) -> Layer {
        var copy = self
        copy.operations = operations
        return copy
    }

    func addingOperation(_ operation: any EditOperation) -> Layer {
        var copy = self
        copy.operations.append(operation)
        return copy
    }

    func withVisibility(_ isVisible: Bool) -> Layer {
        var copy = self
        copy.isVisible = isVisible
        return copy
    }

    func withLocked(_ isLocked: Bool) -> Layer {
        var copy = self
        copy.isLocked = isLocked
        return copy
    }

    func withOpacity(_ opacity: CGFloat) -> Layer {
        var copy = self
        copy.opacity = max(0, min(1, opacity))
        return copy
    }

    func withName(_ name: String) -> Layer {
        var copy = self
        copy.name = name
        return copy
    }
}
