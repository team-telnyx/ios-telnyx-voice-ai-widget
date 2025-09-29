//
//  WidgetState.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
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
    case expanded(settings: WidgetSettings, isConnected: Bool = false, isMuted: Bool = false, agentStatus: AgentStatus = .waiting)
    
    /// Full transcript view state
    case transcriptView(settings: WidgetSettings, isConnected: Bool = false, isMuted: Bool = false, agentStatus: AgentStatus = .waiting)
    
    /// Error state
    case error(message: String, type: ErrorType)
    
    public static func == (lhs: WidgetState, rhs: WidgetState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.collapsed(lhsSettings), .collapsed(rhsSettings)):
            return lhsSettings == rhsSettings
        case let (.connecting(lhsSettings), .connecting(rhsSettings)):
            return lhsSettings == rhsSettings
        case let (.expanded(lhsSettings, lhsConnected, lhsMuted, lhsStatus), 
                  .expanded(rhsSettings, rhsConnected, rhsMuted, rhsStatus)):
            return lhsSettings == rhsSettings && lhsConnected == rhsConnected && 
                   lhsMuted == rhsMuted && lhsStatus == rhsStatus
        case let (.transcriptView(lhsSettings, lhsConnected, lhsMuted, lhsStatus), 
                  .transcriptView(rhsSettings, rhsConnected, rhsMuted, rhsStatus)):
            return lhsSettings == rhsSettings && lhsConnected == rhsConnected && 
                   lhsMuted == rhsMuted && lhsStatus == rhsStatus
        case let (.error(lhsMessage, lhsType), .error(rhsMessage, rhsType)):
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

/// Error types for the widget
public enum ErrorType: Equatable {
    case initialization
    case connection
    case other
}

/// Widget settings model to match Android implementation
public struct WidgetSettings: Equatable {
    public let theme: String?
    public let buttonText: String?
    public let buttonColor: String?
    public let textColor: String?
    public let iconUrl: String?
    
    public init(theme: String? = nil, 
                buttonText: String? = nil, 
                buttonColor: String? = nil, 
                textColor: String? = nil, 
                iconUrl: String? = nil) {
        self.theme = theme
        self.buttonText = buttonText
        self.buttonColor = buttonColor
        self.textColor = textColor
        self.iconUrl = iconUrl
    }
}