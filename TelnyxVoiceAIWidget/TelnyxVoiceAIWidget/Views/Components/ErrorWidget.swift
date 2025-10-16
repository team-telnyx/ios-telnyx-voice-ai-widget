//
//  ErrorWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Error widget component
struct ErrorWidget: View {
    let message: String
    let type: ErrorType
    let assistantId: String
    let onRetry: () -> Void

    private var portalUrl: URL? {
        URL(string: "https://portal.telnyx.com/#/ai/assistants/edit/\(assistantId)?tab=telephony")
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 32))
                .foregroundColor(.red)

            Text("An error occurred")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.widgetTextLight)

            if type == .initialization {
                initializationErrorView
            } else {
                connectionErrorView
            }

            retryButton
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.red, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    private var initializationErrorView: some View {
        VStack(spacing: 8) {
            Text("Failed to initialize the AI Assistant.")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(.widgetSecondaryTextLight)

            HStack(spacing: 0) {
                Text("Please verify your Assistant ID in the ")
                    .foregroundColor(.widgetSecondaryTextLight)

                Button(action: {
                    if let url = portalUrl {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Telnyx Portal")
                        .foregroundColor(.primaryIndigo)
                        .underline()
                }

                Text(" and ensure it's properly configured.")
                    .foregroundColor(.widgetSecondaryTextLight)
            }
            .font(.system(size: 14))
            .multilineTextAlignment(.center)
        }
    }

    private var connectionErrorView: some View {
        Text(type == .connection
            ? "Connection error: \(message)"
            : "An error occurred: \(message)")
            .font(.system(size: 14))
            .multilineTextAlignment(.center)
            .foregroundColor(.widgetSecondaryTextLight)
    }

    private var retryButton: some View {
        Button(action: onRetry) {
            Text("Retry")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.red)
                .cornerRadius(8)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ErrorWidget(
            message: "",
            type: .initialization,
            assistantId: "assistant-b26afd32-84a9-4c09-8346-b667002d0d63",
            onRetry: {}
        )

        ErrorWidget(
            message: "Network connection failed",
            type: .connection,
            assistantId: "assistant-test",
            onRetry: {}
        )
    }
}