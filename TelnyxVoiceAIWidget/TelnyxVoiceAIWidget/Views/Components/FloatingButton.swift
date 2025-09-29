//
//  FloatingButton.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Floating action button component for icon-only mode
struct FloatingButton: View {
    let settings: WidgetSettings
    let onClick: () -> Void
    let isError: Bool
    let buttonImageModifier: AnyView?
    
    init(settings: WidgetSettings, 
         onClick: @escaping () -> Void,
         isError: Bool = false,
         buttonImageModifier: AnyView? = nil) {
        self.settings = settings
        self.onClick = onClick
        self.isError = isError
        self.buttonImageModifier = buttonImageModifier
    }
    
    var body: some View {
        Button(action: onClick) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
                    .modifier(buttonImageModifier ?? AnyView(EmptyView()))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundColor: Color {
        if isError {
            return .red
        }
        
        if let colorString = settings.buttonColor {
            return Color(hex: colorString) ?? .blue
        }
        return .blue
    }
    
    private var iconColor: Color {
        if let colorString = settings.textColor {
            return Color(hex: colorString) ?? .white
        }
        return .white
    }
    
    private var iconName: String {
        if isError {
            return "exclamationmark.triangle.fill"
        }
        return "mic.circle.fill"
    }
}

#Preview {
    VStack(spacing: 20) {
        FloatingButton(
            settings: WidgetSettings(
                buttonColor: "#007AFF",
                textColor: "#FFFFFF"
            ),
            onClick: {}
        )
        
        FloatingButton(
            settings: WidgetSettings(
                buttonColor: "#34C759",
                textColor: "#FFFFFF"
            ),
            onClick: {},
            isError: true
        )
    }
    .padding()
}