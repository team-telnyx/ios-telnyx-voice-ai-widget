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
                if let logoIconUrl = settings.logoIconUrl, let url = URL(string: logoIconUrl) {
                    RemoteImageView(
                        url: url,
                        placeholder: Image(systemName: "person.circle.fill"),
                        width: 32,
                        height: 32
                    )
                    .clipShape(Circle())
                    .if(buttonImageModifier != nil) { view in
                        buttonImageModifier!
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.primaryIndigo)
                        .if(buttonImageModifier != nil) { view in
                            buttonImageModifier!
                        }
                }

                Text(settings.startCallText ?? "Let's chat")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.widgetTextLight)
                    .if(buttonTextModifier != nil) { view in
                        buttonTextModifier!
                    }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        .if(widgetButtonModifier != nil) { view in
            widgetButtonModifier!
        }
    }
}

#Preview {
    WidgetButton(
        settings: WidgetSettings(),
        onClick: {},
        widgetButtonModifier: nil,
        buttonTextModifier: nil,
        buttonImageModifier: nil
    )
    .padding()
}