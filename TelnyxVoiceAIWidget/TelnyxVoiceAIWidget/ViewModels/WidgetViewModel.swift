//
//  WidgetViewModel.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import Foundation
import SwiftUI
import Combine
import TelnyxRTC

/// ViewModel for managing the AI Assistant Widget state and interactions
@MainActor
public class WidgetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var widgetState: WidgetState = .idle
    @Published public var widgetSettings: WidgetSettings = WidgetSettings()
    @Published public var transcriptItems: [TranscriptItem] = []
    @Published public var userInput: String = ""
    @Published public var audioLevels: [Float] = []
    
    // MARK: - Private Properties
    private let aiAssistantDestination = "ai-assistant"
    private let maxLevels = 20
    private var iconOnly: Bool = false
    private var isConnected = false
    private var isMuted = false
    private var handlingResponses = false
    private var currentCall: Call?
    private var telnyxClient: TxClient?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    /// Initialize the widget with assistant ID
    public func initialize(assistantId: String, iconOnly: Bool = false) {
        self.iconOnly = iconOnly
        
        Task {
            do {
                widgetState = .loading
                
                // Initialize TelnyxRTC client
                let txConfig = TxConfig(
                    token: assistantId, // Using assistantId as token for now
                    logLevel: .all
                )
                
                telnyxClient = TxClient()
                
                // Set up delegates and observers
                setupTelnyxClientObservers()
                
                // Connect to Telnyx
                try telnyxClient?.connect(txConfig: txConfig)
                
                // Simulate widget settings loading (in real implementation, this would come from the server)
                widgetSettings = WidgetSettings(
                    theme: "auto",
                    buttonText: "Talk to AI Assistant",
                    buttonColor: "#007AFF",
                    textColor: "#FFFFFF",
                    iconUrl: nil
                )
                
                // Transition to collapsed state
                widgetState = .collapsed(settings: widgetSettings)
                
            } catch {
                widgetState = .error(message: error.localizedDescription, type: .initialization)
            }
        }
    }
    
    /// Start a call to the AI assistant
    public func startCall() {
        guard case let .collapsed(settings) = widgetState else { return }
        
        widgetState = .connecting(settings: settings)
        
        Task {
            do {
                // Create a new call
                currentCall = try telnyxClient?.newInvite(
                    callerName: "",
                    callerNumber: "",
                    destinationNumber: aiAssistantDestination,
                    callId: UUID().uuidString
                )
                
                // Set up call quality monitoring
                setupCallQualityMonitoring()
                
            } catch {
                widgetState = .error(message: error.localizedDescription, type: .connection)
            }
        }
    }
    
    /// End the current call
    public func endCall() {
        guard case let .expanded(settings, _, _, _) = widgetState || 
              case let .transcriptView(settings, _, _, _) = widgetState else { return }
        
        currentCall?.hangup()
        currentCall = nil
        
        isConnected = false
        isMuted = false
        transcriptItems = []
        audioLevels = []
        
        widgetState = .collapsed(settings: widgetSettings)
    }
    
    /// Toggle mute state
    public func toggleMute() {
        isMuted.toggle()
        currentCall?.muteUnmute()
        
        // Update current state with new mute status
        switch widgetState {
        case let .expanded(settings, isConnected, _, agentStatus):
            widgetState = .expanded(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
        case let .transcriptView(settings, isConnected, _, agentStatus):
            widgetState = .transcriptView(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: agentStatus)
        default:
            break
        }
    }
    
    /// Expand to transcript view
    public func showTranscriptView() {
        guard case let .expanded(settings, isConnected, isMuted, agentStatus) = widgetState else { return }
        
        widgetState = .transcriptView(
            settings: settings,
            isConnected: isConnected,
            isMuted: isMuted,
            agentStatus: agentStatus
        )
    }
    
    /// Collapse from transcript view to expanded view
    public func collapseFromTranscriptView() {
        guard case let .transcriptView(settings, isConnected, isMuted, agentStatus) = widgetState else { return }
        
        widgetState = .expanded(
            settings: settings,
            isConnected: isConnected,
            isMuted: isMuted,
            agentStatus: agentStatus
        )
    }
    
    /// Update user input text
    public func updateUserInput(_ input: String) {
        userInput = input
    }
    
    /// Send user message
    public func sendMessage() {
        let message = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        // Add user message to transcript
        let userTranscript = TranscriptItem(
            id: UUID().uuidString,
            text: message,
            isUser: true
        )
        transcriptItems.append(userTranscript)
        
        // Send message via TelnyxRTC (implementation depends on SDK capabilities)
        // For now, we'll simulate sending the message
        
        // Clear input
        userInput = ""
        
        // Simulate AI response (in real implementation, this would come from the server)
        simulateAIResponse(to: message)
    }
    
    // MARK: - Private Methods
    
    private func setupTelnyxClientObservers() {
        // Set up observers for TelnyxRTC events
        // This would depend on the actual TelnyxRTC SDK implementation
        // For now, we'll set up basic call state monitoring
    }
    
    private func setupCallQualityMonitoring() {
        // Set up audio level monitoring
        // This would integrate with TelnyxRTC's audio level callbacks
        // For now, we'll simulate audio levels
        simulateAudioLevels()
    }
    
    private func simulateAudioLevels() {
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self,
                      case .expanded = self.widgetState || case .transcriptView = self.widgetState else {
                    return
                }
                
                let level = Float.random(in: 0...1)
                self.audioLevels.append(level)
                if self.audioLevels.count > self.maxLevels {
                    self.audioLevels.removeFirst()
                }
            }
            .store(in: &cancellables)
    }
    
    private func simulateAIResponse(to message: String) {
        // Simulate AI thinking
        updateAgentStatus(.thinking)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            // Add AI response to transcript
            let aiResponse = TranscriptItem(
                id: UUID().uuidString,
                text: "I understand you said: '\(message)'. How can I help you further?",
                isUser: false
            )
            self.transcriptItems.append(aiResponse)
            
            // Update agent status to waiting
            self.updateAgentStatus(.waiting)
        }
    }
    
    private func updateAgentStatus(_ newStatus: AgentStatus) {
        switch widgetState {
        case let .expanded(settings, isConnected, isMuted, _):
            widgetState = .expanded(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: newStatus)
        case let .transcriptView(settings, isConnected, isMuted, _):
            widgetState = .transcriptView(settings: settings, isConnected: isConnected, isMuted: isMuted, agentStatus: newStatus)
        default:
            break
        }
    }
    
    // MARK: - Call State Handling
    
    private func handleCallAnswered() {
        isConnected = true
        
        guard case let .connecting(settings) = widgetState else { return }
        
        if iconOnly {
            // In icon-only mode, skip Expanded state and go directly to TranscriptView
            widgetState = .transcriptView(
                settings: settings,
                isConnected: true,
                isMuted: false,
                agentStatus: .waiting
            )
        } else {
            // In regular mode, transition to Expanded state
            widgetState = .expanded(
                settings: settings,
                isConnected: true,
                isMuted: false,
                agentStatus: .waiting
            )
        }
    }
    
    private func handleCallEnded() {
        isConnected = false
        
        switch widgetState {
        case .expanded, .transcriptView:
            widgetState = .collapsed(settings: widgetSettings)
        default:
            break
        }
    }
    
    private func handleConnectionError(_ error: Error) {
        widgetState = .error(message: error.localizedDescription, type: .connection)
    }
}