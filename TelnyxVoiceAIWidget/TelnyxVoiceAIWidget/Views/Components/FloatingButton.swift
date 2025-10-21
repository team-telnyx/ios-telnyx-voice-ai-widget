//
//  FloatingButton.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Floating action button component for icon-only mode
struct FloatingButton: View {
    let settings: WidgetSettings
    let onClick: () -> Void
    var isError: Bool = false
    let buttonImageModifier: AnyView?

    var body: some View {
        Button(action: onClick) {
            ZStack {
                Circle()
                    .fill(isError ? Color.red : backgroundColor)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)

                if isError {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                } else if let logoIconUrl = settings.logoIconUrl, let url = URL(string: logoIconUrl) {
                    RemoteImageView(
                        url: url,
                        placeholder: Image(systemName: "person.circle.fill"),
                        width: 32,
                        height: 32
                    )
                    .clipShape(Circle())
                    .ifLet(buttonImageModifier) { view, modifier in
                        view.modifier(modifier)
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(iconColor)
                        .ifLet(buttonImageModifier) { view, modifier in
                            view.modifier(modifier)
                        }
                }
            }
        }
    }

    private var backgroundColor: Color {
        switch settings.theme?.lowercased() {
        case "dark":
            return Color.black
        case "light":
            return Color.white
        default:
            return Color.white
        }
    }

    private var iconColor: Color {
        switch settings.theme?.lowercased() {
        case "dark":
            return Color.white
        case "light":
            return .primaryIndigo
        default:
            return .primaryIndigo
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FloatingButton(
            settings: WidgetSettings(),
            onClick: {},
            isError: false,
            buttonImageModifier: nil
        )

        FloatingButton(
            settings: WidgetSettings(),
            onClick: {},
            isError: true,
            buttonImageModifier: nil
        )
    }
    .padding()
}