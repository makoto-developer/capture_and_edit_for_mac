import SwiftUI
import AppKit

struct NSTextFieldWrapper: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.delegate = context.coordinator
        textField.placeholderString = "テキスト"
        textField.isBordered = true
        textField.bezelStyle = .roundedBezel
        textField.focusRingType = .default

        // 🔑 重要: 編集可能に設定
        textField.isEditable = true
        textField.isSelectable = true

        // 自動的にフォーカスを当てる
        DispatchQueue.main.async {
            textField.window?.makeFirstResponder(textField)
        }

        print("✅ NSTextField created - isEditable: \(textField.isEditable), isSelectable: \(textField.isSelectable)")

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text = textField.stringValue
        }
    }
}
