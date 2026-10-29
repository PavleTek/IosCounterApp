//
//  DecimalParsing.swift
//  Counter
//

import Foundation

enum DecimalParsing {
    static func parse(_ text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil
        }
        if let value = Decimal(string: trimmed, locale: Locale(identifier: "en_US_POSIX")) {
            return value
        }
        return Decimal(string: trimmed, locale: .current)
    }
}
