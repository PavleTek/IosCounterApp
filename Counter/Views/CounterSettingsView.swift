//
//  CounterSettingsView.swift
//  Counter
//

import SwiftUI

struct CounterSettingsView: View {
    @EnvironmentObject private var store: CounterStore
    @Environment(\.dismiss) private var dismiss
    var counterID: UUID

    var body: some View {
        NavigationStack {
            Group {
                if store.counter(id: counterID) == nil {
                    Text("This counter was deleted")
                        .foregroundStyle(.secondary)
                } else {
                    form
                }
            }
            .navigationTitle("Counter Settings")
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
        }
    }

    private var form: some View {
        Form {
            Section("Name") {
                TextField("Name", text: name)
            }

            Section("Step") {
                StepEditor(step: step)
            }

            Section("Buttons") {
                LayoutPicker(layout: layout)
            }

            Section {
                Toggle("Use default theme", isOn: usesDefaultTheme)
                if store.counter(id: counterID)?.theme != nil {
                    ThemeEditor(theme: customTheme)
                }
            } header: {
                Text("Color")
            } footer: {
                Text("Default follows the color in Settings.")
            }

            Section {
                UnitEditor(unit: unit)
            } header: {
                Text("Unit")
            }

            Section {
                DecimalValueField(
                    title: "Value",
                    value: value,
                    allowNegative: store.settings.allowNegative
                )
            } header: {
                Text("Current value")
            } footer: {
                if !store.settings.allowNegative {
                    Text("Negative values are turned off in Settings.")
                }
            }
        }
    }

    private var name: Binding<String> {
        Binding(
            get: { store.counter(id: counterID)?.name ?? "" },
            set: { newValue in update { $0.name = newValue } }
        )
    }

    private var step: Binding<Decimal> {
        Binding(
            get: { store.counter(id: counterID)?.step ?? 1 },
            set: { newValue in
                guard newValue > 0 else { return }
                update { $0.step = newValue }
            }
        )
    }

    private var layout: Binding<CounterLayout> {
        Binding(
            get: { store.counter(id: counterID)?.layout ?? .plusMinusEqual },
            set: { newValue in update { $0.layout = newValue } }
        )
    }

    private var unit: Binding<CounterUnit> {
        Binding(
            get: { store.counter(id: counterID)?.unit ?? .none },
            set: { newValue in update { $0.unit = newValue } }
        )
    }

    private var value: Binding<Decimal> {
        Binding(
            get: { store.counter(id: counterID)?.value ?? 0 },
            set: { newValue in update { $0.value = newValue } }
        )
    }

    private var usesDefaultTheme: Binding<Bool> {
        Binding(
            get: { store.counter(id: counterID)?.theme == nil },
            set: { useDefault in
                update { item in
                    item.theme = useDefault ? nil : store.settings.defaultTheme
                }
            }
        )
    }

    private var customTheme: Binding<CounterTheme> {
        Binding(
            get: { store.counter(id: counterID)?.theme ?? store.settings.defaultTheme },
            set: { newTheme in update { $0.theme = newTheme } }
        )
    }

    private func update(_ mutate: (inout CounterItem) -> Void) {
        guard var item = store.counter(id: counterID) else { return }
        mutate(&item)
        store.update(item)
    }
}
