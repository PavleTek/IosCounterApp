//
//  CounterLayout.swift
//  Counter
//

import Foundation

enum CounterLayout: String, Codable, CaseIterable, Identifiable, Hashable {
    case bigPlus
    case plusMinusEqual
    case plusWithSmallMinus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bigPlus:
            "Big plus"
        case .plusMinusEqual:
            "Equal plus and minus"
        case .plusWithSmallMinus:
            "Plus with small minus"
        }
    }

    var detail: String {
        switch self {
        case .bigPlus:
            "A large plus button and reset."
        case .plusMinusEqual:
            "Plus and minus the same size, plus reset."
        case .plusWithSmallMinus:
            "A large plus, a smaller minus, and reset."
        }
    }
}
