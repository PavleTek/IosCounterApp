//
//  CounterTheme.swift
//  Counter
//

import CoreGraphics
import Foundation
import SwiftUI
import UIKit

struct RGBAColor: Codable, Hashable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    var isDark: Bool {
        relativeLuminance < 0.45
    }

    var readableText: Color {
        isDark ? .white : .black
    }

    init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    init(_ color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.init(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
            return
        }
        if let converted = uiColor.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil),
           let components = converted.components,
           components.count >= 3 {
            let opacity = components.count > 3 ? components[3] : 1
            self.init(
                red: Double(components[0]),
                green: Double(components[1]),
                blue: Double(components[2]),
                opacity: Double(opacity)
            )
            return
        }
        self.init(red: 0, green: 0, blue: 0, opacity: 1)
    }

    static func hex(_ value: UInt32, opacity: Double = 1) -> RGBAColor {
        RGBAColor(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: opacity
        )
    }

    private var relativeLuminance: Double {
        func channel(_ value: Double) -> Double {
            value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
    }
}

struct CounterTheme: Codable, Hashable {
    var name: String?
    var background: RGBAColor
    var foreground: RGBAColor
    var accent: RGBAColor

    static let ocean = CounterTheme(
        name: "Ocean",
        background: .hex(0x0B3A5B),
        foreground: .hex(0xF4FBFF),
        accent: .hex(0x3DDCFF)
    )

    static let pool = CounterTheme(
        name: "Pool",
        background: .hex(0x0E6B6B),
        foreground: .hex(0xF3FFFE),
        accent: .hex(0x7CFFB2)
    )

    static let track = CounterTheme(
        name: "Track",
        background: .hex(0x1A120B),
        foreground: .hex(0xFFF7EF),
        accent: .hex(0xFF6B2C)
    )

    static let forest = CounterTheme(
        name: "Forest",
        background: .hex(0x143024),
        foreground: .hex(0xF3FFF6),
        accent: .hex(0x8BE37A)
    )

    static let sunset = CounterTheme(
        name: "Sunset",
        background: .hex(0x3D1A4A),
        foreground: .hex(0xFFF5F8),
        accent: .hex(0xFF8A5B)
    )

    static let grape = CounterTheme(
        name: "Grape",
        background: .hex(0x2A1848),
        foreground: .hex(0xF8F4FF),
        accent: .hex(0xC084FC)
    )

    static let monoDark = CounterTheme(
        name: "Mono Dark",
        background: .hex(0x111111),
        foreground: .hex(0xF5F5F5),
        accent: .hex(0xE6E6E6)
    )

    static let monoLight = CounterTheme(
        name: "Mono Light",
        background: .hex(0xF7F4EF),
        foreground: .hex(0x1C1C1C),
        accent: .hex(0x2F5D50)
    )

    static let presets: [CounterTheme] = [
        .ocean, .pool, .track, .forest, .sunset, .grape, .monoDark, .monoLight,
    ]
}
