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
                    .fill(isError ? Color.red : Color.accentColor)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 4)

                if isError {
                    Image(systemName: "exclamationmark.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                } else if let logoUrl = settings.logoUrl, let url = URL(string: logoUrl) {
                    RemoteImageView(
                        url: url,
                        placeholder: Image(systemName: "mic.circle.fill"),
                        width: 32,
                        height: 32
                    )
                    .foregroundColor(.white)
                    .if(buttonImageModifier != nil) { view in
                        buttonImageModifier!
                    }
                } else {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .if(buttonImageModifier != nil) { view in
                            buttonImageModifier!
                        }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FloatingButton(
            settings: WidgetSettings(
                theme: "light",
                buttonText: "Talk to AI",
                logoUrl: nil,
                agentName: "Assistant"
            ),
            onClick: {},
            isError: false,
            buttonImageModifier: nil
        )

        FloatingButton(
            settings: WidgetSettings(
                theme: "light",
                buttonText: "Talk to AI",
                logoUrl: nil,
                agentName: "Assistant"
            ),
            onClick: {},
            isError: true,
            buttonImageModifier: nil
        )
    }
    .padding()
}