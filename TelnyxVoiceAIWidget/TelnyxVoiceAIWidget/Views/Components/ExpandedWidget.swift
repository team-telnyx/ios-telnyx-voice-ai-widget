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
    let customization: WidgetCustomization?
    let isConnected: Bool
    let isMuted: Bool
    let agentStatus: AgentStatus
    let audioLevels: [Float]
    let onToggleMute: () -> Void
    let onEndCall: () -> Void
    let onTap: () -> Void
    let expandedWidgetModifier: AnyView?

    private var colorResolver: ColorResolver {
        ColorResolver(customization: customization, settings: settings)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Audio Visualizer
                AudioVisualizer(
                    audioLevels: audioLevels,
                    colorScheme: colorResolver.audioVisualizerColor()
                )
                .frame(height: 60)

                // Status Text
                Text(agentStatusText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colorResolver.secondaryText())
                    .multilineTextAlignment(.center)

                // Control Buttons
                HStack(spacing: 16) {
                    // Mute button
                    Button(action: onToggleMute) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(colorResolver.muteButtonIcon(isMuted: isMuted))
                            .frame(width: 48, height: 48)
                            .background(colorResolver.muteButtonBackground(isMuted: isMuted))
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
            .background(colorResolver.widgetSurface())
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .ifLet(expandedWidgetModifier) { view, modifier in
            view.modifier(modifier)
        }
    }

    private var agentStatusText: String {
        switch agentStatus {
        case .idle:
            return "Idle"
        case .thinking:
            return settings.agentThinkingText ?? "Thinking..."
        case .waiting:
            return settings.speakToInterruptText ?? "Speak to interrupt"
        }
    }
}

#Preview {
    ExpandedWidget(
        settings: WidgetSettings(),
        customization: nil,
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
