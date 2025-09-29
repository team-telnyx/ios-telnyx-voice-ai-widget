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
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("Error")
                .font(.system(size: 22, weight: .bold))

            if type == .initialization {
                initializationErrorView
            } else {
                connectionErrorView
            }

            retryButton
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 8)
        .padding()
    }

    private var initializationErrorView: some View {
        VStack(spacing: 12) {
            Text("Failed to initialize the AI Assistant.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                Text("Please verify your Assistant ID in the ")
                    .foregroundColor(.secondary)

                Button(action: {
                    if let url = portalUrl {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Telnyx Portal")
                        .foregroundColor(.accentColor)
                        .underline()
                }

                Text(" and ensure it's properly configured.")
                    .foregroundColor(.secondary)
            }
            .font(.body)
            .multilineTextAlignment(.center)
        }
    }

    private var connectionErrorView: some View {
        Text(type == .connection
            ? "Connection error: \(message)"
            : "An error occurred: \(message)")
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
    }

    private var retryButton: some View {
        Button(action: onRetry) {
            Text("Retry")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
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