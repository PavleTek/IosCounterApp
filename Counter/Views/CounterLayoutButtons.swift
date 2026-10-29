//
//  CounterLayoutButtons.swift
//  Counter
//

import SwiftUI

struct CounterLayoutButtons: View {
    var layout: CounterLayout
    var theme: CounterTheme
    var wide: Bool
    var onIncrement: () -> Void
    var onDecrement: () -> Void
    var onReset: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            switch layout {
            case .bigPlus:
                symbolButton(
                    systemName: "plus",
                    label: "Add",
                    fill: theme.accent.color,
                    foreground: theme.accent.readableText,
                    fontSize: wide ? 64 : 84,
                    action: onIncrement
                )
            case .plusMinusEqual:
                if wide {
                    HStack(spacing: 12) {
                        minusButton(fontSize: 64)
                        plusButton(fontSize: 64)
                    }
                } else {
                    VStack(spacing: 12) {
                        plusButton(fontSize: 72)
                        minusButton(fontSize: 72)
                    }
                }
            case .plusWithSmallMinus:
                if wide {
                    HStack(spacing: 12) {
                        minusButton(fontSize: 40)
                            .frame(maxWidth: 140)
                        plusButton(fontSize: 72)
                    }
                } else {
                    plusButton(fontSize: 80)
                    minusButton(fontSize: 36)
                        .frame(height: 76)
                }
            }

            Button(action: onReset) {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(theme.foreground.color.opacity(0.14), in: Capsule())
                    .foregroundStyle(theme.foreground.color)
            }
            .buttonStyle(PressableButtonStyle())
            .pointerButton()
            .accessibilityLabel("Reset")
        }
    }

    private func plusButton(fontSize: CGFloat) -> some View {
        symbolButton(
            systemName: "plus",
            label: "Add",
            fill: theme.accent.color,
            foreground: theme.accent.readableText,
            fontSize: fontSize,
            action: onIncrement
        )
    }

    private func minusButton(fontSize: CGFloat) -> some View {
        symbolButton(
            systemName: "minus",
            label: "Subtract",
            fill: theme.foreground.color.opacity(0.14),
            foreground: theme.foreground.color,
            fontSize: fontSize,
            action: onDecrement
        )
    }

    private func symbolButton(
        systemName: String,
        label: String,
        fill: Color,
        foreground: Color,
        fontSize: CGFloat,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: fontSize, weight: .semibold))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(fill, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .foregroundStyle(foreground)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
        .pointerButton()
        .accessibilityLabel(label)
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
