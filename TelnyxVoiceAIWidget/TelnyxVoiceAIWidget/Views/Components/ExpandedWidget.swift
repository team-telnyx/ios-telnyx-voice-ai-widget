//
//  ExpandedWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI

/// Expanded widget component showing active call controls and audio visualizer
struct ExpandedWidget: View {
    let settings: WidgetSettings
    let isConnected: Bool
    let isMuted: Bool
    let agentStatus: AgentStatus
    let audioLevels: [Float]
    let onToggleMute: () -> Void
    let onEndCall: () -> Void
    let onTap: () -> Void
    let expandedWidgetModifier: AnyView?

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                if let logoUrl = settings.logoUrl, let url = URL(string: logoUrl) {
                    RemoteImageView(
                        url: url,
                        placeholder: Image(systemName: "mic.circle.fill"),
                        width: 40,
                        height: 40
                    )
                    .foregroundColor(.accentColor)
                } else {
                    Image(systemName: "mic.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.agentName ?? "AI Assistant")
                        .font(.headline)

                    Text(agentStatusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Connection indicator
                if isConnected {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                }
            }

            // Audio Visualizer
            AudioVisualizer(audioLevels: audioLevels)
                .frame(height: 60)

            // Controls
            HStack(spacing: 24) {
                // Mute button
                Button(action: onToggleMute) {
                    Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 22))
                        .foregroundColor(isMuted ? .red : .primary)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }

                // End call button
                Button(action: onEndCall) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.red)
                        .clipShape(Circle())
                }

                // Expand button
                Button(action: onTap) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 22))
                        .foregroundColor(.primary)
                        .frame(width: 50, height: 50)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(24)
        .shadow(radius: 8)
        .if(expandedWidgetModifier != nil) { view in
            expandedWidgetModifier!
        }
    }

    private var agentStatusText: String {
        switch agentStatus {
        case .idle:
            return "Idle"
        case .thinking:
            return "Thinking..."
        case .waiting:
            return "Listening"
        }
    }
}

#Preview {
    ExpandedWidget(
        settings: WidgetSettings(
            theme: "light",
            buttonText: "Talk to AI",
            logoUrl: nil,
            agentName: "AI Assistant"
        ),
        isConnected: true,
        isMuted: false,
        agentStatus: .waiting,
        audioLevels: [0.3, 0.5, 0.7, 0.5, 0.3],
        onToggleMute: {},
        onEndCall: {},
        onTap: {},
        expandedWidgetModifier: nil
    )
    .padding()
}