//
//  CounterStore.swift
//  Counter
//

import Combine
import Foundation

@MainActor
final class CounterStore: ObservableObject {
    @Published private(set) var counters: [CounterItem]
    @Published var settings: AppSettings {
        didSet {
            guard !suppressSave else { return }
            scheduleSave()
        }
    }

    private let fileURL: URL
    private var saveTask: Task<Void, Never>?
    /// Stays true through `init` so assigning `settings` does not schedule a save before the store is ready.
    private var suppressSave = true

    init(fileURL: URL? = nil, createDefaultIfEmpty: Bool = true) {
        self.fileURL = fileURL ?? Self.defaultFileURL()
        if let persisted = Self.load(from: self.fileURL) {
            counters = persisted.counters
            settings = persisted.settings
            suppressSave = false
            return
        }

        let initial = AppSettings.initial
        counters = createDefaultIfEmpty ? [Self.makeCounter(using: initial, existingNames: [])] : []
        settings = initial
        suppressSave = false
        if createDefaultIfEmpty {
            saveNow()
        }
    }

    func counter(id: UUID) -> CounterItem? {
        counters.first { $0.id == id }
    }

    func increment(id: UUID) {
        guard let index = index(of: id) else { return }
        counters[index].value += counters[index].step
        Haptics.impact(enabled: settings.hapticsEnabled)
        scheduleSave()
    }

    func decrement(id: UUID) {
        guard let index = index(of: id) else { return }
        var next = counters[index].value - counters[index].step
        if !settings.allowNegative && next < 0 {
            next = 0
        }
        counters[index].value = next
        Haptics.impact(enabled: settings.hapticsEnabled)
        scheduleSave()
    }

    func reset(id: UUID) {
        guard let index = index(of: id) else { return }
        counters[index].value = 0
        Haptics.notify(enabled: settings.hapticsEnabled)
        scheduleSave()
    }

    @discardableResult
    func add() -> CounterItem {
        let item = Self.makeCounter(using: settings, existingNames: counters.map(\.name))
        counters.append(item)
        scheduleSave()
        return item
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            counters.remove(at: index)
        }
        scheduleSave()
    }

    func delete(id: UUID) {
        counters.removeAll { $0.id == id }
        scheduleSave()
    }

    func move(from source: IndexSet, to destination: Int) {
        let moving = source.sorted().map { counters[$0] }
        let alreadyBeforeDestination = source.filter { $0 < destination }.count
        for index in source.sorted(by: >) {
            counters.remove(at: index)
        }
        counters.insert(contentsOf: moving, at: destination - alreadyBeforeDestination)
        scheduleSave()
    }

    func update(_ counter: CounterItem) {
        guard let index = index(of: counter.id) else { return }
        counters[index] = counter
        scheduleSave()
    }

    func applyDefaultThemeToAll() {
        let theme = settings.defaultTheme
        for index in counters.indices {
            counters[index].theme = theme
        }
        scheduleSave()
    }

    func flush() {
        saveTask?.cancel()
        saveTask = nil
        saveNow()
    }

    static func defaultFileURL() -> URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("counters.json")
    }

    static func makeCounter(using settings: AppSettings, existingNames: [String]) -> CounterItem {
        CounterItem(
            id: UUID(),
            name: nextName(existing: existingNames),
            value: 0,
            step: settings.defaultStep,
            layout: settings.defaultLayout,
            theme: nil,
            unit: settings.defaultUnit,
            createdAt: Date()
        )
    }

    private func index(of id: UUID) -> Int? {
        counters.firstIndex { $0.id == id }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(nanoseconds: 250_000_000)
            } catch {
                return
            }
            guard let self, !Task.isCancelled else { return }
            self.saveNow()
        }
    }

    private func saveNow() {
        let directory = fileURL.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let state = PersistedState(version: 1, counters: counters, settings: settings)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(state)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // A failed write leaves the previous file in place. The next change tries again.
        }
    }

    private static func load(from url: URL) -> PersistedState? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(PersistedState.self, from: data)
        } catch {
            let backup = url.appendingPathExtension("bak")
            try? FileManager.default.removeItem(at: backup)
            try? FileManager.default.moveItem(at: url, to: backup)
            return nil
        }
    }

    private static func nextName(existing: [String]) -> String {
        let taken = Set(existing)
        if !taken.contains("Counter") {
            return "Counter"
        }
        var number = 2
        while taken.contains("Counter \(number)") {
            number += 1
        }
        return "Counter \(number)"
    }
}

private struct PersistedState: Codable {
    var version: Int
    var counters: [CounterItem]
    var settings: AppSettings
}
