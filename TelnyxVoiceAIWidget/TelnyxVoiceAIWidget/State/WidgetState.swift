//
//  WidgetState.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import Foundation
import TelnyxRTC

/// Represents the different states of the AI Assistant Widget
public enum WidgetState: Equatable {

    /// Initial state before initialization
    case idle

    /// Loading state while initiating the call
    case loading

    /// Collapsed state showing the widget button
    case collapsed(settings: WidgetSettings)

    /// Loading state when initiating a call
    case connecting(settings: WidgetSettings)

    /// Expanded state during an active call
    case expanded(settings: WidgetSettings, isConnected: Bool, isMuted: Bool, agentStatus: AgentStatus)

    /// Full transcript view state
    case transcriptView(settings: WidgetSettings, isConnected: Bool, isMuted: Bool, agentStatus: AgentStatus)

    /// Error state
    case error(message: String, type: ErrorType)

    public static func == (lhs: WidgetState, rhs: WidgetState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.collapsed(let lhsSettings), .collapsed(let rhsSettings)):
            return lhsSettings == rhsSettings
        case (.connecting(let lhsSettings), .connecting(let rhsSettings)):
            return lhsSettings == rhsSettings
        case (.expanded(let lhsSettings, let lhsConnected, let lhsMuted, let lhsStatus),
              .expanded(let rhsSettings, let rhsConnected, let rhsMuted, let rhsStatus)):
            return lhsSettings == rhsSettings && lhsConnected == rhsConnected &&
                   lhsMuted == rhsMuted && lhsStatus == rhsStatus
        case (.transcriptView(let lhsSettings, let lhsConnected, let lhsMuted, let lhsStatus),
              .transcriptView(let rhsSettings, let rhsConnected, let rhsMuted, let rhsStatus)):
            return lhsSettings == rhsSettings && lhsConnected == rhsConnected &&
                   lhsMuted == rhsMuted && lhsStatus == rhsStatus
        case (.error(let lhsMessage, let lhsType), .error(let rhsMessage, let rhsType)):
            return lhsMessage == rhsMessage && lhsType == rhsType
        default:
            return false
        }
    }
}

/// Represents the agent's current status
public enum AgentStatus: Equatable {
    /// Agent is idle (no active conversation)
    case idle

    /// Agent is thinking/processing user input
    case thinking

    /// Agent is waiting and can be interrupted
    case waiting
}

/// Represents a transcript item in the conversation
public struct TranscriptItem: Identifiable, Equatable {
    public let id: String
    public let text: String
    public let isUser: Bool
    public let timestamp: Date

    public init(id: String, text: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

/// Error types that can occur in the widget
public enum ErrorType: Equatable {
    case initialization
    case connection
    case other
}

/// Widget settings received from Telnyx AI configuration
public struct WidgetSettings: Equatable {
    public let theme: String?
    public let buttonText: String?
    public let logoUrl: String?
    public let agentName: String?

    public init(theme: String? = nil, buttonText: String? = nil, logoUrl: String? = nil, agentName: String? = nil) {
        self.theme = theme
        self.buttonText = buttonText
        self.logoUrl = logoUrl
        self.agentName = agentName
    }
}