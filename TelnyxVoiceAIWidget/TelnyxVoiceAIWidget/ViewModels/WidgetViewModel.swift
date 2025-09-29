//
//  WidgetViewModel.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import Foundation
import Combine
import TelnyxRTC
import AVFoundation

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
    private var assistantId: String = ""

    // MARK: - Initialization
    public init() {}

    deinit {
        // Cleanup synchronously since deinit is not async
        telnyxClient?.aiAssistantManager.delegate = nil
        telnyxClient = nil
    }

    // MARK: - Public Methods

    /// Initialize the widget with assistant ID
    /// - Parameters:
    ///   - assistantId: The Assistant ID from your Telnyx AI configuration
    ///   - iconOnly: When true, displays as a floating action button
    public func initialize(assistantId: String, iconOnly: Bool = false) {
        self.assistantId = assistantId
        self.iconOnly = iconOnly

        widgetState = .loading

        telnyxClient = TxClient()

        // Set up delegates
        telnyxClient?.aiAssistantManager.delegate = self
        telnyxClient?.delegate = self

        // Use anonymous login for AI Assistant connections
        telnyxClient?.anonymousLogin(
            targetId: assistantId,
            targetType: "ai_assistant",
            targetVersionId: nil
        )

        // Start observing transcript updates
        observeTranscriptUpdates()
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

    private func observeTranscriptUpdates() {
        guard let aiAssistantManager = telnyxClient?.aiAssistantManager else { return }

        // Subscribe to transcript updates using the publisher
        let cancellable = aiAssistantManager.subscribeToTranscriptUpdates { [weak self] updatedTranscriptions in
            Task { @MainActor in
                // Convert TelnyxRTC.TranscriptionItem to our TranscriptItem
                self?.transcriptItems = updatedTranscriptions.map { item in
                    TranscriptItem(
                        id: item.id,
                        text: item.content,
                        isUser: item.role.lowercased() == "user",
                        timestamp: item.timestamp
                    )
                }
            }
        }
        // Store cancellable (note: TranscriptCancellable auto-cancels on deinit)
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

    private func handleCallStateChange(_ callState: CallState) {
        switch callState {
        case .ACTIVE:
            // Call is connected and active
            isConnected = true

            // Enable audio session when call becomes active
            enableAudioSession()

            guard case .connecting(let settings) = widgetState else { return }

            if iconOnly {
                // In icon-only mode, skip Expanded state and go directly to TranscriptView
                widgetState = .transcriptView(settings: settings, isConnected: true, isMuted: false, agentStatus: .waiting)
            } else {
                // In regular mode, transition to Expanded state
                widgetState = .expanded(settings: settings, isConnected: true, isMuted: false, agentStatus: .waiting)
            }

        case .DONE:
            // Call ended
            isConnected = false

            // Disable audio session when call ends
            disableAudioSession()

            if case .expanded = widgetState {
                widgetState = .collapsed(settings: widgetSettings)
            } else if case .transcriptView = widgetState {
                widgetState = .collapsed(settings: widgetSettings)
            }

        default:
            break
        }
    }

    private func enableAudioSession() {
        telnyxClient?.enableAudioSession(audioSession: AVAudioSession.sharedInstance())
    }

    private func disableAudioSession() {
        telnyxClient?.disableAudioSession(audioSession: AVAudioSession.sharedInstance())
    }
}

// MARK: - AIAssistantManagerDelegate
extension WidgetViewModel: AIAssistantManagerDelegate {
    nonisolated public func onAIConversationMessage(_ message: [String : Any]) {
        Task { @MainActor in
            // Extract type from message for agent status updates
            if let params = message["params"] as? [String: Any],
               let type = params["type"] as? String {
                handleAIConversation(type: type)
            }
        }
    }

    nonisolated public func onRingingAckReceived(callId: String) {
        // Handle ringing acknowledgment if needed
    }

    nonisolated public func onAIAssistantConnectionStateChanged(isConnected: Bool, targetId: String?) {
        Task { @MainActor in
            self.isConnected = isConnected

            if isConnected {
                // Connection established, transition to collapsed state
                widgetState = .collapsed(settings: widgetSettings)
            } else {
                // Connection lost
                if widgetState != .idle && widgetState != .loading {
                    widgetState = .error(message: "Connection lost", type: .connection)
                }
            }
        }
    }

    nonisolated public func onTranscriptionUpdated(_ transcriptions: [TelnyxRTC.TranscriptionItem]) {
        Task { @MainActor in
            // Convert TelnyxRTC.TranscriptionItem to our TranscriptItem
            self.transcriptItems = transcriptions.map { item in
                TranscriptItem(
                    id: item.id,
                    text: item.content,
                    isUser: item.role.lowercased() == "user",
                    timestamp: item.timestamp
                )
            }
        }
    }

    nonisolated public func onWidgetSettingsUpdated(_ settings: TelnyxRTC.WidgetSettings) {
        Task { @MainActor in
            // Convert TelnyxRTC.WidgetSettings to our WidgetSettings
            let convertedSettings = WidgetSettings(
                theme: settings.theme,
                buttonText: settings.startCallText,
                logoUrl: settings.logoIconUrl,
                agentName: nil
            )
            self.widgetSettings = convertedSettings

            // If we're in loading state, transition to collapsed now that we have settings
            if case .loading = widgetState {
                widgetState = .collapsed(settings: convertedSettings)
            }
        }
    }
}

// MARK: - TxClientDelegate
extension WidgetViewModel: TxClientDelegate {
    nonisolated public func onCallStateUpdated(callState: CallState, callId: UUID) {
        Task { @MainActor in
            handleCallStateChange(callState)
        }
    }

    nonisolated public func onSessionUpdated(sessionId: String) {
        // Not needed for widget
    }

    nonisolated public func onIncomingCall(call: Call) {
        // Widget only makes outbound calls
    }

    nonisolated public func onPushCall(call: Call) {
        // Not applicable for widget
    }

    nonisolated public func onRemoteCallEnded(callId: UUID, reason: CallTerminationReason?) {
        Task { @MainActor in
            handleCallStateChange(.DONE(reason: reason))
        }
    }

    nonisolated public func onSocketConnected() {
        // Already handled by AIAssistantManagerDelegate
    }

    nonisolated public func onSocketDisconnected() {
        // Already handled by AIAssistantManagerDelegate
    }

    nonisolated public func onClientError(error: Error) {
        Task { @MainActor in
            widgetState = .error(message: error.localizedDescription, type: .connection)
        }
    }

    nonisolated public func onClientReady() {
        // Already handled by AIAssistantManagerDelegate
    }

    nonisolated public func onPushDisabled(success: Bool, message: String) {
        // Not applicable for widget
    }
}