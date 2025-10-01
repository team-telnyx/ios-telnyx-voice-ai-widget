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
/// Note: Full definition is in Models/WidgetSettings.swift
/// This struct is kept here for backward compatibility but should import from Models
public struct WidgetSettings: Codable, Equatable {
    public let agentThinkingText: String?
    public let audioVisualizerConfig: AudioVisualizerConfig?
    public let defaultState: String?
    public let giveFeedbackUrl: String?
    public let logoIconUrl: String?
    public let position: String?
    public let reportIssueUrl: String?
    public let speakToInterruptText: String?
    public let startCallText: String?
    public let theme: String?
    public let viewHistoryUrl: String?

    enum CodingKeys: String, CodingKey {
        case agentThinkingText = "agent_thinking_text"
        case audioVisualizerConfig = "audio_visualizer_config"
        case defaultState = "default_state"
        case giveFeedbackUrl = "give_feedback_url"
        case logoIconUrl = "logo_icon_url"
        case position
        case reportIssueUrl = "report_issue_url"
        case speakToInterruptText = "speak_to_interrupt_text"
        case startCallText = "start_call_text"
        case theme
        case viewHistoryUrl = "view_history_url"
    }

    public init(
        agentThinkingText: String? = nil,
        audioVisualizerConfig: AudioVisualizerConfig? = nil,
        defaultState: String? = nil,
        giveFeedbackUrl: String? = nil,
        logoIconUrl: String? = nil,
        position: String? = nil,
        reportIssueUrl: String? = nil,
        speakToInterruptText: String? = nil,
        startCallText: String? = nil,
        theme: String? = nil,
        viewHistoryUrl: String? = nil
    ) {
        self.agentThinkingText = agentThinkingText
        self.audioVisualizerConfig = audioVisualizerConfig
        self.defaultState = defaultState
        self.giveFeedbackUrl = giveFeedbackUrl
        self.logoIconUrl = logoIconUrl
        self.position = position
        self.reportIssueUrl = reportIssueUrl
        self.speakToInterruptText = speakToInterruptText
        self.startCallText = startCallText
        self.theme = theme
        self.viewHistoryUrl = viewHistoryUrl
    }
}

/// Configuration for the audio visualizer
public struct AudioVisualizerConfig: Codable, Equatable {
    public let enabled: Bool?
    public let type: String?
    public let color: String?
    public let preset: String?

    enum CodingKeys: String, CodingKey {
        case enabled
        case type
        case color
        case preset
    }

    public init(enabled: Bool? = nil, type: String? = nil, color: String? = nil, preset: String? = nil) {
        self.enabled = enabled
        self.type = type
        self.color = color
        self.preset = preset
    }
}