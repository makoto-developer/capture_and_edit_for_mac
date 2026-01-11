# Capture and Edit for Mac

macOSでスクリーンショットをキャプチャしたら自動で起動し、その場で編集できる軽量アプリケーションです。

## Motivation

- Claude Code でフロントエンドの画面修正を指示する時に、画像を編集して指示した方がAIが理解しやすい
- 無料でこのようなツールが存在しなかったので自分で作ることにした

## デモ

### 使用例: UIの問題点を指摘

![デモ](docs/images/demo.gif)

**操作の流れ:**
1. 適当な画面UIをキャプチャ（Cmd+Shift+4）
2. アプリが自動起動
3. 枠描画ツールで問題箇所を四角で囲む
4. テキストツールで問題点を指摘
5. クリップボードに保存して他のアプリで使用

## 機能

### 自動起動
- クリップボードに画像がコピーされると自動でアプリが起動
- キャプチャ画像を即座に編集可能
- メニューバーアイコンから簡単アクセス

### 編集機能
- **選択ツール**: オブジェクトを選択してドラッグで移動
- **線描画**: 色付きの線を自由に描画
- **枠描画**: 色付きの矩形で範囲を囲む
- **矢印**: 矢印を描画
- **テキスト**: テキストを追加
- **塗りつぶし**: シークレット情報を黒く塗りつぶし（AI読み取り防止）
- **Undo/Redo**: 編集操作の取り消し・やり直し（Ctrl+B / Ctrl+R）
- **全クリア**: すべての編集をリセット

### 保存機能
- 編集後、クリップボードに上書き保存
- 保存後の自動終了設定（オプション）

### ヒストリー機能
- 過去に編集した画像の履歴を自動保存
- 履歴ビューから過去の画像を表示・再利用
- 履歴からクリップボードへのコピーが可能
- 個別削除・全削除機能

**保存・表示枚数:**
- **アプリ上の表示**: 最大25件まで（新しい順）
- **ディスク上の保存**: 枚数制限なし（すべて保存されます）
- **自動削除**: なし（古いファイルも自動削除されません）

**保存場所とファイル管理:**
- 保存先: `~/CaptureAndEdit_history/`（ホームディレクトリ直下）
- ファイル名形式: `CaptureAndEdit_YYYYMMDD_HHmmss.png`
  - 例: `CaptureAndEdit_20260111_143052.png`
- 編集した画像は自動的にこのフォルダに保存されます
- アプリを削除してもこのフォルダは残りますので、手動で削除してください
- ディスク容量を圧迫する可能性があるため、定期的にフォルダ内を整理してください

### キーボードショートカット
- **Ctrl+B**: Undo（操作を取り消し）
- **Ctrl+R**: Redo（取り消した操作を元に戻す）
- **Cmd+Shift+E**: アプリウィンドウを表示

## 技術スタック

- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI + AppKit
- **アーキテクチャ**: MVVM
- **対応OS**: macOS 13.0+

## インストール方法

### 簡単インストール（推奨）

(将来的にはインストーラとか`brew`コマンドでインストールできるようにする予定)

Makefileを使った簡単なインストール方法

```bash
# ヘルプを表示
make help

# ビルド + インストール
make install

# ビルド + インストール + 起動
make run

# クリーン + ビルド + インストール
make deploy
```

### 利用可能なMakeコマンド

- `make build` - アプリをビルド（.appバンドル作成）
- `make install` - ビルド + /Applicationsにインストール
- `make run` - ビルド + インストール + アプリ起動
- `make deploy` - クリーン + ビルド + インストール
- `make clean` - ビルド成果物を削除
- `make uninstall` - /Applicationsからアプリを削除
- `make help` - ヘルプを表示

### 手動インストール

ターミナルで以下のコマンドを実行してください：

```bash
./build-app.sh && cp -R CaptureAndEdit.app /Applications/
```

これで、macOSの「アプリケーション」フォルダにアプリがインストールされます。

### 詳細な手順

1. **ビルドスクリプトを実行**
   ```bash
   ./build-app.sh
   ```

2. **アプリをApplicationsフォルダにコピー**
   ```bash
   cp -R CaptureAndEdit.app /Applications/
   ```

3. **Launchpadまたはアプリケーションフォルダから起動**

   初回起動時、メニューバーにアイコンが表示されます

4. **完了！**

   以降、スクリーンショットをキャプチャすると自動で起動します

## ビルド方法

### 必要環境
- macOS 13.0以上
- Xcode 15.0以上（Swift 5.9対応）
- Swift Package Manager

### ビルドコマンド

**Makefileを使う（推奨）:**
```bash
# アプリバンドルを作成
make build

# クリーンビルド
make clean && make build
```

**直接Swiftコマンドを使う:**
```bash
# デバッグビルド
swift build

# リリースビルド
swift build -c release

# 実行
swift run

# アプリバンドルの作成
./build-app.sh
```

## プロジェクト構造

```
Sources/CaptureAndEdit/
├── App/
│   ├── CaptureAndEditApp.swift    # アプリエントリーポイント
│   └── AppDelegate.swift          # アプリケーションデリゲート
├── Models/
│   ├── DrawingTool.swift          # 描画ツール定義
│   ├── EditOperation.swift        # 編集操作プロトコル
│   ├── ImageDocument.swift        # 画像ドキュメントモデル
│   └── HistoryItem.swift          # ヒストリーアイテムモデル
├── ViewModels/
│   ├── MainViewModel.swift        # メインビューモデル
│   ├── CanvasViewModel.swift      # キャンバスビューモデル
│   └── HistoryViewModel.swift     # ヒストリービューモデル
├── Views/
│   ├── MainView.swift             # メインビュー
│   ├── CanvasView.swift           # キャンバスビュー
│   ├── ToolbarView.swift          # ツールバー
│   ├── SettingsView.swift         # 設定画面
│   └── HistoryView.swift          # ヒストリービュー
├── Services/
│   ├── ClipboardMonitor.swift     # クリップボード監視
│   ├── ClipboardService.swift     # クリップボード保存
│   └── HistoryService.swift       # ヒストリー管理
└── Utilities/
    └── Extensions.swift           # 拡張機能
```

## セキュリティ

- アカウント登録不要：無料で誰もが利用可能(商用利用不可)
- ローカル完結型: すべての処理はローカルで実行
- インターネットアクセスなし: 外部への通信は一切行いません
- プライバシー保護: 画像データは外部に送信されません

## 使い方

1. アプリを起動
2. macOSの標準スクリーンショット機能でキャプチャ（Cmd+Shift+4など）
3. アプリが自動で前面に表示
4. ツールバーからツールと色を選択
5. 画像上をドラッグして編集
6. 「Save to Clipboard」ボタンでクリップボードに保存
7. 他のアプリで貼り付け（Cmd+V）

## 設定

(この機能は拡張して実装していません。終了する選択肢だけ用意しています。)

設定画面

- **自動終了**: 保存後にアプリを自動で終了するかどうか

## ライセンス

このプロジェクトは [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.ja) (Creative Commons Attribution-NonCommercial 4.0 International) の下でライセンスされています。

- ✅ 個人利用・学習目的での使用は自由
- ✅ フォーク・改変は可能
- ❌ 商用利用・販売は禁止
- ❌ 改変版の商品化も禁止

詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 注意事項

- テストコードは別途作成予定
- 本番環境での使用前に十分な動作確認を行ってください

