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

    // MARK: - Public Properties
    /// Custom color configuration that takes priority over socket-received theme
    public var customization: WidgetCustomization?

    // MARK: - Private Properties
    private var iconOnly: Bool = false
    private var isConnected: Bool = false
    private var isMuted: Bool = false
    private var currentCall: Call?
    private var telnyxClient: TxClient?
    private var cancellables = Set<AnyCancellable>()
    private var assistantId: String = ""
    private var previousAudioLevel: Float = 0.0

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
    ///   - customization: Optional custom colors that override theme-based colors
    public func initialize(assistantId: String, iconOnly: Bool = false, customization: WidgetCustomization? = nil) {
        self.assistantId = assistantId
        self.iconOnly = iconOnly
        self.customization = customization

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
                    callId: UUID(),
                    debug: true  // Enable debug to get quality metrics
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

        if isMuted {
            currentCall?.muteAudio()
        } else {
            currentCall?.unmuteAudio()
        }
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
        audioLevels = []
        previousAudioLevel = 0.0
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
        currentCall?.onCallQualityChange = { [weak self] metrics in
            Task { @MainActor in
                self?.updateAudioLevels(from: metrics)
            }
        }
    }

    private func updateAudioLevels(from metrics: CallQualityMetrics?) {
        guard let metrics = metrics else {
            // Clear levels when no metrics
            audioLevels = []
            previousAudioLevel = 0.0
            return
        }

        // Scale the audio level for better visualization (make it more sensitive)
        // Remote audio level is typically 0.0 to 1.0, we scale by 4x for visibility
        let rawLevel = min(1.0, metrics.inboundAudioLevel * 4.0)

        // Apply smoothing to prevent jarring jumps but keep responsiveness
        let smoothedLevel = smoothAudioLevel(current: rawLevel, previous: previousAudioLevel)
        previousAudioLevel = smoothedLevel

        // Update audio levels array with 10 values for the visualizer
        // Create a frequency-band effect by varying the level slightly
        var levels: [Float] = []
        for index in 0..<10 {
            let normalizedIndex = Float(index) / 9.0
            let frequencyWeight = 1.0 - (normalizedIndex * 0.6) // Lower frequencies show more
            let randomVariation = Float.random(in: 0.8...1.2)
            let level = smoothedLevel * frequencyWeight * randomVariation
            levels.append(level > 0.05 ? min(1.0, level) : 0.0)
        }

        audioLevels = levels
    }

    private func smoothAudioLevel(current: Float, previous: Float) -> Float {
        if current > previous {
            // Quick response to new audio input
            let quickResponseFactor: Float = 0.1
            return previous * quickResponseFactor + current * (1.0 - quickResponseFactor)
        } else {
            // Slightly slower decay for natural look
            let slowDecayFactor: Float = 0.4
            return previous * slowDecayFactor + current * (1.0 - slowDecayFactor)
        }
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

    private func updateWidgetSettings(_ newSettings: WidgetSettings) {
        // Update the published widgetSettings property
        widgetSettings = newSettings

        // Update current state with new settings
        switch widgetState {
        case .idle, .loading:
            // Initial state transitions will use the new settings
            break
        case .collapsed:
            widgetState = .collapsed(settings: newSettings)
        case .connecting:
            widgetState = .connecting(settings: newSettings)
        case .expanded(_, let isConnected, let isMuted, let agentStatus):
            widgetState = .expanded(settings: newSettings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
        case .transcriptView(_, let isConnected, let isMuted, let agentStatus):
            widgetState = .transcriptView(settings: newSettings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
        case .error:
            // Don't update settings during error state
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
            // Extract params from message
            guard let params = message["params"] as? [String: Any] else { return }

            // Extract and update widget settings if present
            if let widgetSettingsDict = params["widget_settings"] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: widgetSettingsDict)
                    let settings = try JSONDecoder().decode(WidgetSettings.self, from: jsonData)
                    updateWidgetSettings(settings)
                } catch {
                    print("Failed to parse widget settings: \(error)")
                }
            }

            // Extract type from message for agent status updates
            if let type = params["type"] as? String {
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
            // Note: TelnyxRTC.AudioVisualizerConfig might be a different type, so we create our own
            let audioConfig: AudioVisualizerConfig? = {
                if settings.audioVisualizerConfig != nil {
                    // For now, just create a default config when present
                    return AudioVisualizerConfig(enabled: true, type: "waveform")
                }
                return nil
            }()

            let convertedSettings = WidgetSettings(
                agentThinkingText: settings.agentThinkingText,
                audioVisualizerConfig: audioConfig,
                defaultState: settings.defaultState,
                giveFeedbackUrl: settings.giveFeedbackUrl,
                logoIconUrl: settings.logoIconUrl,
                position: settings.position,
                reportIssueUrl: settings.reportIssueUrl,
                speakToInterruptText: settings.speakToInterruptText,
                startCallText: settings.startCallText,
                theme: settings.theme,
                viewHistoryUrl: settings.viewHistoryUrl
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