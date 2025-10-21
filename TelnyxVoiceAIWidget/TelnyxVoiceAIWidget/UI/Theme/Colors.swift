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

    // MARK: - Audio Visualizer Gradient Colors

    /// Verdant gradient colors (default)
    static let verdantStart = Color(hex: "D3FFA6")
    static let verdantMid = Color(hex: "036B5B")
    static let verdantEnd = Color(hex: "D3FFA6")

    /// Twilight gradient colors
    static let twilightStart = Color(hex: "81B9FF")
    static let twilightMid = Color(hex: "371A5E")
    static let twilightEnd = Color(hex: "81B9FF")

    /// Bloom gradient colors
    static let bloomStart = Color(hex: "FFD4FE")
    static let bloomMid = Color(hex: "FD05F9")
    static let bloomEnd = Color(hex: "FFD4FE")

    /// Mystic gradient colors
    static let mysticStart = Color(hex: "1F023A")
    static let mysticMid = Color(hex: "CA76FF")
    static let mysticEnd = Color(hex: "1F023A")

    /// Flare gradient colors
    static let flareStart = Color(hex: "FFFFFF")
    static let flareMid = Color(hex: "FC5F00")
    static let flareEnd = Color(hex: "FFFFFF")

    /// Glacier gradient colors
    static let glacierStart = Color(hex: "4CE5F2")
    static let glacierMid = Color(hex: "005A98")
    static let glacierEnd = Color(hex: "4CE5F2")

    // MARK: - Transcript Colors

    /// Transcript background (light mode)
    static let transcriptBackgroundLight = Color(hex: "E6E3D3")

    /// Transcript background (dark mode)
    static let transcriptBackgroundDark = Color(hex: "38383C")

    /// User message bubble background (light mode)
    static let userBubbleLight = Color(hex: "FEFDF5")

    /// User message bubble background (dark mode)
    static let userBubbleDark = Color(hex: "222227")

    /// Mute button background (light mode)
    static let muteButtonLight = Color(hex: "E6E3D3")

    /// Mute button background (dark mode)
    static let muteButtonDark = Color(hex: "3C3C3C")

    /// Mute button active background (light mode)
    static let muteButtonActiveLight = Color(hex: "F36666")

    /// Mute button active background (dark mode)
    static let muteButtonActiveDark = Color(hex: "750000")

    // MARK: - Helper

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue:  Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

// MARK: - Color Priority Helper
/// Helper struct to resolve color priority: custom > socket theme > default
struct ColorResolver {
    let customization: WidgetCustomization?
    let settings: WidgetSettings

    private var isDarkTheme: Bool {
        settings.theme?.lowercased() == "dark"
    }

    // MARK: - Audio Visualizer

    func audioVisualizerColor() -> String {
        // Priority: customization > socket config > default
        if let customColor = customization?.audioVisualizerColor {
            return customColor
        }
        if let socketColor = settings.audioVisualizerConfig?.color {
            return socketColor
        }
        return "verdant" // default
    }

    // MARK: - Transcript View

    func transcriptBackground() -> Color {
        if let custom = customization?.transcriptBackgroundColor {
            return custom
        }
        return isDarkTheme ? .transcriptBackgroundDark : .transcriptBackgroundLight
    }

    func userBubbleBackground() -> Color {
        if let custom = customization?.userBubbleBackgroundColor {
            return custom
        }
        return isDarkTheme ? .userBubbleDark : .userBubbleLight
    }

    func agentBubbleBackground() -> Color {
        if let custom = customization?.agentBubbleBackgroundColor {
            return custom
        }
        return isDarkTheme ? .slate700 : .slate100
    }

    func userBubbleText() -> Color {
        if let custom = customization?.userBubbleTextColor {
            return custom
        }
        return isDarkTheme ? .white : .widgetTextLight
    }

    func agentBubbleText() -> Color {
        if let custom = customization?.agentBubbleTextColor {
            return custom
        }
        return isDarkTheme ? .white : .widgetTextLight
    }

    // MARK: - Widget Surface and Text

    func widgetSurface() -> Color {
        if let custom = customization?.widgetSurfaceColor {
            return custom
        }
        return isDarkTheme ? .widgetSurfaceDark : .white
    }

    func primaryText() -> Color {
        if let custom = customization?.primaryTextColor {
            return custom
        }
        return isDarkTheme ? .widgetTextDark : .widgetTextLight
    }

    func secondaryText() -> Color {
        if let custom = customization?.secondaryTextColor {
            return custom
        }
        return isDarkTheme ? .widgetSecondaryTextDark : .widgetSecondaryTextLight
    }

    func inputBackground() -> Color {
        if let custom = customization?.inputBackgroundColor {
            return custom
        }
        return isDarkTheme ? .slate800 : .slate100
    }

    // MARK: - Buttons

    func muteButtonBackground(isMuted: Bool) -> Color {
        if isMuted {
            if let custom = customization?.muteButtonActiveBackgroundColor {
                return custom
            }
            return isDarkTheme ? .muteButtonActiveDark : .muteButtonActiveLight
        } else {
            if let custom = customization?.muteButtonBackgroundColor {
                return custom
            }
            return isDarkTheme ? .muteButtonDark : .muteButtonLight
        }
    }

    func muteButtonIcon(isMuted: Bool) -> Color {
        if let custom = customization?.muteButtonIconColor {
            return custom
        }
        return isDarkTheme ? .white : .black
    }
}