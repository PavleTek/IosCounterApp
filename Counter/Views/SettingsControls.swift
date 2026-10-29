//
//  SettingsControls.swift
//  Counter
//

import SwiftUI
import UIKit

struct StepEditor: View {
    @Binding var step: Decimal
    @State private var text = ""
    @FocusState private var focused: Bool

    private let presets: [Decimal] = [1, 25, 50, 100, 400]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { preset in
                        let title = UnitFormatter.formatQuantity(preset)
                        Button(title) {
                            focused = false
                            step = preset
                            text = title
                        }
                        .buttonStyle(.bordered)
                        .tint(step == preset ? Color.accentColor : Color.secondary)
                        .pointerButton()
                        .accessibilityLabel("Step \(title)")
                        .accessibilityAddTraits(step == preset ? .isSelected : AccessibilityTraits())
                    }
                }
                .padding(.vertical, 2)
            }

            TextField("Custom step", text: $text)
                .keyboardType(.decimalPad)
                .focused($focused)
                .onChange(of: text) { newText in
                    guard focused else { return }
                    guard let parsed = DecimalParsing.parse(newText), parsed > 0 else { return }
                    if parsed != step {
                        step = parsed
                    }
                }
                .onChange(of: focused) { isFocused in
                    if !isFocused {
                        text = UnitFormatter.formatQuantity(step)
                    }
                }
        }
        .onAppear {
            text = UnitFormatter.formatQuantity(step)
        }
        .onChange(of: step) { newStep in
            guard !focused else { return }
            let formatted = UnitFormatter.formatQuantity(newStep)
            if formatted != text {
                text = formatted
            }
        }
    }
}

struct DecimalValueField: View {
    var title: String
    @Binding var value: Decimal
    var allowNegative: Bool

    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(allowNegative ? .numbersAndPunctuation : .decimalPad)
            .focused($focused)
            .onAppear {
                text = UnitFormatter.formatQuantity(value)
            }
            .onChange(of: text) { newText in
                guard focused else { return }
                guard let parsed = DecimalParsing.parse(newText) else { return }
                if !allowNegative && parsed < 0 { return }
                if parsed != value {
                    value = parsed
                }
            }
            .onChange(of: value) { newValue in
                guard !focused else { return }
                text = UnitFormatter.formatQuantity(newValue)
            }
            .onChange(of: focused) { isFocused in
                if !isFocused {
                    text = UnitFormatter.formatQuantity(value)
                }
            }
    }
}

struct UnitEditor: View {
    @Binding var unit: CounterUnit
    @State private var customLabel = ""

    var body: some View {
        Picker("Unit", selection: kindBinding) {
            ForEach(UnitKind.allCases) { kind in
                Text(kind.title).tag(kind)
            }
        }

        if unit.kind == .custom {
            TextField("Unit label", text: customLabelBinding)
                .textInputAutocapitalization(.never)
        }

        Text(unit.scalingDescription)
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var kindBinding: Binding<UnitKind> {
        Binding(
            get: { unit.kind },
            set: { kind in
                let label = customLabel.isEmpty ? unit.customLabel : customLabel
                customLabel = label
                unit = unit.replacingKind(kind, customLabel: label)
            }
        )
    }

    private var customLabelBinding: Binding<String> {
        Binding(
            get: { unit.customLabel },
            set: { newValue in
                customLabel = newValue
                unit = .custom(label: newValue)
            }
        )
    }
}

struct ThemeEditor: View {
    @Binding var theme: CounterTheme

    var body: some View {
        ThemePresetGrid(selected: theme) { preset in
            theme = preset
        }
        ColorPicker("Background", selection: colorBinding(\.background), supportsOpacity: false)
        ColorPicker("Text", selection: colorBinding(\.foreground), supportsOpacity: false)
        ColorPicker("Accent", selection: colorBinding(\.accent), supportsOpacity: false)
    }

    private func colorBinding(_ keyPath: WritableKeyPath<CounterTheme, RGBAColor>) -> Binding<Color> {
        Binding(
            get: { theme[keyPath: keyPath].color },
            set: { newColor in
                var updated = theme
                updated[keyPath: keyPath] = RGBAColor(newColor)
                updated.name = nil
                theme = updated
            }
        )
    }
}

struct ThemePresetGrid: View {
    var selected: CounterTheme
    var onSelect: (CounterTheme) -> Void

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(CounterTheme.presets, id: \.name) { preset in
                Button {
                    onSelect(preset)
                } label: {
                    VStack(spacing: 6) {
                        Circle()
                            .fill(preset.background.color)
                            .overlay(Circle().stroke(preset.accent.color, lineWidth: 4))
                            .overlay {
                                if preset.name == selected.name, selected.name != nil {
                                    Image(systemName: "checkmark")
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(preset.foreground.color)
                                }
                            }
                            .frame(width: 44, height: 44)
                        Text(preset.name ?? "Theme")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointerButton()
                .accessibilityLabel(preset.name ?? "Theme")
                .accessibilityAddTraits(preset.name == selected.name ? .isSelected : AccessibilityTraits())
            }
        }
        .padding(.vertical, 4)
    }
}

struct LayoutPicker: View {
    @Binding var layout: CounterLayout

    var body: some View {
        VStack(spacing: 8) {
            ForEach(CounterLayout.allCases) { option in
                Button {
                    layout = option
                } label: {
                    HStack(spacing: 12) {
                        LayoutMiniPreview(layout: option)
                            .frame(width: 72, height: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(option.title)
                                .foregroundStyle(.primary)
                            Text(option.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 8)
                        if layout == option {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointerButton()
                .accessibilityLabel(option.title)
                .accessibilityAddTraits(layout == option ? .isSelected : AccessibilityTraits())
            }
        }
        .padding(.vertical, 4)
    }
}

struct LayoutMiniPreview: View {
    var layout: CounterLayout

    var body: some View {
        HStack(spacing: 3) {
            switch layout {
            case .bigPlus:
                previewBlock
            case .plusMinusEqual:
                previewBlock
                previewBlock
            case .plusWithSmallMinus:
                previewBlock
                    .frame(maxWidth: 18)
                previewBlock
            }
        }
        .accessibilityHidden(true)
    }

    private var previewBlock: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color.accentColor.opacity(0.85))
    }
}

struct KeyboardDoneModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
                .pointerButton()
            }
        }
    }
}
