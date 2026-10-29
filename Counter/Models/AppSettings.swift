//
//  AppSettings.swift
//  Counter
//

import Foundation

struct AppSettings: Codable, Hashable {
    var defaultTheme: CounterTheme
    @StoredDecimal var defaultStep: Decimal
    var defaultLayout: CounterLayout
    var defaultUnit: CounterUnit
    var hapticsEnabled: Bool
    var keepScreenAwake: Bool
    var confirmReset: Bool
    var allowNegative: Bool

    static let initial = AppSettings(
        defaultTheme: .ocean,
        defaultStep: 1,
        defaultLayout: .plusMinusEqual,
        defaultUnit: .none,
        hapticsEnabled: true,
        keepScreenAwake: false,
        confirmReset: true,
        allowNegative: false
    )
}
