//
//  TranscriptView.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import SwiftUI
import Combine

/// Full-screen transcript view component
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
        NavigationView {
            VStack(spacing: 0) {
                // Header with audio visualizer
                VStack(spacing: 12) {
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

                        if isConnected {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                        }
                    }

                    AudioVisualizer(audioLevels: audioLevels)
                        .frame(height: 40)
                }
                .padding()
                .background(Color(.systemGray6))

                // Transcript messages
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(transcriptItems) { item in
                            TranscriptMessageBubble(item: item)
                        }
                    }
                    .padding()
                }

                Divider()

                // Input area
                HStack(spacing: 12) {
                    TextField("Type a message...", text: Binding(
                        get: { userInput },
                        set: { onUserInputChange($0) }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isConnected)

                    Button(action: onSendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(userInput.isEmpty ? .gray : .accentColor)
                    }
                    .disabled(userInput.isEmpty || !isConnected)
                }
                .padding()
                .background(Color(.systemBackground))

                // Bottom controls
                HStack(spacing: 24) {
                    Button(action: onToggleMute) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 22))
                            .foregroundColor(isMuted ? .red : .primary)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }

                    Button(action: onEndCall) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationBarItems(
                leading: !iconOnly ? Button(action: onCollapse) {
                    Image(systemName: "chevron.down")
                } : nil,
                trailing: EmptyView()
            )
            .navigationBarTitle("Conversation", displayMode: .inline)
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

/// Individual message bubble in the transcript
struct TranscriptMessageBubble: View {
    let item: TranscriptItem

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: item.timestamp)
    }

    var body: some View {
        HStack {
            if item.isUser {
                Spacer()
            }

            VStack(alignment: item.isUser ? .trailing : .leading, spacing: 4) {
                Text(item.text)
                    .padding(12)
                    .background(item.isUser ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(item.isUser ? .white : .primary)
                    .cornerRadius(16)

                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            if !item.isUser {
                Spacer()
            }
        }
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