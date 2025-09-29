//
//  WidgetViewModel.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import Foundation
import Combine
import TelnyxRTC

/// ViewModel for managing the AI Assistant Widget state and interactions
@MainActor
public class WidgetViewModel: ObservableObject {

    // MARK: - Constants
    private let aiAssistantDestination = "ai-assistant"
    private let maxLevels = 20

    // MARK: - Published Properties
    @Published public var widgetState: WidgetState = .idle
    @Published public var widgetSettings: WidgetSettings = WidgetSettings()
    @Published public var transcriptItems: [TranscriptItem] = []
    @Published public var userInput: String = ""
    @Published public var audioLevels: [Float] = []

    // MARK: - Private Properties
    private var iconOnly: Bool = false
    private var isConnected: Bool = false
    private var isMuted: Bool = false
    private var currentCall: Call?
    private var telnyxClient: TxClient?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    public init() {}

    // MARK: - Public Methods

    /// Initialize the widget with assistant ID
    /// - Parameters:
    ///   - assistantId: The Assistant ID from your Telnyx AI configuration
    ///   - iconOnly: When true, displays as a floating action button
    public func initialize(assistantId: String, iconOnly: Bool = false) {
        self.iconOnly = iconOnly

        Task {
            do {
                widgetState = .loading

                telnyxClient = TxClient()

                // Use anonymous login for AI Assistant connections
                telnyxClient?.anonymousLogin(
                    targetId: assistantId,
                    targetType: "ai_assistant",
                    targetVersionId: nil
                )

                // Start observing socket responses
                observeSocketResponses()

                // Start observing transcript updates
                observeTranscriptUpdates()

            } catch {
                widgetState = .error(message: "", type: .initialization)
            }
        }
    }

    /// Start a call to the AI assistant
    public func startCall() {
        guard case .collapsed(let settings) = widgetState else { return }

        widgetState = .connecting(settings: settings)

        Task {
            do {
                currentCall = try telnyxClient?.newCall(
                    callerName: "Anonymous User",
                    callerNumber: "anonymous",
                    destinationNumber: aiAssistantDestination,
                    callId: UUID()
                )

                // Observe call quality metrics for audio visualization
                observeCallQualityMetrics()

            } catch {
                widgetState = .error(message: error.localizedDescription, type: .connection)
            }
        }
    }

    /// End the current call
    public func endCall() {
        guard case .expanded(let settings, _, _, _) = widgetState else {
            if case .transcriptView(let settings, _, _, _) = widgetState {
                endCallCleanup(settings: settings)
                return
            }
            return
        }

        endCallCleanup(settings: settings)
    }

    /// Toggle mute state
    public func toggleMute() {
        isMuted.toggle()

        switch widgetState {
        case .expanded(let settings, let isConnected, _, let agentStatus):
            widgetState = .expanded(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
        case .transcriptView(let settings, let isConnected, _, let agentStatus):
            widgetState = .transcriptView(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
        default:
            break
        }

        currentCall?.muteAudio()
    }

    /// Expand to transcript view
    public func showTranscriptView() {
        guard case .expanded(let settings, let isConnected, let isMuted, let agentStatus) = widgetState else { return }

        widgetState = .transcriptView(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
    }

    /// Collapse from transcript view to expanded view
    public func collapseFromTranscriptView() {
        guard case .transcriptView(let settings, let isConnected, let isMuted, let agentStatus) = widgetState else { return }

        widgetState = .expanded(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
    }

    /// Update user input text
    public func updateUserInput(_ input: String) {
        userInput = input
    }

    /// Send user message
    public func sendMessage() {
        let message = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }

        Task {
            telnyxClient?.sendAIAssistantMessage(message)
            userInput = ""
        }
    }

    // MARK: - Private Methods

    private func endCallCleanup(settings: WidgetSettings) {
        if let call = currentCall {
            call.hangup()
            currentCall = nil
        }

        isConnected = false
        isMuted = false
        transcriptItems = []
        widgetState = .collapsed(settings: settings)
    }

    private func observeSocketResponses() {
        // TODO: Implement socket response observation when TxClient provides Combine publishers
        // This would observe connection status, errors, and various socket events
    }

    private func observeTranscriptUpdates() {
        // TODO: Implement transcript observation when TxClient provides transcript updates
        // This would populate the transcriptItems array
    }

    private func observeCallQualityMetrics() {
        // TODO: Implement call quality metrics observation for audio visualization
        // This would populate the audioLevels array with audio level data
    }

    private func updateAgentStatus(_ newStatus: AgentStatus) {
        switch widgetState {
        case .expanded(let settings, let isConnected, let isMuted, _):
            widgetState = .expanded(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: newStatus)
        case .transcriptView(let settings, let isConnected, let isMuted, _):
            widgetState = .transcriptView(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: newStatus)
        default:
            break
        }
    }

    // MARK: - Socket Response Handlers

    private func handleClientReady() {
        widgetState = .collapsed(settings: widgetSettings)
    }

    private func handleAnswer() {
        isConnected = true

        guard case .connecting(let settings) = widgetState else { return }

        if iconOnly {
            // In icon-only mode, skip Expanded state and go directly to TranscriptView
            widgetState = .transcriptView(settings: settings, isConnected: true, isMuted: false, agentStatus: .waiting)
        } else {
            // In regular mode, transition to Expanded state
            widgetState = .expanded(settings: settings, isConnected: true, isMuted: false, agentStatus: .waiting)
        }
    }

    private func handleBye() {
        isConnected = false

        if case .expanded = widgetState {
            widgetState = .collapsed(settings: widgetSettings)
        } else if case .transcriptView = widgetState {
            widgetState = .collapsed(settings: widgetSettings)
        }
    }

    private func handleAIConversation(type: String?) {
        guard let type = type else { return }

        let newAgentStatus: AgentStatus? = {
            switch type {
            case "conversation.item.created":
                return .thinking
            case "response.text.delta", "response.created":
                return .waiting
            case "response.done", "response.text.done":
                return .idle
            default:
                return nil
            }
        }()

        if let status = newAgentStatus {
            updateAgentStatus(status)
        }
    }
}