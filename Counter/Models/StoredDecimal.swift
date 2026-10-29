//
//  StoredDecimal.swift
//  Counter
//

import Foundation

/// Decimal stored as a string so JSON keeps exact values such as 0.5.
@propertyWrapper
struct StoredDecimal: Codable, Hashable {
    var wrappedValue: Decimal

    init(wrappedValue: Decimal) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let decimal = Decimal(string: string, locale: Locale(identifier: "en_US_POSIX")) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected a decimal string."
            )
        }
        wrappedValue = decimal
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(NSDecimalNumber(decimal: wrappedValue).stringValue)
    }
}
