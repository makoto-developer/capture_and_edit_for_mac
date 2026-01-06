# CaptureAndEdit テストドキュメント

## テスト概要

このプロジェクトには包括的なユニットテストと統合テストが実装されています。

## テスト構成

### 作成済みテストファイル

1. **EditOperationTests.swift**
   - LineOperation の初期化、描画テスト
   - RectangleOperation の初期化、描画テスト
   - PixelateOperation の初期化、描画テスト
   - EditOperation プロトコル準拠テスト

2. **ImageDocumentTests.swift** (予定)
   - 画像管理機能のテスト
   - Undo/Redo 機能のテスト
   - 操作追加機能のテスト
   - レンダリング機能のテスト

3. **DrawingToolTests.swift** (予定)
   - DrawingTool enum のテスト
   - DrawingColor enum のテスト

4. **CanvasViewModelTests.swift** (予定)
   - マウス操作テスト
   - 編集操作生成テスト

5. **MainViewModelTests.swift** (予定)
   - クリップボード連携テスト
   - 保存機能テスト
   - 全体ワークフローテスト

6. **ClipboardServiceTests.swift** (予定)
   - クリップボード操作テスト
   - シングルトンテスト

7. **IntegrationTests.swift** (予定)
   - エディタ全体フローの統合テスト
   - Undo/Redo ワークフロー
   - 複数ツール使用シナリオ

## テスト実行方法

### Xcode を使用する場合

1. Xcode でプロジェクトを開く
   ```bash
   open Package.swift
   ```

2. テストを実行
   - `Cmd + U` でテストを実行
   - または Test Navigator から個別のテストを実行

### コマンドラインから実行する場合

```bash
swift test
```

**注意**: Command Line Tools環境では XCTest モジュールの読み込みに問題が発生する場合があります。
その場合は Xcode を使用してテストを実行してください。

### Xcode の開発者パスを設定

Command Line Tools環境で問題が発生する場合:

```bash
# Xcode の開発者パスを確認
xcode-select -p

# 必要に応じて Xcode.app に切り替え
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## テストカバレッジ目標

- **Models層**: 主要ロジックの100%カバレッジ
- **ViewModels層**: ビジネスロジックの100%カバレッジ
- **Services層**: クリティカルパスの100%カバレッジ
- **統合テスト**: 主要ユーザーフローの網羅

## テストの型安全性

すべてのテストは以下の原則に従っています:

- `any` 型の使用を最小限に抑制
- 明示的な型アノテーション
- XCTest のアサーションで型安全性を保証

## 継続的インテグレーション

GitHub Actions や他の CI/CD ツールでテストを自動実行することを推奨します。

```yaml
# .github/workflows/test.yml の例
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: swift test
```
