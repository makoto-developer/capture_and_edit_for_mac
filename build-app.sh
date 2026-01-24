#!/bin/bash

set -e

echo "🔨 Building CaptureAndEdit..."

# ビルド
swift build -c release

# アプリバンドルのディレクトリ構造を作成
APP_NAME="CaptureAndEdit"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS="${CONTENTS}/MacOS"
RESOURCES="${CONTENTS}/Resources"

# 既存のバンドルを削除
rm -rf "${APP_BUNDLE}"

# ディレクトリ作成
mkdir -p "${MACOS}"
mkdir -p "${RESOURCES}"

# 実行可能ファイルをコピー
cp ".build/release/${APP_NAME}" "${MACOS}/"

# アイコンをコピー
if [ -f "AppIcon.icns" ]; then
    cp "AppIcon.icns" "${RESOURCES}/"
    echo "✅ Icon copied"
else
    echo "⚠️  AppIcon.icns not found, run: swift generate-icon.swift && iconutil -c icns AppIcon.iconset"
fi

# Info.plistを作成
cat > "${CONTENTS}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>CaptureAndEdit</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.captureandedit</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Capture and Edit</string>
    <key>CFBundleDisplayName</key>
    <string>Capture and Edit</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "✅ App bundle created: ${APP_BUNDLE}"
echo "📦 To install, run: cp -R ${APP_BUNDLE} /Applications/"
