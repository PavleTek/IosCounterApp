//
//  SettingsView.swift
//  Counter
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: CounterStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmingApply = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ThemeEditor(theme: defaultTheme)
                } header: {
                    Text("Default color")
                } footer: {
                    Text("New counters use this color until you set one of their own. Counters set to the default update when you change it here.")
                }

                Section("Default step") {
                    StepEditor(step: defaultStep)
                }

                Section("Default buttons") {
                    LayoutPicker(layout: defaultLayout)
                }

                Section("Default unit") {
                    UnitEditor(unit: defaultUnit)
                }

                Section("Behavior") {
                    Toggle("Haptics", isOn: setting(\.hapticsEnabled))
                    Toggle("Keep screen awake", isOn: setting(\.keepScreenAwake))
                    Toggle("Confirm before reset", isOn: setting(\.confirmReset))
                    Toggle("Allow negative values", isOn: setting(\.allowNegative))
                }

                Section {
                    Button("Apply default theme to all counters") {
                        confirmingApply = true
                    }
                    .pointerButton()
                } footer: {
                    Text("Replaces each counter's colors with the default theme.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .pointerButton()
                }
            }
            .modifier(KeyboardDoneModifier())
            .confirmationDialog(
                "Apply the default theme to every counter?",
                isPresented: $confirmingApply,
                titleVisibility: .visible
            ) {
                Button("Apply") {
                    store.applyDefaultThemeToAll()
                }
                .pointerButton()
                Button("Cancel", role: .cancel) {}
                    .pointerButton()
            } message: {
                Text("This replaces each counter's own colors.")
            }
        }
    }

    private var defaultTheme: Binding<CounterTheme> {
        Binding(
            get: { store.settings.defaultTheme },
            set: { store.settings.defaultTheme = $0 }
        )
    }

    private var defaultStep: Binding<Decimal> {
        Binding(
            get: { store.settings.defaultStep },
            set: { newValue in
                guard newValue > 0 else { return }
                store.settings.defaultStep = newValue
            }
        )
    }

    private var defaultLayout: Binding<CounterLayout> {
        Binding(
            get: { store.settings.defaultLayout },
            set: { store.settings.defaultLayout = $0 }
        )
    }

    private var defaultUnit: Binding<CounterUnit> {
        Binding(
            get: { store.settings.defaultUnit },
            set: { store.settings.defaultUnit = $0 }
        )
    }

    private func setting(_ keyPath: WritableKeyPath<AppSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { store.settings[keyPath: keyPath] },
            set: { store.settings[keyPath: keyPath] = $0 }
        )
    }
}
