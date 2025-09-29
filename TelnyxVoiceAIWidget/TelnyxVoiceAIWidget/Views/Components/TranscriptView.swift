//
//  TranscriptView.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Full transcript view component
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
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with status and controls
                headerView
                
                Divider()
                
                // Transcript messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(transcriptItems) { item in
                                TranscriptMessageView(item: item)
                                    .id(item.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: transcriptItems.count) { _ in
                        if let lastItem = transcriptItems.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastItem.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input area
                inputArea
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !iconOnly {
                        Button("Collapse") {
                            onCollapse()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("End Call") {
                        onEndCall()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                if isConnected && !audioLevels.isEmpty {
                    AudioVisualizer(audioLevels: audioLevels, color: .blue)
                        .scaleEffect(0.8)
                }
            }
            
            Spacer()
            
            // Mute button
            Button(action: onToggleMute) {
                Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isMuted ? .red : .blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var inputArea: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: .constant(userInput))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .onSubmit {
                    onSendMessage()
                }
                .onChange(of: userInput) { newValue in
                    onUserInputChange(newValue)
                }
            
            Button(action: onSendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue))
            }
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
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

/// Individual transcript message view
struct TranscriptMessageView: View {
    let item: TranscriptItem
    
    var body: some View {
        HStack {
            if item.isUser {
                Spacer()
                messageContent
                    .background(Color.blue)
                    .foregroundColor(.white)
            } else {
                messageContent
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: item.isUser ? .trailing : .leading, spacing: 4) {
            Text(item.text)
                .font(.system(size: 16))
                .multilineTextAlignment(item.isUser ? .trailing : .leading)
            
            Text(DateFormatter.timeFormatter.string(from: item.timestamp))
                .font(.system(size: 12))
                .opacity(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.isUser ? Color.blue : Color(.systemGray5))
        )
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: item.isUser ? .trailing : .leading)
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    TranscriptView(
        settings: WidgetSettings(),
        transcriptItems: [
            TranscriptItem(id: "1", text: "Hello, how can I help you today?", isUser: false),
            TranscriptItem(id: "2", text: "I need help with my account", isUser: true),
            TranscriptItem(id: "3", text: "I'd be happy to help you with your account. What specific issue are you experiencing?", isUser: false)
        ],
        userInput: "",
        isConnected: true,
        isMuted: false,
        agentStatus: .waiting,
        audioLevels: Array(0..<20).map { _ in Float.random(in: 0...1) },
        onUserInputChange: { _ in },
        onSendMessage: {},
        onToggleMute: {},
        onEndCall: {},
        onCollapse: {},
        iconOnly: false
    )
}