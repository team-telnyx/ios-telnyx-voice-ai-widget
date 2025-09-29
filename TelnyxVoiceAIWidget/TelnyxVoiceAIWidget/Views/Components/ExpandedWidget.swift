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
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Audio Visualizer
                AudioVisualizer(audioLevels: audioLevels)
                    .frame(height: 60)

                // Status Text
                Text(agentStatusText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.widgetSecondaryTextLight)
                    .multilineTextAlignment(.center)

                // Control Buttons
                HStack(spacing: 16) {
                    // Mute button
                    Button(action: onToggleMute) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isMuted ? .red : .primaryIndigo)
                            .frame(width: 48, height: 48)
                            .background(Color.slate100)
                            .clipShape(Circle())
                    }

                    // End call button
                    Button(action: onEndCall) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
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