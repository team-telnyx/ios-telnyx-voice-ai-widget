//
//  ExpandedWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Expanded widget component during active call
struct ExpandedWidget: View {
    let settings: WidgetSettings
    let isConnected: Bool
    let isMuted: Bool
    let agentStatus: AgentStatus
    let audioLevels: [Float]
    let onToggleMute: () -> Void
    let onEndCall: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Status text
                    Text(statusText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    // Audio visualizer
                    if isConnected && !audioLevels.isEmpty {
                        AudioVisualizer(audioLevels: audioLevels, color: .blue)
                    }
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 12) {
                    // Mute button
                    Button(action: onToggleMute) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 16))
                            .foregroundColor(isMuted ? .red : .blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // End call button
                    Button(action: onEndCall) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch agentStatus {
        case .idle:
            return .gray
        case .thinking:
            return .orange
        case .waiting:
            return .green
        }
    }
    
    private var statusText: String {
        if !isConnected {
            return "Connecting..."
        }
        
        switch agentStatus {
        case .idle:
            return "AI Assistant - Idle"
        case .thinking:
            return "AI Assistant - Thinking..."
        case .waiting:
            return "AI Assistant - Listening"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ExpandedWidget(
            settings: WidgetSettings(),
            isConnected: true,
            isMuted: false,
            agentStatus: .waiting,
            audioLevels: Array(0..<20).map { _ in Float.random(in: 0...1) },
            onToggleMute: {},
            onEndCall: {},
            onTap: {}
        )
        
        ExpandedWidget(
            settings: WidgetSettings(),
            isConnected: true,
            isMuted: true,
            agentStatus: .thinking,
            audioLevels: [],
            onToggleMute: {},
            onEndCall: {},
            onTap: {}
        )
    }
    .padding()
}