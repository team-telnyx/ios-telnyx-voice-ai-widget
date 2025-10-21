//
//  WidgetStateTests.swift
//  TelnyxVoiceAIWidgetTests
//
//  Created by Telnyx on 02-10-25.
//

@testable import TelnyxVoiceAIWidget
import XCTest

final class WidgetStateTests: XCTestCase {
    // MARK: - Equality Tests

    func testIdleState_equality() {
        // Given
        let state1 = WidgetState.idle
        let state2 = WidgetState.idle

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testLoadingState_equality() {
        // Given
        let state1 = WidgetState.loading
        let state2 = WidgetState.loading

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testCollapsedState_equality_withSameSettings() {
        // Given
        let settings = WidgetSettings(
            logoIconUrl: "https://example.com/logo.png",
            startCallText: "Start Call"
        )
        let state1 = WidgetState.collapsed(settings: settings)
        let state2 = WidgetState.collapsed(settings: settings)

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testCollapsedState_inequality_withDifferentSettings() {
        // Given
        let settings1 = WidgetSettings(startCallText: "Start Call")
        let settings2 = WidgetSettings(startCallText: "Begin Call")
        let state1 = WidgetState.collapsed(settings: settings1)
        let state2 = WidgetState.collapsed(settings: settings2)

        // Then
        XCTAssertNotEqual(state1, state2)
    }

    func testConnectingState_equality_withSameSettings() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        let state1 = WidgetState.connecting(settings: settings)
        let state2 = WidgetState.connecting(settings: settings)

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testExpandedState_equality_withSameParameters() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        let state1 = WidgetState.expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )
        let state2 = WidgetState.expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testExpandedState_inequality_withDifferentMuteStatus() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        let state1 = WidgetState.expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )
        let state2 = WidgetState.expanded(
            settings: settings,
            isConnected: true,
            isMuted: true,
            agentStatus: .thinking
        )

        // Then
        XCTAssertNotEqual(state1, state2)
    }

    func testExpandedState_inequality_withDifferentAgentStatus() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        let state1 = WidgetState.expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )
        let state2 = WidgetState.expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .waiting
        )

        // Then
        XCTAssertNotEqual(state1, state2)
    }

    func testTranscriptViewState_equality_withSameParameters() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        let state1 = WidgetState.transcriptView(
            settings: settings,
            isConnected: true,
            isMuted: true,
            agentStatus: .waiting
        )
        let state2 = WidgetState.transcriptView(
            settings: settings,
            isConnected: true,
            isMuted: true,
            agentStatus: .waiting
        )

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testErrorState_equality_withSameErrorDetails() {
        // Given
        let state1 = WidgetState.error(message: "Connection failed", type: .connection)
        let state2 = WidgetState.error(message: "Connection failed", type: .connection)

        // Then
        XCTAssertEqual(state1, state2)
    }

    func testErrorState_inequality_withDifferentMessages() {
        // Given
        let state1 = WidgetState.error(message: "Connection failed", type: .connection)
        let state2 = WidgetState.error(message: "Initialization failed", type: .connection)

        // Then
        XCTAssertNotEqual(state1, state2)
    }

    func testErrorState_inequality_withDifferentErrorTypes() {
        // Given
        let state1 = WidgetState.error(message: "Failed", type: .connection)
        let state2 = WidgetState.error(message: "Failed", type: .initialization)

        // Then
        XCTAssertNotEqual(state1, state2)
    }

    func testDifferentStates_inequality() {
        // Given
        let idleState = WidgetState.idle
        let loadingState = WidgetState.loading
        let collapsedState = WidgetState.collapsed(settings: WidgetSettings())

        // Then
        XCTAssertNotEqual(idleState, loadingState)
        XCTAssertNotEqual(loadingState, collapsedState)
        XCTAssertNotEqual(idleState, collapsedState)
    }

    // MARK: - AgentStatus Tests

    func testAgentStatus_idle_equality() {
        // Given
        let status1 = AgentStatus.idle
        let status2 = AgentStatus.idle

        // Then
        XCTAssertEqual(status1, status2)
    }

    func testAgentStatus_thinking_equality() {
        // Given
        let status1 = AgentStatus.thinking
        let status2 = AgentStatus.thinking

        // Then
        XCTAssertEqual(status1, status2)
    }

    func testAgentStatus_waiting_equality() {
        // Given
        let status1 = AgentStatus.waiting
        let status2 = AgentStatus.waiting

        // Then
        XCTAssertEqual(status1, status2)
    }

    func testAgentStatus_differentStatuses_inequality() {
        // Given
        let idleStatus = AgentStatus.idle
        let thinkingStatus = AgentStatus.thinking
        let waitingStatus = AgentStatus.waiting

        // Then
        XCTAssertNotEqual(idleStatus, thinkingStatus)
        XCTAssertNotEqual(thinkingStatus, waitingStatus)
        XCTAssertNotEqual(idleStatus, waitingStatus)
    }

    // MARK: - ErrorType Tests

    func testErrorType_initialization_equality() {
        // Given
        let error1 = ErrorType.initialization
        let error2 = ErrorType.initialization

        // Then
        XCTAssertEqual(error1, error2)
    }

    func testErrorType_connection_equality() {
        // Given
        let error1 = ErrorType.connection
        let error2 = ErrorType.connection

        // Then
        XCTAssertEqual(error1, error2)
    }

    func testErrorType_other_equality() {
        // Given
        let error1 = ErrorType.other
        let error2 = ErrorType.other

        // Then
        XCTAssertEqual(error1, error2)
    }

    func testErrorType_differentTypes_inequality() {
        // Given
        let initError = ErrorType.initialization
        let connError = ErrorType.connection
        let otherError = ErrorType.other

        // Then
        XCTAssertNotEqual(initError, connError)
        XCTAssertNotEqual(connError, otherError)
        XCTAssertNotEqual(initError, otherError)
    }

    // MARK: - TranscriptItem Tests

    func testTranscriptItem_initialization() {
        // Given
        let id = "test-id"
        let text = "Hello, world!"
        let isUser = true
        let timestamp = Date()

        // When
        let item = TranscriptItem(
            id: id,
            text: text,
            isUser: isUser,
            timestamp: timestamp
        )

        // Then
        XCTAssertEqual(item.id, id)
        XCTAssertEqual(item.text, text)
        XCTAssertEqual(item.isUser, isUser)
        XCTAssertEqual(item.timestamp, timestamp)
    }

    func testTranscriptItem_defaultTimestamp() {
        // Given
        let id = "test-id"
        let text = "Hello"
        let isUser = false
        let before = Date()

        // When
        let item = TranscriptItem(id: id, text: text, isUser: isUser)
        let after = Date()

        // Then
        XCTAssertTrue(item.timestamp >= before && item.timestamp <= after)
    }

    func testTranscriptItem_equality_withSameValues() {
        // Given
        let timestamp = Date()
        let item1 = TranscriptItem(
            id: "1",
            text: "Hello",
            isUser: true,
            timestamp: timestamp
        )
        let item2 = TranscriptItem(
            id: "1",
            text: "Hello",
            isUser: true,
            timestamp: timestamp
        )

        // Then
        XCTAssertEqual(item1, item2)
    }

    func testTranscriptItem_inequality_withDifferentIds() {
        // Given
        let timestamp = Date()
        let item1 = TranscriptItem(
            id: "1",
            text: "Hello",
            isUser: true,
            timestamp: timestamp
        )
        let item2 = TranscriptItem(
            id: "2",
            text: "Hello",
            isUser: true,
            timestamp: timestamp
        )

        // Then
        XCTAssertNotEqual(item1, item2)
    }

    func testTranscriptItem_inequality_withDifferentText() {
        // Given
        let timestamp = Date()
        let item1 = TranscriptItem(
            id: "1",
            text: "Hello",
            isUser: true,
            timestamp: timestamp
        )
        let item2 = TranscriptItem(
            id: "1",
            text: "Goodbye",
            isUser: true,
            timestamp: timestamp
        )

        // Then
        XCTAssertNotEqual(item1, item2)
    }

    func testTranscriptItem_inequality_withDifferentIsUser() {
        // Given
        let timestamp = Date()
        let item1 = TranscriptItem(
            id: "1",
            text: "Hello",
            isUser: true,
            timestamp: timestamp
        )
        let item2 = TranscriptItem(
            id: "1",
            text: "Hello",
            isUser: false,
            timestamp: timestamp
        )

        // Then
        XCTAssertNotEqual(item1, item2)
    }

    // MARK: - WidgetSettings Tests

    func testWidgetSettings_initialization_withAllParameters() {
        // Given & When
        let settings = WidgetSettings(
            agentThinkingText: "Agent is thinking...",
            audioVisualizerConfig: AudioVisualizerConfig(enabled: true, type: "wave", color: "blue"),
            defaultState: "collapsed",
            giveFeedbackUrl: "https://example.com/feedback",
            logoIconUrl: "https://example.com/logo.png",
            position: "bottom-right",
            reportIssueUrl: "https://example.com/report",
            speakToInterruptText: "Speak to interrupt",
            startCallText: "Start Call",
            theme: "light",
            viewHistoryUrl: "https://example.com/history"
        )

        // Then
        XCTAssertEqual(settings.agentThinkingText, "Agent is thinking...")
        XCTAssertNotNil(settings.audioVisualizerConfig)
        XCTAssertEqual(settings.defaultState, "collapsed")
        XCTAssertEqual(settings.startCallText, "Start Call")
        XCTAssertEqual(settings.theme, "light")
    }

    func testWidgetSettings_initialization_withDefaults() {
        // Given & When
        let settings = WidgetSettings()

        // Then
        XCTAssertNil(settings.agentThinkingText)
        XCTAssertNil(settings.audioVisualizerConfig)
        XCTAssertNil(settings.defaultState)
        XCTAssertNil(settings.startCallText)
        XCTAssertNil(settings.theme)
    }

    func testWidgetSettings_equality_withSameValues() {
        // Given
        let settings1 = WidgetSettings(
            startCallText: "Start Call",
            theme: "dark"
        )
        let settings2 = WidgetSettings(
            startCallText: "Start Call",
            theme: "dark"
        )

        // Then
        XCTAssertEqual(settings1, settings2)
    }

    func testWidgetSettings_inequality_withDifferentValues() {
        // Given
        let settings1 = WidgetSettings(startCallText: "Start Call")
        let settings2 = WidgetSettings(startCallText: "Begin Call")

        // Then
        XCTAssertNotEqual(settings1, settings2)
    }

    // MARK: - AudioVisualizerConfig Tests

    func testAudioVisualizerConfig_initialization() {
        // Given & When
        let config = AudioVisualizerConfig(
            enabled: true,
            type: "wave",
            color: "twilight",
            preset: "default"
        )

        // Then
        XCTAssertEqual(config.enabled, true)
        XCTAssertEqual(config.type, "wave")
        XCTAssertEqual(config.color, "twilight")
        XCTAssertEqual(config.preset, "default")
    }

    func testAudioVisualizerConfig_initialization_withDefaults() {
        // Given & When
        let config = AudioVisualizerConfig()

        // Then
        XCTAssertNil(config.enabled)
        XCTAssertNil(config.type)
        XCTAssertNil(config.color)
        XCTAssertNil(config.preset)
    }

    func testAudioVisualizerConfig_equality() {
        // Given
        let config1 = AudioVisualizerConfig(
            enabled: true,
            type: "wave",
            color: "blue"
        )
        let config2 = AudioVisualizerConfig(
            enabled: true,
            type: "wave",
            color: "blue"
        )

        // Then
        XCTAssertEqual(config1, config2)
    }

    func testAudioVisualizerConfig_inequality() {
        // Given
        let config1 = AudioVisualizerConfig(enabled: true, color: "blue")
        let config2 = AudioVisualizerConfig(enabled: false, color: "blue")

        // Then
        XCTAssertNotEqual(config1, config2)
    }
}
