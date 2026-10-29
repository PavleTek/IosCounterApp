//
//  CounterListView.swift
//  Counter
//

import SwiftUI

struct CounterListView: View {
    @EnvironmentObject private var store: CounterStore
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if store.counters.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Counters")
            .toolbar { toolbar }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .navigationDestination(for: UUID.self) { id in
                CounterDetailView(counterID: id)
            }
        }
    }

    private var list: some View {
        List {
            ForEach(store.counters) { counter in
                NavigationLink(value: counter.id) {
                    CounterRow(
                        counter: counter,
                        theme: counter.resolvedTheme(using: store.settings)
                    )
                }
            }
            .onDelete { offsets in
                withAnimation {
                    store.delete(at: offsets)
                }
            }
            .onMove { source, destination in
                withAnimation {
                    store.move(from: source, to: destination)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No counters")
                .font(.title2.weight(.semibold))
            Text("Add a counter for laps, reps, or anything you want to keep track of.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                withAnimation {
                    _ = store.add()
                }
            } label: {
                Text("Add counter")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.accentColor, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .pointerButton()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if !store.counters.isEmpty {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .pointerButton()
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .pointerButton()
            .accessibilityLabel("Settings")

            Button {
                withAnimation {
                    _ = store.add()
                }
            } label: {
                Image(systemName: "plus")
            }
            .pointerButton()
            .accessibilityLabel("Add counter")
        }
    }
}

private struct CounterRow: View {
    var counter: CounterItem
    var theme: CounterTheme

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(theme.background.color)
                .overlay(Circle().stroke(theme.accent.color, lineWidth: 3))
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(counter.displayName)
                    .font(.headline)
                Text(UnitFormatter.format(value: counter.value, unit: counter.unit))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CounterListView()
        .environmentObject(CounterStore(fileURL: previewStoreURL(), createDefaultIfEmpty: true))
}

private func previewStoreURL() -> URL {
    FileManager.default.temporaryDirectory
        .appendingPathComponent("CounterPreview", isDirectory: true)
        .appendingPathComponent("counters.json")
}
