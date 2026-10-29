//
//  CounterTests.swift
//  CounterTests
//
//  Created by Pavle on 29-10-26.
//

import Foundation
import Testing
@testable import Counter

@MainActor
struct UnitFormatterTests {
    @Test func metricDistanceScalesAtOneThousand() {
        #expect(UnitFormatter.format(value: 950, unit: .metricDistance) == "950 m")
        #expect(UnitFormatter.format(value: 999, unit: .metricDistance) == "999 m")
        #expect(UnitFormatter.format(value: 1000, unit: .metricDistance) == "1 km")
        #expect(UnitFormatter.format(value: 1100, unit: .metricDistance) == "1.1 km")
        #expect(UnitFormatter.format(value: 2500, unit: .metricDistance) == "2.5 km")
    }

    @Test func imperialDistanceUsesMilesAtOneSevenSixZero() {
        #expect(UnitFormatter.format(value: 880, unit: .imperialDistance) == "880 yd")
        #expect(UnitFormatter.format(value: 1759, unit: .imperialDistance) == "1759 yd")
        #expect(UnitFormatter.format(value: 1760, unit: .imperialDistance) == "1 mi")
        #expect(UnitFormatter.format(value: 3520, unit: .imperialDistance) == "2 mi")
    }

    @Test func weightVolumeAndTimeScaleOnTheirLadders() {
        #expect(UnitFormatter.format(value: 999, unit: .weightMetric) == "999 g")
        #expect(UnitFormatter.format(value: 1500, unit: .weightMetric) == "1.5 kg")
        #expect(UnitFormatter.format(value: 1_000_000, unit: .weightMetric) == "1 t")
        #expect(UnitFormatter.format(value: 2_500_000, unit: .weightMetric) == "2.5 t")
        #expect(UnitFormatter.format(value: 59, unit: .time) == "59 s")
        #expect(UnitFormatter.format(value: 90, unit: .time) == "1.5 min")
        #expect(UnitFormatter.format(value: 3600, unit: .time) == "1 h")
        #expect(UnitFormatter.format(value: 500, unit: .volume) == "500 mL")
        #expect(UnitFormatter.format(value: 1500, unit: .volume) == "1.5 L")
    }

    @Test func trimsTrailingZerosAndKeepsTheSign() {
        #expect(UnitFormatter.formatQuantity(2) == "2")
        #expect(UnitFormatter.formatQuantity(decimal("1.50")) == "1.5")
        #expect(UnitFormatter.formatQuantity(decimal("1.10")) == "1.1")
        #expect(UnitFormatter.format(value: -1100, unit: .metricDistance) == "-1.1 km")
        #expect(UnitFormatter.format(value: -90, unit: .time) == "-1.5 min")
        #expect(UnitFormatter.format(value: 12, unit: .none) == "12")
        #expect(UnitFormatter.format(value: 3, unit: .custom(label: "laps")) == "3 laps")
        #expect(UnitFormatter.format(value: 3, unit: .custom(label: "")) == "3")
    }
}

@MainActor
struct CounterStoreTests {
    @Test func incrementAndDecrementUseTheCounterStep() {
        let store = makeStore(createDefault: false)
        store.settings.defaultStep = 25
        let item = store.add()
        store.increment(id: item.id)
        #expect(store.counter(id: item.id)?.value == 25)
        store.increment(id: item.id)
        #expect(store.counter(id: item.id)?.value == 50)
        store.decrement(id: item.id)
        #expect(store.counter(id: item.id)?.value == 25)
    }

    @Test func decrementClampsAtZeroUnlessNegativesAreAllowed() {
        let store = makeStore(createDefault: false)
        var item = store.add()
        item.value = 10
        item.step = 25
        store.update(item)
        store.decrement(id: item.id)
        #expect(store.counter(id: item.id)?.value == 0)

        store.settings.allowNegative = true
        var negative = store.counter(id: item.id)!
        negative.value = 10
        negative.step = 25
        store.update(negative)
        store.decrement(id: item.id)
        #expect(store.counter(id: item.id)?.value == -15)
    }

    @Test func addUsesCurrentDefaultsAndUniqueNames() {
        let store = makeStore(createDefault: true)
        #expect(store.counters.count == 1)
        #expect(store.counters[0].name == "Counter")

        store.settings.defaultStep = decimal("0.5")
        store.settings.defaultLayout = .bigPlus
        store.settings.defaultUnit = .metricDistance
        let added = store.add()
        #expect(added.name == "Counter 2")
        #expect(added.step == decimal("0.5"))
        #expect(added.layout == .bigPlus)
        #expect(added.unit == .metricDistance)
        #expect(added.theme == nil)
        #expect(added.value == 0)
    }

    @Test func deleteAndMoveUpdateOrder() {
        let store = makeStore(createDefault: false)
        let first = store.add()
        let second = store.add()
        store.delete(at: IndexSet(integer: 0))
        #expect(store.counters.map(\.id) == [second.id])
        let third = store.add()
        store.move(from: IndexSet(integer: 1), to: 0)
        #expect(store.counters.map(\.id) == [third.id, second.id])
        #expect(first.id != second.id)
    }

    @Test func resetSetsTheValueBackToZero() {
        let store = makeStore(createDefault: false)
        let item = store.add()
        store.increment(id: item.id)
        store.reset(id: item.id)
        #expect(store.counter(id: item.id)?.value == 0)
    }

    @Test func applyDefaultThemeCopiesItOntoEveryCounter() {
        let store = makeStore(createDefault: true)
        store.settings.defaultTheme = .forest
        #expect(store.counters[0].theme == nil)
        store.applyDefaultThemeToAll()
        #expect(store.counters[0].theme == .forest)
    }

    @Test func firstLaunchWritesOneCounterAndReloadKeepsIt() {
        let url = temporaryFileURL()
        let store = CounterStore(fileURL: url, createDefaultIfEmpty: true)
        #expect(store.counters.count == 1)
        #expect(store.counters[0].name == "Counter")
        #expect(FileManager.default.fileExists(atPath: url.path))

        let reloaded = CounterStore(fileURL: url, createDefaultIfEmpty: false)
        #expect(reloaded.counters.map(\.id) == store.counters.map(\.id))
    }

    @Test func anEmptySavedListStaysEmpty() {
        let url = temporaryFileURL()
        let store = CounterStore(fileURL: url, createDefaultIfEmpty: true)
        store.delete(at: IndexSet(integer: 0))
        store.flush()

        let reloaded = CounterStore(fileURL: url, createDefaultIfEmpty: true)
        #expect(reloaded.counters.isEmpty)
    }

    @Test func roundTripKeepsValuesThemeUnitAndSettings() throws {
        let url = temporaryFileURL()
        let store = CounterStore(fileURL: url, createDefaultIfEmpty: false)
        store.settings.hapticsEnabled = false
        store.settings.defaultTheme = .track
        store.settings.defaultStep = 400
        store.settings.defaultLayout = .plusWithSmallMinus
        store.settings.defaultUnit = .custom(label: "reps")
        store.settings.keepScreenAwake = true
        store.settings.confirmReset = false
        store.settings.allowNegative = true

        let added = store.add()
        var edited = added
        edited.value = decimal("12.5")
        edited.theme = .pool
        edited.unit = .time
        store.update(edited)
        store.increment(id: edited.id)
        store.flush()

        let reloaded = CounterStore(fileURL: url, createDefaultIfEmpty: false)
        let counter = try #require(reloaded.counters.first)
        #expect(reloaded.counters.count == 1)
        #expect(counter.id == edited.id)
        #expect(counter.value == decimal("412.5"))
        #expect(counter.step == 400)
        #expect(counter.theme == .pool)
        #expect(counter.unit == .time)
        #expect(counter.layout == .plusWithSmallMinus)
        #expect(reloaded.settings == store.settings)
    }

    @Test func aCorruptFileStartsOverAndKeepsABackup() {
        let url = temporaryFileURL()
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? Data("not json".utf8).write(to: url)

        let store = CounterStore(fileURL: url, createDefaultIfEmpty: true)
        #expect(store.counters.count == 1)
        #expect(store.counters[0].name == "Counter")
        #expect(FileManager.default.fileExists(atPath: url.appendingPathExtension("bak").path))
    }
}

@MainActor
private func makeStore(createDefault: Bool) -> CounterStore {
    let store = CounterStore(fileURL: temporaryFileURL(), createDefaultIfEmpty: createDefault)
    store.settings.hapticsEnabled = false
    return store
}

private func temporaryFileURL() -> URL {
    FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
        .appendingPathComponent("counters.json")
}

private func decimal(_ string: String) -> Decimal {
    Decimal(string: string, locale: Locale(identifier: "en_US_POSIX"))!
}
