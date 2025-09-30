//
//  TranscriptView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI
import Combine

/// Full-screen transcript view component matching Android implementation
struct TranscriptView: View {
    let settings: WidgetSettings
    let transcriptItems: [TranscriptItem]
    let userInput: String
    let isConnected: Bool
    let isMuted: Bool
    let agentStatus: AgentStatus
    let audioLevels: [Float]
    let onUserInputChange: (String) -> Void
    let onSendMessage: () -> Void
    let onToggleMute: () -> Void
    let onEndCall: () -> Void
    let onCollapse: () -> Void
    let iconOnly: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with controls
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        // Collapse button (only in regular mode)
                        if !iconOnly {
                            Button(action: onCollapse) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.widgetTextLight)
                                    .frame(width: 40, height: 40)
                            }
                        }

                        Spacer()

                        // Mute button
                        Button(action: onToggleMute) {
                            Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isMuted ? .red : .widgetTextLight)
                                .frame(width: 40, height: 40)
                        }

                        // End call button
                        Button(action: onEndCall) {
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Audio visualizer and status
                    VStack(spacing: 8) {
                        AudioVisualizer(audioLevels: audioLevels)
                            .frame(height: 60)

                        Text(agentStatusText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.widgetSecondaryTextLight)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)

                // Transcript messages - iOS 13 compatible
                TranscriptScrollView(transcriptItems: transcriptItems)
                    .background(Color.slate50)

                Divider()

                // Message input area
                HStack(spacing: 12) {
                    TextField("Type a message...", text: Binding(
                        get: { userInput },
                        set: { onUserInputChange($0) }
                    ), onCommit: {
                        if !userInput.isEmpty && isConnected {
                            onSendMessage()
                        }
                    })
                    .foregroundColor(.widgetTextLight)
                    .padding(12)
                    .background(Color.slate100)
                    .cornerRadius(24)
                    .disabled(!isConnected)

                    Button(action: onSendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(userInput.isEmpty || !isConnected ? Color.slate300 : Color.primaryIndigo)
                    }
                    .disabled(userInput.isEmpty || !isConnected)
                }
                .padding(16)
                .background(Color.white)
            }
            .background(Color.white)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
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

/// iOS 13 compatible scroll view with auto-scroll to bottom
struct TranscriptScrollView: View {
    let transcriptItems: [TranscriptItem]

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(transcriptItems) { item in
                    TranscriptMessageBubble(item: item)
                }

                // Invisible anchor for scrolling to bottom
                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
            .padding(16)
        }
    }
}

/// Individual message bubble in the transcript
struct TranscriptMessageBubble: View {
    let item: TranscriptItem

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: item.timestamp)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if item.isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: item.isUser ? .trailing : .leading, spacing: 4) {
                Text(item.text)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(item.isUser ? Color.primaryIndigo : Color.slate100)
                    .foregroundColor(item.isUser ? .white : .widgetTextLight)
                    .cornerRadius(16, corners: item.isUser ?
                        [.topLeft, .topRight, .bottomLeft] :
                        [.topLeft, .topRight, .bottomRight])
                    .fixedSize(horizontal: false, vertical: true)

                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.6))
            }

            if !item.isUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// Helper for selective corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    TranscriptView(
        settings: WidgetSettings(
            theme: "light",
            buttonText: "Talk to AI",
            logoUrl: nil,
            agentName: "AI Assistant"
        ),
        transcriptItems: [
            TranscriptItem(id: "1", text: "Hello! How can I help you today?", isUser: false),
            TranscriptItem(id: "2", text: "I need help with my account", isUser: true),
            TranscriptItem(id: "3", text: "I'd be happy to help with your account. What specific issue are you experiencing?", isUser: false)
        ],
        userInput: "",
        isConnected: true,
        isMuted: false,
        agentStatus: .waiting,
        audioLevels: [0.3, 0.5, 0.7, 0.5, 0.3],
        onUserInputChange: { _ in },
        onSendMessage: {},
        onToggleMute: {},
        onEndCall: {},
        onCollapse: {},
        iconOnly: false
    )
}