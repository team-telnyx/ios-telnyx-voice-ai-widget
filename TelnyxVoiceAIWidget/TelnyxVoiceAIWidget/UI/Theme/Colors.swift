//
//  Colors.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Color palette matching Android Material 3 design
extension Color {
    // MARK: - Primary Colors

    /// Indigo-500 - Primary action color
    static let primaryIndigo = Color(hex: "6366F1")

    /// Indigo-600 - Darker primary variant
    static let primaryIndigoDark = Color(hex: "4F46E5")

    // MARK: - Slate Colors (Neutral)

    /// Slate-50 - Lightest background
    static let slate50 = Color(hex: "F8FAFC")

    /// Slate-100 - Light surface variant
    static let slate100 = Color(hex: "F1F5F9")

    /// Slate-200 - Light text on dark
    static let slate200 = Color(hex: "E2E8F0")

    /// Slate-300 - Medium light variant
    static let slate300 = Color(hex: "CBD5E1")

    /// Slate-500 - Secondary color
    static let slate500 = Color(hex: "64748B")

    /// Slate-600 - Medium text
    static let slate600 = Color(hex: "475569")

    /// Slate-700 - Dark surface variant
    static let slate700 = Color(hex: "334155")

    /// Slate-800 - Dark text
    static let slate800 = Color(hex: "1E293B")

    /// Slate-900 - Darkest background
    static let slate900 = Color(hex: "0F172A")

    // MARK: - Theme Colors

    /// Widget surface color (light mode)
    static let widgetSurfaceLight = Color.white

    /// Widget surface color (dark mode)
    static let widgetSurfaceDark = slate800

    /// Widget background color (light mode)
    static let widgetBackgroundLight = slate50

    /// Widget background color (dark mode)
    static let widgetBackgroundDark = slate900

    /// Widget primary text (light mode)
    static let widgetTextLight = slate800

    /// Widget primary text (dark mode)
    static let widgetTextDark = slate200

    /// Widget secondary text (light mode)
    static let widgetSecondaryTextLight = slate600

    /// Widget secondary text (dark mode)
    static let widgetSecondaryTextDark = slate300

    // MARK: - Helper

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}