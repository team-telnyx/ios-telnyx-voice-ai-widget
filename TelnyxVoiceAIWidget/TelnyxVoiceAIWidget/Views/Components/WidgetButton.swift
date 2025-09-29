//
//  WidgetButton.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Widget button component for collapsed state
struct WidgetButton: View {
    let settings: WidgetSettings
    let onClick: () -> Void
    let buttonTextModifier: AnyView?
    let buttonImageModifier: AnyView?
    
    init(settings: WidgetSettings, 
         onClick: @escaping () -> Void,
         buttonTextModifier: AnyView? = nil,
         buttonImageModifier: AnyView? = nil) {
        self.settings = settings
        self.onClick = onClick
        self.buttonTextModifier = buttonTextModifier
        self.buttonImageModifier = buttonImageModifier
    }
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(textColor)
                    .modifier(buttonImageModifier ?? AnyView(EmptyView()))
                
                // Text
                Text(settings.buttonText ?? "Talk to AI Assistant")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                    .modifier(buttonTextModifier ?? AnyView(EmptyView()))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(buttonColor)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var buttonColor: Color {
        if let colorString = settings.buttonColor {
            return Color(hex: colorString) ?? .blue
        }
        return .blue
    }
    
    private var textColor: Color {
        if let colorString = settings.textColor {
            return Color(hex: colorString) ?? .white
        }
        return .white
    }
}

// Extension to create Color from hex string
extension Color {
    init?(hex: String) {
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
            return nil
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

#Preview {
    VStack(spacing: 20) {
        WidgetButton(
            settings: WidgetSettings(
                buttonText: "Talk to AI Assistant",
                buttonColor: "#007AFF",
                textColor: "#FFFFFF"
            ),
            onClick: {}
        )
        
        WidgetButton(
            settings: WidgetSettings(
                buttonText: "Custom Button",
                buttonColor: "#34C759",
                textColor: "#FFFFFF"
            ),
            onClick: {}
        )
    }
    .padding()
}