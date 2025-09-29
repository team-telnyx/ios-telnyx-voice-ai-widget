//
//  WidgetButton.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Collapsed widget button component
struct WidgetButton: View {
    let settings: WidgetSettings
    let onClick: () -> Void
    let widgetButtonModifier: AnyView?
    let buttonTextModifier: AnyView?
    let buttonImageModifier: AnyView?

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                if let logoUrl = settings.logoUrl, let url = URL(string: logoUrl) {
                    RemoteImageView(
                        url: url,
                        placeholder: Image(systemName: "mic.circle.fill"),
                        width: 32,
                        height: 32
                    )
                    .if(buttonImageModifier != nil) { view in
                        buttonImageModifier!
                    }
                } else {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .if(buttonImageModifier != nil) { view in
                            buttonImageModifier!
                        }
                }

                Text(settings.buttonText ?? "Start Call")
                    .font(.headline)
                    .if(buttonTextModifier != nil) { view in
                        buttonTextModifier!
                    }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(24)
        }
        .if(widgetButtonModifier != nil) { view in
            widgetButtonModifier!
        }
    }
}

#Preview {
    WidgetButton(
        settings: WidgetSettings(
            theme: "light",
            buttonText: "Talk to AI Assistant",
            logoUrl: nil,
            agentName: "Assistant"
        ),
        onClick: {},
        widgetButtonModifier: nil,
        buttonTextModifier: nil,
        buttonImageModifier: nil
    )
    .padding()
}