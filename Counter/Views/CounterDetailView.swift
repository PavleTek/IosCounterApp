//
//  CounterDetailView.swift
//  Counter
//

import SwiftUI
import UIKit

struct CounterDetailView: View {
    @EnvironmentObject private var store: CounterStore
    var counterID: UUID

    @State private var showingSettings = false
    @State private var showingResetConfirm = false
    @State private var editingName = false

    var body: some View {
        Group {
            if let counter = store.counter(id: counterID) {
                counterBody(counter)
            } else {
                missingCounter
            }
        }
        .navigationTitle(store.counter(id: counterID)?.displayName ?? "Counter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let counter = store.counter(id: counterID) {
                    nameField(theme: counter.resolvedTheme(using: store.settings))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingName = false
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .pointerButton()
                .accessibilityLabel("Counter settings")
                .disabled(store.counter(id: counterID) == nil)
            }
        }
        .sheet(isPresented: $showingSettings) {
            CounterSettingsView(counterID: counterID)
        }
        .confirmationDialog(
            "Reset this counter?",
            isPresented: $showingResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    store.reset(id: counterID)
                }
            }
            .pointerButton()
            Button("Cancel", role: .cancel) {}
                .pointerButton()
        } message: {
            Text("The current value will go back to zero.")
        }
        .onAppear {
            Haptics.prepare()
            updateIdleTimer()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onChange(of: store.settings.keepScreenAwake) { _ in
            updateIdleTimer()
        }
        .onChange(of: editingName) { editing in
            if !editing {
                trimName()
            }
        }
    }

    private var missingCounter: some View {
        VStack(spacing: 8) {
            Text("This counter was deleted")
                .font(.title3.weight(.semibold))
            Text("Go back to the list to pick another one.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }

    private func nameField(theme: CounterTheme) -> some View {
        CounterNameField(
            text: name,
            isEditing: $editingName,
            placeholder: "Untitled",
            textColor: theme.foreground.color,
            cursorColor: theme.accent.color
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            theme.foreground.color.opacity(editingName ? 0.14 : 0),
            in: Capsule()
        )
        .frame(maxWidth: 240)
        .animation(.easeOut(duration: 0.18), value: editingName)
    }

    private func counterBody(_ counter: CounterItem) -> some View {
        let theme = counter.resolvedTheme(using: store.settings)
        let valueText = UnitFormatter.format(value: counter.value, unit: counter.unit)
        let colorScheme: ColorScheme = theme.background.isDark ? .dark : .light
        return GeometryReader { geo in
            let wide = geo.size.width > geo.size.height
            let valueSize = min(max(min(geo.size.width, geo.size.height) * 0.18, 48), 112)
            VStack(spacing: 16) {
                Text(valueText)
                    .font(.system(size: valueSize, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.foreground.color)
                    .monospacedDigit()
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .modifier(NumericTextTransition(value: NSDecimalNumber(decimal: counter.value).doubleValue))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .accessibilityLabel("Value")
                    .accessibilityValue(valueText)

                CounterLayoutButtons(
                    layout: counter.layout,
                    theme: theme,
                    wide: wide,
                    onIncrement: {
                        editingName = false
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            store.increment(id: counter.id)
                        }
                    },
                    onDecrement: {
                        editingName = false
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            store.decrement(id: counter.id)
                        }
                    },
                    onReset: requestReset
                )
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea(.keyboard)
        .background(theme.background.color.ignoresSafeArea())
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(colorScheme, for: .navigationBar)
        .environment(\.colorScheme, colorScheme)
        .tint(theme.foreground.color)
    }

    private var name: Binding<String> {
        Binding(
            get: { store.counter(id: counterID)?.name ?? "" },
            set: { newValue in
                guard var item = store.counter(id: counterID) else { return }
                item.name = newValue
                store.update(item)
            }
        )
    }

    private func trimName() {
        guard var item = store.counter(id: counterID) else { return }
        let trimmed = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != item.name else { return }
        item.name = trimmed
        store.update(item)
    }

    private func requestReset() {
        editingName = false
        if store.settings.confirmReset {
            showingResetConfirm = true
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                store.reset(id: counterID)
            }
        }
    }

    private func updateIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = store.settings.keepScreenAwake
    }
}

private struct NumericTextTransition: ViewModifier {
    var value: Double

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.contentTransition(.numericText(value: value))
        } else {
            content
        }
    }
}
