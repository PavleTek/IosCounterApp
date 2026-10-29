//
//  UnitFormatter.swift
//  Counter
//

import Foundation

enum UnitFormatter {
    static func format(value: Decimal, unit: CounterUnit) -> String {
        let magnitude = abs(value)
        let rung = unit.ladder.last(where: { magnitude >= $0.threshold }) ?? unit.ladder[0]
        let scaled = magnitude / rung.divisor
        let number = formatQuantity(scaled)
        let signed = value < 0 ? "-\(number)" : number
        if rung.symbol.isEmpty {
            return signed
        }
        return "\(signed) \(rung.symbol)"
    }

    /// Up to two fraction digits, with trailing zeros removed. Uses a fixed locale so the text is stable.
    static func formatQuantity(_ value: Decimal) -> String {
        var input = value
        var rounded = Decimal()
        NSDecimalRound(&rounded, &input, 2, .plain)
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: rounded as NSDecimalNumber) ?? "0"
    }
}
