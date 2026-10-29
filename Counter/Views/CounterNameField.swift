//
//  CounterNameField.swift
//  Counter
//

import SwiftUI
import UIKit

/// SwiftUI `@FocusState` does not reach text fields hosted in the navigation bar,
/// so the title field is a `UITextField` that reports and accepts its editing state directly.
struct CounterNameField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    var placeholder: String
    var textColor: Color
    var cursorColor: Color

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.textAlignment = .center
        field.font = UIFont.preferredFont(forTextStyle: .headline)
        field.adjustsFontForContentSizeCategory = true
        field.returnKeyType = .done
        field.autocapitalizationType = .words
        field.accessibilityLabel = "Counter name"
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ field: UITextField, context: Context) {
        context.coordinator.parent = self
        if field.text != text {
            field.text = text
        }
        let textUIColor = UIColor(textColor)
        field.textColor = textUIColor
        field.tintColor = UIColor(cursorColor)
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: textUIColor.withAlphaComponent(0.5)]
        )
        if !isEditing && field.isFirstResponder {
            DispatchQueue.main.async {
                field.resignFirstResponder()
            }
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CounterNameField

        init(parent: CounterNameField) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ field: UITextField) {
            parent.isEditing = true
            DispatchQueue.main.async {
                field.selectAll(nil)
            }
        }

        func textFieldDidEndEditing(_ field: UITextField) {
            parent.isEditing = false
        }

        func textFieldShouldReturn(_ field: UITextField) -> Bool {
            field.resignFirstResponder()
            return false
        }

        @objc func textChanged(_ field: UITextField) {
            parent.text = field.text ?? ""
        }
    }
}
