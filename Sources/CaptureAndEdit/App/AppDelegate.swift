import AppKit
import SwiftUI

public final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    public var window: NSWindow?
    private var viewModel: MainViewModel?
    private var statusItem: NSStatusItem?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // 🔑 重要: アプリを通常のフォアグラウンドアプリとして設定
        // これにより Cmd+Tab に表示され、フォーカスを取得できる
        NSApp.setActivationPolicy(.regular)
        print("✅ Activation policy set to .regular")

        // ViewModelを作成
        let mainViewModel = MainViewModel()
        viewModel = mainViewModel

        // ウィンドウ参照をViewModelに渡す
        mainViewModel.window = { [weak self] in self?.window }

        // ウィンドウを作成（最初は非表示）
        let contentView = MainView()
            .environmentObject(mainViewModel)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window?.center()
        window?.title = "Capture and Edit"
        window?.contentView = NSHostingView(rootView: contentView)
        window?.delegate = self

        // ウィンドウサイズの制限を設定
        window?.minSize = NSSize(width: 400, height: 300)
        window?.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        // 🔑 重要: Cmd+Tab に表示させるため、起動時にウィンドウを表示
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        print("✅ Window displayed on launch")

        // 監視を開始
        print("📡 AppDelegate: Starting clipboard monitoring...")
        mainViewModel.startMonitoring()
        print("✅ AppDelegate: Monitoring started")

        // グローバルホットキー登録（Cmd + Shift + E）
        HotKeyManager.shared.onHotKeyPressed = { [weak self] in
            self?.showWindow()
        }
        HotKeyManager.shared.registerHotKey()

        // メニューバーアイコンを設定
        setupMenuBarIcon()

        // メインメニューを設定（Undo/Redoショートカット用）
        setupMainMenu()
    }

    private func setupMenuBarIcon() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // SF Symbolsを使用してアイコンを設定
            button.image = NSImage(systemSymbolName: "photo.on.rectangle.angled", accessibilityDescription: "Capture and Edit")
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
        }

        // メニューを作成
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "ウィンドウを表示", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "終了", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc private func statusBarButtonClicked(_ sender: AnyObject?) {
        showWindow()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc private func showWindow() {
        print("🪟 showWindow() called")

        guard let window = window else {
            print("❌ No window found")
            return
        }

        // ウィンドウがミニマイズされている場合は元に戻す
        if window.isMiniaturized {
            window.deminiaturize(nil)
        }

        // ウィンドウを最前面に表示
        window.orderFront(nil)
        window.makeKeyAndOrderFront(nil)

        // アプリをアクティベート
        NSApp.activate(ignoringOtherApps: true)

        print("✅ Window should be visible now")
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // ウィンドウの×ボタンを押した時に、閉じずに隠す
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("🔒 Window close button pressed - hiding instead of closing")
        sender.orderOut(nil)  // ウィンドウを隠す
        return false  // ウィンドウを閉じない
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // Fileメニューを作成
        let fileMenu = NSMenu(title: "File")
        let fileMenuItem = NSMenuItem()
        fileMenuItem.submenu = fileMenu

        // Close Window（Cmd+W）
        let closeWindowItem = NSMenuItem(
            title: "Close Window",
            action: #selector(closeWindow),
            keyEquivalent: "w"
        )
        closeWindowItem.target = self
        fileMenu.addItem(closeWindowItem)

        mainMenu.addItem(fileMenuItem)

        // Editメニューを作成
        let editMenu = NSMenu(title: "Edit")
        let editMenuItem = NSMenuItem()
        editMenuItem.submenu = editMenu

        // Undo（Cmd+Z）
        let undoItem = NSMenuItem(
            title: "Undo",
            action: #selector(performUndo),
            keyEquivalent: "z"
        )
        undoItem.target = self
        editMenu.addItem(undoItem)

        // Redo（Cmd+Shift+Z）
        let redoItem = NSMenuItem(
            title: "Redo",
            action: #selector(performRedo),
            keyEquivalent: "z"
        )
        redoItem.keyEquivalentModifierMask = [.command, .shift]
        redoItem.target = self
        editMenu.addItem(redoItem)

        editMenu.addItem(NSMenuItem.separator())

        // Undo（Ctrl+B）
        let undoCtrlItem = NSMenuItem(
            title: "Undo (Ctrl+B)",
            action: #selector(performUndo),
            keyEquivalent: "b"
        )
        undoCtrlItem.keyEquivalentModifierMask = [.control]
        undoCtrlItem.target = self
        editMenu.addItem(undoCtrlItem)

        // Redo（Ctrl+R）
        let redoCtrlItem = NSMenuItem(
            title: "Redo (Ctrl+R)",
            action: #selector(performRedo),
            keyEquivalent: "r"
        )
        redoCtrlItem.keyEquivalentModifierMask = [.control]
        redoCtrlItem.target = self
        editMenu.addItem(redoCtrlItem)

        mainMenu.addItem(editMenuItem)
        NSApp.mainMenu = mainMenu

        print("✅ Main menu setup complete with Undo/Redo shortcuts")
    }

    @objc private func performUndo() {
        print("⏪ Undo triggered via keyboard shortcut")
        viewModel?.undo()
    }

    @objc private func performRedo() {
        print("⏩ Redo triggered via keyboard shortcut")
        viewModel?.redo()
    }

    @objc private func closeWindow() {
        print("🔒 Close Window triggered via Cmd+W")
        window?.orderOut(nil)
    }
}
