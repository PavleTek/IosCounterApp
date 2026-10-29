//
//  CounterItem.swift
//  Counter
//

import Foundation

struct CounterItem: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    @StoredDecimal var value: Decimal
    @StoredDecimal var step: Decimal
    var layout: CounterLayout
    var theme: CounterTheme?
    var unit: CounterUnit
    var createdAt: Date

    var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled" : trimmed
    }

    func resolvedTheme(using settings: AppSettings) -> CounterTheme {
        theme ?? settings.defaultTheme
    }
}
