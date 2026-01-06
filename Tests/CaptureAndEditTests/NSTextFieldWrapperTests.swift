import XCTest
import SwiftUI
@testable import CaptureAndEdit

final class NSTextFieldWrapperTests: XCTestCase {

    func testTextFieldIsEditable() {
        // Arrange
        let binding = Binding<String>(
            get: { "" },
            set: { _ in }
        )
        let wrapper = NSTextFieldWrapper(text: binding)
        let context = NSViewRepresentableContext<NSTextFieldWrapper>(
            coordinator: wrapper.makeCoordinator(),
            transaction: Transaction(),
            environment: EnvironmentValues()
        )

        // Act
        let textField = wrapper.makeNSView(context: context)

        // Assert
        XCTAssertTrue(textField.isEditable, "TextField should be editable")
        XCTAssertTrue(textField.isSelectable, "TextField should be selectable")
    }

    func testTextFieldHasBorder() {
        // Arrange
        let binding = Binding<String>(
            get: { "" },
            set: { _ in }
        )
        let wrapper = NSTextFieldWrapper(text: binding)
        let context = NSViewRepresentableContext<NSTextFieldWrapper>(
            coordinator: wrapper.makeCoordinator(),
            transaction: Transaction(),
            environment: EnvironmentValues()
        )

        // Act
        let textField = wrapper.makeNSView(context: context)

        // Assert
        XCTAssertTrue(textField.isBordered, "TextField should have border")
        XCTAssertEqual(textField.bezelStyle, .roundedBezel, "TextField should have rounded bezel style")
    }

    func testTextFieldBindingUpdates() {
        // Arrange
        var capturedText = ""
        let binding = Binding<String>(
            get: { capturedText },
            set: { capturedText = $0 }
        )
        let wrapper = NSTextFieldWrapper(text: binding)
        let coordinator = wrapper.makeCoordinator()
        let context = NSViewRepresentableContext<NSTextFieldWrapper>(
            coordinator: coordinator,
            transaction: Transaction(),
            environment: EnvironmentValues()
        )
        let textField = wrapper.makeNSView(context: context)

        // Act
        textField.stringValue = "Test Text"
        let notification = Notification(name: NSControl.textDidChangeNotification, object: textField)
        coordinator.controlTextDidChange(notification)

        // Assert
        XCTAssertEqual(capturedText, "Test Text", "Binding should be updated with text field value")
    }

    func testUpdateNSView() {
        // Arrange
        var capturedText = "Initial"
        let binding = Binding<String>(
            get: { capturedText },
            set: { capturedText = $0 }
        )
        let wrapper = NSTextFieldWrapper(text: binding)
        let context = NSViewRepresentableContext<NSTextFieldWrapper>(
            coordinator: wrapper.makeCoordinator(),
            transaction: Transaction(),
            environment: EnvironmentValues()
        )
        let textField = wrapper.makeNSView(context: context)

        // Act
        capturedText = "Updated"
        wrapper.updateNSView(textField, context: context)

        // Assert
        XCTAssertEqual(textField.stringValue, "Updated", "TextField should display updated text")
    }
}
