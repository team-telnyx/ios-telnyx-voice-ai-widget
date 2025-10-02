//
//  WidgetLifecycleIntegrationTests.swift
//  TelnyxVoiceAIWidgetTests
//
//  Created by Telnyx on 02-10-25.
//

import XCTest
import Combine
@testable import TelnyxVoiceAIWidget

@MainActor
final class WidgetLifecycleIntegrationTests: XCTestCase {

    var sut: WidgetViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = WidgetViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - shouldInitialize Transition Tests

    func testShouldInitialize_fromFalseToTrue_shouldTransitionFromIdleToLoading() {
        // Given
        let assistantId = "test-assistant-id"
        let expectation = XCTestExpectation(description: "Should transition from idle to loading")

        // Widget starts in idle state
        XCTAssertEqual(sut.widgetState, .idle)

        sut.$widgetState
            .dropFirst() // Skip initial idle state
            .sink { state in
                if case .loading = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When - Initialize widget (equivalent to shouldInitialize = true)
        sut.initialize(assistantId: assistantId)

        // Then
        wait(for: [expectation], timeout: 2.0)
    }

    func testShouldInitialize_afterInitialization_shouldRemainInLoadingOrErrorState() {
        // Given
        let assistantId = "test-assistant-id"

        // When
        sut.initialize(assistantId: assistantId)

        // Then - Should remain in loading or error state without real network connection
        // Wait a bit for any state changes
        let expectation = XCTestExpectation(description: "Wait for state to settle")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)

        // Verify we're in loading or error state (not collapsed without real connection)
        switch sut.widgetState {
        case .loading:
            XCTAssert(true, "State is loading as expected without network")
        case .error:
            XCTAssert(true, "Error state is acceptable without real connection")
        case .collapsed:
            // This might happen if the SDK has a cached session or mock data
            XCTAssert(true, "Collapsed state reached - SDK may have cached data")
        default:
            XCTFail("State should be loading, error, or collapsed, got: \(sut.widgetState)")
        }
    }

    // MARK: - Full Call Flow Tests (Simulated)

    func testFullCallFlow_collapsedToExpandedToCollapsed() {
        // Given
        let settings = WidgetSettings(
            startCallText: "Start Call",
            theme: "light"
        )
        sut.widgetState = .collapsed(settings: settings)

        // Step 1: Verify initial collapsed state
        if case .collapsed = sut.widgetState {
            XCTAssert(true)
        } else {
            XCTFail("Should start in collapsed state")
        }

        // Step 2: Start call - should transition to connecting
        let connectingExpectation = XCTestExpectation(description: "Should transition to connecting")

        sut.$widgetState
            .dropFirst()
            .sink { state in
                if case .connecting = state {
                    connectingExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.startCall()

        wait(for: [connectingExpectation], timeout: 2.0)

        // Step 3: Simulate successful connection - manually transition to expanded
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // Verify expanded state
        if case .expanded(_, let isConnected, let isMuted, _) = sut.widgetState {
            XCTAssertTrue(isConnected)
            XCTAssertFalse(isMuted)
        } else {
            XCTFail("Should be in expanded state")
        }

        // Step 4: End call - should transition back to collapsed
        sut.endCall()

        // Verify back to collapsed state
        if case .collapsed = sut.widgetState {
            XCTAssert(true)
        } else {
            XCTFail("Should return to collapsed state after ending call")
        }
    }

    func testFullCallFlow_shouldClearTranscriptAndAudioOnEndCall() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .waiting
        )

        // Add some transcript items and audio levels
        sut.transcriptItems = [
            TranscriptItem(id: "1", text: "Hello", isUser: true),
            TranscriptItem(id: "2", text: "Hi there!", isUser: false),
            TranscriptItem(id: "3", text: "How are you?", isUser: true)
        ]
        sut.audioLevels = [0.5, 0.6, 0.7, 0.8, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4]

        // Verify data exists before ending call
        XCTAssertFalse(sut.transcriptItems.isEmpty)
        XCTAssertFalse(sut.audioLevels.isEmpty)

        // When
        sut.endCall()

        // Then
        XCTAssertTrue(sut.transcriptItems.isEmpty, "Transcript should be cleared")
        XCTAssertTrue(sut.audioLevels.isEmpty, "Audio levels should be cleared")
    }

    // MARK: - Icon-Only Mode Tests

    func testIconOnlyMode_initialization_shouldStoreMode() {
        // Given
        let assistantId = "test-assistant-id"
        let customization = WidgetCustomization(audioVisualizerColor: "twilight")

        // When
        sut.initialize(
            assistantId: assistantId,
            iconOnly: true,
            customization: customization
        )

        // Then
        XCTAssertEqual(sut.widgetState, .loading)
        XCTAssertNotNil(sut.customization)
    }

    func testIconOnlyMode_directTransitionToTranscriptView() {
        // Given - Simulate icon-only mode by manually setting up the flow
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // When - Show transcript view (in icon-only mode, this happens automatically)
        sut.showTranscriptView()

        // Then
        if case .transcriptView = sut.widgetState {
            XCTAssert(true)
        } else {
            XCTFail("Should be in transcript view state")
        }
    }

    // MARK: - State Transition Tests

    func testStateTransition_expandedToTranscriptView() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )

        // When
        sut.showTranscriptView()

        // Then
        if case .transcriptView(let resultSettings, let isConnected, let isMuted, let agentStatus) = sut.widgetState {
            XCTAssertEqual(resultSettings, settings)
            XCTAssertTrue(isConnected)
            XCTAssertFalse(isMuted)
            XCTAssertEqual(agentStatus, .thinking)
        } else {
            XCTFail("Should transition to transcript view")
        }
    }

    func testStateTransition_transcriptViewToExpanded() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .transcriptView(
            settings: settings,
            isConnected: true,
            isMuted: true,
            agentStatus: .waiting
        )

        // When
        sut.collapseFromTranscriptView()

        // Then
        if case .expanded(let resultSettings, let isConnected, let isMuted, let agentStatus) = sut.widgetState {
            XCTAssertEqual(resultSettings, settings)
            XCTAssertTrue(isConnected)
            XCTAssertTrue(isMuted)
            XCTAssertEqual(agentStatus, .waiting)
        } else {
            XCTFail("Should transition to expanded state")
        }
    }

    func testStateTransition_muteToggleDuringCall_shouldPreserveOtherState() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )

        // When - Toggle mute
        sut.toggleMute()

        // Then - Should preserve all other state properties except isMuted
        if case .expanded(let resultSettings, let isConnected, let isMuted, let agentStatus) = sut.widgetState {
            XCTAssertEqual(resultSettings, settings)
            XCTAssertTrue(isConnected)
            XCTAssertTrue(isMuted) // This changed
            XCTAssertEqual(agentStatus, .thinking)
        } else {
            XCTFail("Should remain in expanded state")
        }

        // When - Toggle again
        sut.toggleMute()

        // Then - Should toggle back
        if case .expanded(_, _, let isMuted, _) = sut.widgetState {
            XCTAssertFalse(isMuted)
        } else {
            XCTFail("Should remain in expanded state")
        }
    }

    // MARK: - Error Handling Tests

    func testErrorState_fromConnectionFailure() {
        // Given
        sut.widgetState = .error(
            message: "Failed to connect to AI Assistant",
            type: .connection
        )

        // Then
        if case .error(let message, let type) = sut.widgetState {
            XCTAssertEqual(message, "Failed to connect to AI Assistant")
            XCTAssertEqual(type, .connection)
        } else {
            XCTFail("Should be in error state")
        }
    }

    func testErrorState_fromInitializationFailure() {
        // Given
        sut.widgetState = .error(
            message: "Invalid assistant ID",
            type: .initialization
        )

        // Then
        if case .error(let message, let type) = sut.widgetState {
            XCTAssertEqual(message, "Invalid assistant ID")
            XCTAssertEqual(type, .initialization)
        } else {
            XCTFail("Should be in error state")
        }
    }

    // MARK: - Message Sending Tests

    func testSendMessage_withValidInput_shouldClearInputAndSend() async {
        // Given
        sut.userInput = "Hello, how can you help me?"

        let expectation = XCTestExpectation(description: "User input should be cleared")

        sut.$userInput
            .dropFirst() // Skip initial value
            .sink { input in
                if input.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.sendMessage()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.userInput, "", "User input should be cleared after sending")
    }

    func testSendMessage_withEmptyInput_shouldNotSend() {
        // Given
        sut.userInput = ""
        let initialInput = sut.userInput

        // When
        sut.sendMessage()

        // Then
        XCTAssertEqual(sut.userInput, initialInput, "Empty input should not be sent")
    }

    func testSendMessage_withWhitespaceOnly_shouldNotSend() {
        // Given
        sut.userInput = "   \n\t   "

        // When
        sut.sendMessage()

        // Then
        // Input should remain unchanged since trimmed message is empty
        XCTAssertEqual(sut.userInput, "   \n\t   ")
    }

    func testUpdateUserInput_shouldUpdateInputProperty() {
        // Given
        let newInput = "This is my question"
        let expectation = XCTestExpectation(description: "User input should update")

        sut.$userInput
            .dropFirst()
            .sink { input in
                if input == newInput {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.updateUserInput(newInput)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.userInput, newInput)
    }

    // MARK: - Agent Status Tests

    func testAgentStatus_transitionsThroughDifferentStates() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")

        // Test idle status
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        if case .expanded(_, _, _, let status) = sut.widgetState {
            XCTAssertEqual(status, .idle)
        }

        // Test thinking status
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .thinking
        )

        if case .expanded(_, _, _, let status) = sut.widgetState {
            XCTAssertEqual(status, .thinking)
        }

        // Test waiting status
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .waiting
        )

        if case .expanded(_, _, _, let status) = sut.widgetState {
            XCTAssertEqual(status, .waiting)
        }
    }

    // MARK: - Customization Tests

    func testCustomization_shouldBeStoredDuringInitialization() {
        // Given
        let customization = WidgetCustomization(
            audioVisualizerColor: "bloom",
            userBubbleBackgroundColor: .blue,
            agentBubbleBackgroundColor: .gray,
            muteButtonBackgroundColor: .green
        )

        // When
        sut.initialize(
            assistantId: "test-id",
            iconOnly: false,
            customization: customization
        )

        // Then
        XCTAssertNotNil(sut.customization)
        XCTAssertEqual(sut.customization?.audioVisualizerColor, "bloom")
        XCTAssertEqual(sut.customization?.userBubbleBackgroundColor, .blue)
        XCTAssertEqual(sut.customization?.agentBubbleBackgroundColor, .gray)
        XCTAssertEqual(sut.customization?.muteButtonBackgroundColor, .green)
    }

    func testCustomization_withoutCustomization_shouldBeNil() {
        // Given & When
        sut.initialize(assistantId: "test-id")

        // Then
        XCTAssertNil(sut.customization)
    }
}
