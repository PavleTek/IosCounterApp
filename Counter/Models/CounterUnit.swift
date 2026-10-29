//
//  CounterUnit.swift
//  Counter
//

import Foundation

struct UnitRung: Equatable {
    var threshold: Decimal
    var divisor: Decimal
    var symbol: String
}

enum UnitKind: String, CaseIterable, Identifiable, Hashable {
    case none
    case metricDistance
    case imperialDistance
    case weightMetric
    case time
    case volume
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:
            "None"
        case .metricDistance:
            "Meters"
        case .imperialDistance:
            "Yards"
        case .weightMetric:
            "Grams"
        case .time:
            "Seconds"
        case .volume:
            "Milliliters"
        case .custom:
            "Custom"
        }
    }
}

enum CounterUnit: Codable, Hashable {
    case none
    case metricDistance
    case imperialDistance
    case weightMetric
    case time
    case volume
    case custom(label: String)

    var kind: UnitKind {
        switch self {
        case .none:
            .none
        case .metricDistance:
            .metricDistance
        case .imperialDistance:
            .imperialDistance
        case .weightMetric:
            .weightMetric
        case .time:
            .time
        case .volume:
            .volume
        case .custom:
            .custom
        }
    }

    var customLabel: String {
        if case .custom(let label) = self {
            return label
        }
        return ""
    }

    /// Largest rung whose threshold is at or below the absolute value wins.
    var ladder: [UnitRung] {
        switch self {
        case .none:
            [UnitRung(threshold: 0, divisor: 1, symbol: "")]
        case .metricDistance:
            [
                UnitRung(threshold: 0, divisor: 1, symbol: "m"),
                UnitRung(threshold: 1000, divisor: 1000, symbol: "km"),
            ]
        case .imperialDistance:
            [
                UnitRung(threshold: 0, divisor: 1, symbol: "yd"),
                UnitRung(threshold: 1760, divisor: 1760, symbol: "mi"),
            ]
        case .weightMetric:
            [
                UnitRung(threshold: 0, divisor: 1, symbol: "g"),
                UnitRung(threshold: 1000, divisor: 1000, symbol: "kg"),
                UnitRung(threshold: 1_000_000, divisor: 1_000_000, symbol: "t"),
            ]
        case .time:
            [
                UnitRung(threshold: 0, divisor: 1, symbol: "s"),
                UnitRung(threshold: 60, divisor: 60, symbol: "min"),
                UnitRung(threshold: 3600, divisor: 3600, symbol: "h"),
            ]
        case .volume:
            [
                UnitRung(threshold: 0, divisor: 1, symbol: "mL"),
                UnitRung(threshold: 1000, divisor: 1000, symbol: "L"),
            ]
        case .custom(let label):
            [UnitRung(threshold: 0, divisor: 1, symbol: label)]
        }
    }

    var scalingDescription: String {
        switch self {
        case .none:
            "Shows the number with no unit."
        case .metricDistance:
            "Counts in meters and switches to kilometers from 1,000."
        case .imperialDistance:
            "Counts in yards and switches to miles from 1,760."
        case .weightMetric:
            "Counts in grams, then kilograms from 1,000 and tonnes from 1,000,000."
        case .time:
            "Counts in seconds, then minutes from 60 and hours from 3,600."
        case .volume:
            "Counts in milliliters and switches to liters from 1,000."
        case .custom:
            "Shows your label. The number does not scale."
        }
    }

    func replacingKind(_ kind: UnitKind, customLabel: String) -> CounterUnit {
        switch kind {
        case .none:
            .none
        case .metricDistance:
            .metricDistance
        case .imperialDistance:
            .imperialDistance
        case .weightMetric:
            .weightMetric
        case .time:
            .time
        case .volume:
            .volume
        case .custom:
            .custom(label: customLabel)
        }
    }
}
