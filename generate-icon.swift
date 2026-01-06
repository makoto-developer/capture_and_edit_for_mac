#!/usr/bin/env swift

import AppKit
import CoreGraphics

// アイコンを生成する関数
func generateIcon(size: CGSize) -> NSImage {
    let image = NSImage(size: size)

    image.lockFocus()

    // 背景のグラデーション（青から水色）
    let gradient = NSGradient(colors: [
        NSColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
    ])
    let rect = NSRect(origin: .zero, size: size)
    gradient?.draw(in: rect, angle: -45)

    // 角丸の四角形（写真フレームのイメージ）
    let cornerRadius = size.width * 0.15
    let frameRect = rect.insetBy(dx: size.width * 0.15, dy: size.height * 0.15)
    let framePath = NSBezierPath(roundedRect: frameRect, xRadius: cornerRadius * 0.5, yRadius: cornerRadius * 0.5)

    // 白い枠
    NSColor.white.setStroke()
    framePath.lineWidth = size.width * 0.08
    framePath.stroke()

    // 鉛筆アイコン（編集のイメージ）
    let pencilSize = size.width * 0.35
    let pencilRect = NSRect(
        x: size.width * 0.55,
        y: size.height * 0.1,
        width: pencilSize,
        height: pencilSize
    )

    // 鉛筆の背景（白い円）
    let circlePath = NSBezierPath(ovalIn: pencilRect.insetBy(dx: -size.width * 0.05, dy: -size.height * 0.05))
    NSColor.white.setFill()
    circlePath.fill()

    // 鉛筆を描画（簡易版）
    let pencilPath = NSBezierPath()
    let pencilX = pencilRect.midX
    let pencilY = pencilRect.midY
    let pencilLen = pencilSize * 0.4

    // 鉛筆の本体
    pencilPath.move(to: NSPoint(x: pencilX - pencilLen * 0.3, y: pencilY + pencilLen * 0.3))
    pencilPath.line(to: NSPoint(x: pencilX + pencilLen * 0.3, y: pencilY - pencilLen * 0.3))

    NSColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0).setStroke()
    pencilPath.lineWidth = size.width * 0.06
    pencilPath.lineCapStyle = .round
    pencilPath.stroke()

    // 鉛筆の先
    let tipPath = NSBezierPath()
    tipPath.move(to: NSPoint(x: pencilX + pencilLen * 0.3, y: pencilY - pencilLen * 0.3))
    tipPath.line(to: NSPoint(x: pencilX + pencilLen * 0.45, y: pencilY - pencilLen * 0.45))

    NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).setStroke()
    tipPath.lineWidth = size.width * 0.04
    tipPath.lineCapStyle = .round
    tipPath.stroke()

    image.unlockFocus()

    return image
}

// PNG画像として保存
func savePNG(image: NSImage, size: Int, path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for size \(size)")
        return
    }

    try? pngData.write(to: URL(fileURLWithPath: path))
    print("Created: \(path)")
}

// メイン処理
let sizes = [16, 32, 64, 128, 256, 512, 1024]
let iconsetPath = "AppIcon.iconset"

// iconsetディレクトリを作成
try? FileManager.default.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

for size in sizes {
    let image = generateIcon(size: CGSize(width: size, height: size))

    // 通常サイズ
    savePNG(image: image, size: size, path: "\(iconsetPath)/icon_\(size)x\(size).png")

    // @2x サイズ（Retinaディスプレイ用）
    if size <= 512 {
        savePNG(image: image, size: size, path: "\(iconsetPath)/icon_\(size/2)x\(size/2)@2x.png")
    }
}

print("\n✅ Icon images generated in \(iconsetPath)")
print("📦 To create .icns file, run:")
print("   iconutil -c icns \(iconsetPath)")
