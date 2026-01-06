import Foundation
import AppKit

enum ResizeHandle {
    case topLeft, top, topRight
    case left, right
    case bottomLeft, bottom, bottomRight
}

protocol EditOperation: Identifiable {
    var id: UUID { get }
    func draw(in context: CGContext)
    func contains(point: CGPoint) -> Bool
    func offset(by delta: CGPoint) -> any EditOperation
    func getResizeHandles() -> [ResizeHandle: CGPoint]
    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation
}

struct LineOperation: EditOperation {
    let id: UUID
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: NSColor
    let lineWidth: CGFloat

    init(id: UUID = UUID(), startPoint: CGPoint, endPoint: CGPoint, color: NSColor, lineWidth: CGFloat = 3.0) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.color = color
        self.lineWidth = lineWidth
    }

    func draw(in context: CGContext) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)

        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()

        context.restoreGState()
    }

    func contains(point: CGPoint) -> Bool {
        let threshold: CGFloat = 10.0
        let distance = distanceFromPointToLineSegment(point: point, start: startPoint, end: endPoint)
        return distance <= threshold
    }

    func offset(by delta: CGPoint) -> any EditOperation {
        return LineOperation(
            id: id,
            startPoint: CGPoint(x: startPoint.x + delta.x, y: startPoint.y + delta.y),
            endPoint: CGPoint(x: endPoint.x + delta.x, y: endPoint.y + delta.y),
            color: color,
            lineWidth: lineWidth
        )
    }

    func getResizeHandles() -> [ResizeHandle: CGPoint] {
        // 線の両端をリサイズハンドルとして返す
        return [
            .topLeft: startPoint,
            .bottomRight: endPoint
        ]
    }

    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation {
        switch handle {
        case .topLeft:
            return LineOperation(id: id, startPoint: point, endPoint: endPoint, color: color, lineWidth: lineWidth)
        case .bottomRight:
            return LineOperation(id: id, startPoint: startPoint, endPoint: point, color: color, lineWidth: lineWidth)
        default:
            return self
        }
    }

    private func distanceFromPointToLineSegment(point: CGPoint, start: CGPoint, end: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy

        if lengthSquared == 0 {
            return hypot(point.x - start.x, point.y - start.y)
        }

        let t = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared))
        let projectionX = start.x + t * dx
        let projectionY = start.y + t * dy

        return hypot(point.x - projectionX, point.y - projectionY)
    }
}

struct RectangleOperation: EditOperation {
    let id: UUID
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: NSColor
    let lineWidth: CGFloat

    init(id: UUID = UUID(), startPoint: CGPoint, endPoint: CGPoint, color: NSColor, lineWidth: CGFloat = 3.0) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.color = color
        self.lineWidth = lineWidth
    }

    func draw(in context: CGContext) {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )

        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.stroke(rect)
        context.restoreGState()
    }

    func contains(point: CGPoint) -> Bool {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        let threshold: CGFloat = 10.0
        let expandedRect = rect.insetBy(dx: -threshold, dy: -threshold)
        return expandedRect.contains(point) && !rect.insetBy(dx: threshold, dy: threshold).contains(point)
    }

    func offset(by delta: CGPoint) -> any EditOperation {
        return RectangleOperation(
            id: id,
            startPoint: CGPoint(x: startPoint.x + delta.x, y: startPoint.y + delta.y),
            endPoint: CGPoint(x: endPoint.x + delta.x, y: endPoint.y + delta.y),
            color: color,
            lineWidth: lineWidth
        )
    }

    func getResizeHandles() -> [ResizeHandle: CGPoint] {
        let minX = min(startPoint.x, endPoint.x)
        let maxX = max(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let maxY = max(startPoint.y, endPoint.y)
        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2

        return [
            .topLeft: CGPoint(x: minX, y: maxY),
            .top: CGPoint(x: centerX, y: maxY),
            .topRight: CGPoint(x: maxX, y: maxY),
            .left: CGPoint(x: minX, y: centerY),
            .right: CGPoint(x: maxX, y: centerY),
            .bottomLeft: CGPoint(x: minX, y: minY),
            .bottom: CGPoint(x: centerX, y: minY),
            .bottomRight: CGPoint(x: maxX, y: minY)
        ]
    }

    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation {
        let minX = min(startPoint.x, endPoint.x)
        let maxX = max(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let maxY = max(startPoint.y, endPoint.y)

        var newStartPoint = startPoint
        var newEndPoint = endPoint

        switch handle {
        case .topLeft:
            newStartPoint = CGPoint(x: point.x, y: minY)
            newEndPoint = CGPoint(x: maxX, y: point.y)
        case .top:
            newStartPoint = CGPoint(x: minX, y: minY)
            newEndPoint = CGPoint(x: maxX, y: point.y)
        case .topRight:
            newStartPoint = CGPoint(x: minX, y: minY)
            newEndPoint = CGPoint(x: point.x, y: point.y)
        case .left:
            newStartPoint = CGPoint(x: point.x, y: minY)
            newEndPoint = CGPoint(x: maxX, y: maxY)
        case .right:
            newStartPoint = CGPoint(x: minX, y: minY)
            newEndPoint = CGPoint(x: point.x, y: maxY)
        case .bottomLeft:
            newStartPoint = CGPoint(x: point.x, y: point.y)
            newEndPoint = CGPoint(x: maxX, y: maxY)
        case .bottom:
            newStartPoint = CGPoint(x: minX, y: point.y)
            newEndPoint = CGPoint(x: maxX, y: maxY)
        case .bottomRight:
            newStartPoint = CGPoint(x: minX, y: maxY)
            newEndPoint = CGPoint(x: point.x, y: point.y)
        }

        return RectangleOperation(
            id: id,
            startPoint: newStartPoint,
            endPoint: newEndPoint,
            color: color,
            lineWidth: lineWidth
        )
    }
}

struct PixelateOperation: EditOperation {
    let id: UUID
    let startPoint: CGPoint
    let endPoint: CGPoint

    init(id: UUID = UUID(), startPoint: CGPoint, endPoint: CGPoint) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    func draw(in context: CGContext) {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )

        context.saveGState()
        context.setFillColor(NSColor.black.cgColor)
        context.fill(rect)
        context.restoreGState()
    }

    func contains(point: CGPoint) -> Bool {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        return rect.contains(point)
    }

    func offset(by delta: CGPoint) -> any EditOperation {
        return PixelateOperation(
            id: id,
            startPoint: CGPoint(x: startPoint.x + delta.x, y: startPoint.y + delta.y),
            endPoint: CGPoint(x: endPoint.x + delta.x, y: endPoint.y + delta.y)
        )
    }

    func getResizeHandles() -> [ResizeHandle: CGPoint] {
        let minX = min(startPoint.x, endPoint.x)
        let maxX = max(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let maxY = max(startPoint.y, endPoint.y)
        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2

        return [
            .topLeft: CGPoint(x: minX, y: maxY),
            .top: CGPoint(x: centerX, y: maxY),
            .topRight: CGPoint(x: maxX, y: maxY),
            .left: CGPoint(x: minX, y: centerY),
            .right: CGPoint(x: maxX, y: centerY),
            .bottomLeft: CGPoint(x: minX, y: minY),
            .bottom: CGPoint(x: centerX, y: minY),
            .bottomRight: CGPoint(x: maxX, y: minY)
        ]
    }

    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation {
        let minX = min(startPoint.x, endPoint.x)
        let maxX = max(startPoint.x, endPoint.x)
        let minY = min(startPoint.y, endPoint.y)
        let maxY = max(startPoint.y, endPoint.y)

        var newStartPoint = startPoint
        var newEndPoint = endPoint

        switch handle {
        case .topLeft:
            newStartPoint = CGPoint(x: point.x, y: minY)
            newEndPoint = CGPoint(x: maxX, y: point.y)
        case .top:
            newStartPoint = CGPoint(x: minX, y: minY)
            newEndPoint = CGPoint(x: maxX, y: point.y)
        case .topRight:
            newStartPoint = CGPoint(x: minX, y: minY)
            newEndPoint = CGPoint(x: point.x, y: point.y)
        case .left:
            newStartPoint = CGPoint(x: point.x, y: minY)
            newEndPoint = CGPoint(x: maxX, y: maxY)
        case .right:
            newStartPoint = CGPoint(x: minX, y: minY)
            newEndPoint = CGPoint(x: point.x, y: maxY)
        case .bottomLeft:
            newStartPoint = CGPoint(x: point.x, y: point.y)
            newEndPoint = CGPoint(x: maxX, y: maxY)
        case .bottom:
            newStartPoint = CGPoint(x: minX, y: point.y)
            newEndPoint = CGPoint(x: maxX, y: maxY)
        case .bottomRight:
            newStartPoint = CGPoint(x: minX, y: maxY)
            newEndPoint = CGPoint(x: point.x, y: point.y)
        }

        return PixelateOperation(
            id: id,
            startPoint: newStartPoint,
            endPoint: newEndPoint
        )
    }
}

struct ArrowOperation: EditOperation {
    let id: UUID
    let startPoint: CGPoint
    let endPoint: CGPoint
    let color: NSColor
    let lineWidth: CGFloat

    init(id: UUID = UUID(), startPoint: CGPoint, endPoint: CGPoint, color: NSColor, lineWidth: CGFloat = 3.0) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.color = color
        self.lineWidth = lineWidth
    }

    func draw(in context: CGContext) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)

        // 矢印の線を描画
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()

        // 矢印の頭を描画
        let arrowHeadLength: CGFloat = 15.0
        let arrowHeadAngle: CGFloat = .pi / 6.0

        let angle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)

        let arrowPoint1 = CGPoint(
            x: endPoint.x - arrowHeadLength * cos(angle - arrowHeadAngle),
            y: endPoint.y - arrowHeadLength * sin(angle - arrowHeadAngle)
        )

        let arrowPoint2 = CGPoint(
            x: endPoint.x - arrowHeadLength * cos(angle + arrowHeadAngle),
            y: endPoint.y - arrowHeadLength * sin(angle + arrowHeadAngle)
        )

        context.move(to: endPoint)
        context.addLine(to: arrowPoint1)
        context.move(to: endPoint)
        context.addLine(to: arrowPoint2)
        context.strokePath()

        context.restoreGState()
    }

    func contains(point: CGPoint) -> Bool {
        let threshold: CGFloat = 10.0
        let distance = distanceFromPointToLineSegment(point: point, start: startPoint, end: endPoint)
        return distance <= threshold
    }

    func offset(by delta: CGPoint) -> any EditOperation {
        return ArrowOperation(
            id: id,
            startPoint: CGPoint(x: startPoint.x + delta.x, y: startPoint.y + delta.y),
            endPoint: CGPoint(x: endPoint.x + delta.x, y: endPoint.y + delta.y),
            color: color,
            lineWidth: lineWidth
        )
    }

    func getResizeHandles() -> [ResizeHandle: CGPoint] {
        return [
            .topLeft: startPoint,
            .bottomRight: endPoint
        ]
    }

    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation {
        switch handle {
        case .topLeft:
            return ArrowOperation(id: id, startPoint: point, endPoint: endPoint, color: color, lineWidth: lineWidth)
        case .bottomRight:
            return ArrowOperation(id: id, startPoint: startPoint, endPoint: point, color: color, lineWidth: lineWidth)
        default:
            return self
        }
    }

    private func distanceFromPointToLineSegment(point: CGPoint, start: CGPoint, end: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy

        if lengthSquared == 0 {
            return hypot(point.x - start.x, point.y - start.y)
        }

        let t = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared))
        let projectionX = start.x + t * dx
        let projectionY = start.y + t * dy

        return hypot(point.x - projectionX, point.y - projectionY)
    }
}

struct TextOperation: EditOperation {
    let id: UUID
    let position: CGPoint
    let text: String
    let color: NSColor
    let fontSize: CGFloat

    init(id: UUID = UUID(), position: CGPoint, text: String, color: NSColor, fontSize: CGFloat = 16.0) {
        self.id = id
        self.position = position
        self.text = text
        self.color = color
        self.fontSize = fontSize
    }

    func draw(in context: CGContext) {
        context.saveGState()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: color
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)

        context.textPosition = position
        CTLineDraw(line, context)

        context.restoreGState()
    }

    func contains(point: CGPoint) -> Bool {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: fontSize, weight: .medium)
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()

        let textRect = CGRect(
            x: position.x,
            y: position.y - textSize.height,
            width: textSize.width,
            height: textSize.height
        )

        return textRect.contains(point)
    }

    func offset(by delta: CGPoint) -> any EditOperation {
        return TextOperation(
            id: id,
            position: CGPoint(x: position.x + delta.x, y: position.y + delta.y),
            text: text,
            color: color,
            fontSize: fontSize
        )
    }

    func getResizeHandles() -> [ResizeHandle: CGPoint] {
        // テキストはリサイズハンドルを持たない
        return [:]
    }

    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation {
        // テキストはリサイズしない
        return self
    }
}

struct PenOperation: EditOperation {
    let id: UUID
    let points: [CGPoint]
    let color: NSColor
    let lineWidth: CGFloat

    init(id: UUID = UUID(), points: [CGPoint], color: NSColor, lineWidth: CGFloat = 3.0) {
        self.id = id
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }

    func draw(in context: CGContext) {
        guard points.count >= 2 else { return }

        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        context.move(to: points[0])
        for index in 1..<points.count {
            context.addLine(to: points[index])
        }
        context.strokePath()

        context.restoreGState()
    }

    func contains(point: CGPoint) -> Bool {
        let threshold: CGFloat = 10.0

        for index in 0..<(points.count - 1) {
            let distance = distanceFromPointToLineSegment(
                point: point,
                start: points[index],
                end: points[index + 1]
            )
            if distance <= threshold {
                return true
            }
        }
        return false
    }

    func offset(by delta: CGPoint) -> any EditOperation {
        let newPoints = points.map { CGPoint(x: $0.x + delta.x, y: $0.y + delta.y) }
        return PenOperation(
            id: id,
            points: newPoints,
            color: color,
            lineWidth: lineWidth
        )
    }

    func getResizeHandles() -> [ResizeHandle: CGPoint] {
        guard !points.isEmpty else { return [:] }
        let boundingRect = calculateBoundingRect()
        let centerX = boundingRect.midX
        let centerY = boundingRect.midY

        return [
            .topLeft: CGPoint(x: boundingRect.minX, y: boundingRect.maxY),
            .top: CGPoint(x: centerX, y: boundingRect.maxY),
            .topRight: CGPoint(x: boundingRect.maxX, y: boundingRect.maxY),
            .left: CGPoint(x: boundingRect.minX, y: centerY),
            .right: CGPoint(x: boundingRect.maxX, y: centerY),
            .bottomLeft: CGPoint(x: boundingRect.minX, y: boundingRect.minY),
            .bottom: CGPoint(x: centerX, y: boundingRect.minY),
            .bottomRight: CGPoint(x: boundingRect.maxX, y: boundingRect.minY)
        ]
    }

    func resize(handle: ResizeHandle, to point: CGPoint) -> any EditOperation {
        guard !points.isEmpty else { return self }

        let oldRect = calculateBoundingRect()
        guard oldRect.width > 0, oldRect.height > 0 else { return self }

        var newRect = oldRect

        switch handle {
        case .topLeft:
            newRect = CGRect(x: point.x, y: oldRect.minY, width: oldRect.maxX - point.x, height: point.y - oldRect.minY)
        case .top:
            newRect = CGRect(x: oldRect.minX, y: oldRect.minY, width: oldRect.width, height: point.y - oldRect.minY)
        case .topRight:
            newRect = CGRect(x: oldRect.minX, y: oldRect.minY, width: point.x - oldRect.minX, height: point.y - oldRect.minY)
        case .left:
            newRect = CGRect(x: point.x, y: oldRect.minY, width: oldRect.maxX - point.x, height: oldRect.height)
        case .right:
            newRect = CGRect(x: oldRect.minX, y: oldRect.minY, width: point.x - oldRect.minX, height: oldRect.height)
        case .bottomLeft:
            newRect = CGRect(x: point.x, y: point.y, width: oldRect.maxX - point.x, height: oldRect.maxY - point.y)
        case .bottom:
            newRect = CGRect(x: oldRect.minX, y: point.y, width: oldRect.width, height: oldRect.maxY - point.y)
        case .bottomRight:
            newRect = CGRect(x: oldRect.minX, y: point.y, width: point.x - oldRect.minX, height: oldRect.maxY - point.y)
        }

        guard newRect.width > 0, newRect.height > 0 else { return self }

        let scaleX = newRect.width / oldRect.width
        let scaleY = newRect.height / oldRect.height

        let newPoints = points.map { p -> CGPoint in
            let relativeX = (p.x - oldRect.minX) * scaleX
            let relativeY = (p.y - oldRect.minY) * scaleY
            return CGPoint(x: newRect.minX + relativeX, y: newRect.minY + relativeY)
        }

        return PenOperation(id: id, points: newPoints, color: color, lineWidth: lineWidth)
    }

    private func calculateBoundingRect() -> CGRect {
        guard !points.isEmpty else { return .zero }

        var minX = CGFloat.infinity
        var maxX = -CGFloat.infinity
        var minY = CGFloat.infinity
        var maxY = -CGFloat.infinity

        for point in points {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func distanceFromPointToLineSegment(point: CGPoint, start: CGPoint, end: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy

        if lengthSquared == 0 {
            return hypot(point.x - start.x, point.y - start.y)
        }

        let t = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared))
        let projectionX = start.x + t * dx
        let projectionY = start.y + t * dy

        return hypot(point.x - projectionX, point.y - projectionY)
    }

    func addPoint(_ point: CGPoint) -> PenOperation {
        var newPoints = points
        newPoints.append(point)
        return PenOperation(id: id, points: newPoints, color: color, lineWidth: lineWidth)
    }
}
