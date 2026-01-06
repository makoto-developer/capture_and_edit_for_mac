.PHONY: help build install clean uninstall run deploy

APP_NAME = CaptureAndEdit
APP_BUNDLE = $(APP_NAME).app
INSTALL_PATH = /Applications/$(APP_BUNDLE)

# デフォルトターゲット: ヘルプ表示
help:
	@echo "📋 CaptureAndEdit - 利用可能なコマンド"
	@echo ""
	@echo "  make build      - アプリをビルド（.appバンドル作成）"
	@echo "  make install    - ビルド + /Applicationsにインストール"
	@echo "  make run        - ビルド + インストール + アプリ起動"
	@echo "  make deploy     - クリーン + ビルド + インストール"
	@echo "  make clean      - ビルド成果物を削除"
	@echo "  make uninstall  - /Applicationsからアプリを削除"
	@echo "  make help       - このヘルプを表示"
	@echo ""

# ビルド: build-app.shを実行
build:
	@echo "🔨 Building $(APP_NAME)..."
	@./build-app.sh
	@echo "✅ Build complete: $(APP_BUNDLE)"

# インストール: ビルド後に/Applicationsにコピー
install: build
	@echo "📦 Installing to $(INSTALL_PATH)..."
	@if [ -d "$(INSTALL_PATH)" ]; then \
		echo "⚠️  $(INSTALL_PATH) already exists. Removing..."; \
		rm -rf "$(INSTALL_PATH)"; \
	fi
	@cp -R $(APP_BUNDLE) /Applications/
	@echo "✅ Installed to $(INSTALL_PATH)"

# クリーン: ビルド成果物を削除
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf .build
	@rm -rf $(APP_BUNDLE)
	@echo "✅ Clean complete"

# アンインストール: /Applicationsからアプリを削除
uninstall:
	@if [ -d "$(INSTALL_PATH)" ]; then \
		echo "🗑️  Uninstalling $(INSTALL_PATH)..."; \
		rm -rf "$(INSTALL_PATH)"; \
		echo "✅ Uninstalled"; \
	else \
		echo "⚠️  $(INSTALL_PATH) not found"; \
	fi

# 実行: ビルド + インストール + アプリ起動
run: install
	@echo "🚀 Launching $(APP_NAME)..."
	@open $(INSTALL_PATH)
	@echo "✅ $(APP_NAME) launched"

# デプロイ: クリーン + ビルド + インストール
deploy: clean install
	@echo "✅ Deploy complete"
