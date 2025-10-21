//
//  WidgetViewModelTests.swift
//  TelnyxVoiceAIWidgetTests
//
//  Created by Telnyx on 02-10-25.
//

import Combine
@testable import TelnyxVoiceAIWidget
import XCTest

@MainActor
final class WidgetViewModelTests: XCTestCase {

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

    // MARK: - Initialization Tests

    func testInit_shouldHaveIdleState() {
        // Given & When - ViewModel is initialized in setUp

        // Then
        XCTAssertEqual(sut.widgetState, .idle)
    }

    func testInit_shouldHaveEmptyTranscriptItems() {
        // Given & When - ViewModel is initialized in setUp

        // Then
        XCTAssertTrue(sut.transcriptItems.isEmpty)
    }

    func testInit_shouldHaveEmptyUserInput() {
        // Given & When - ViewModel is initialized in setUp

        // Then
        XCTAssertEqual(sut.userInput, "")
    }

    func testInit_shouldHaveEmptyAudioLevels() {
        // Given & When - ViewModel is initialized in setUp

        // Then
        XCTAssertTrue(sut.audioLevels.isEmpty)
    }

    func testInit_shouldHaveDefaultWidgetSettings() {
        // Given & When - ViewModel is initialized in setUp

        // Then
        XCTAssertEqual(sut.widgetSettings, WidgetSettings())
    }

    // MARK: - Initialize Method Tests

    func testInitialize_shouldSetLoadingState() {
        // Given
        let assistantId = "test-assistant-id"
        let expectation = XCTestExpectation(description: "State should change to loading")

        sut.$widgetState
            .dropFirst() // Skip initial idle state
            .sink { state in
                if case .loading = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.initialize(assistantId: assistantId)

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testInitialize_withIconOnly_shouldStoreIconOnlyFlag() {
        // Given
        let assistantId = "test-assistant-id"

        // When
        sut.initialize(assistantId: assistantId, iconOnly: true)

        // Then
        // Note: iconOnly is private, so we verify behavior through state transitions
        // This will be tested in integration tests
        XCTAssertEqual(sut.widgetState, .loading)
    }

    func testInitialize_withCustomization_shouldStoreCustomization() {
        // Given
        let assistantId = "test-assistant-id"
        let customization = WidgetCustomization(
            audioVisualizerColor: "twilight",
            userBubbleBackgroundColor: .blue
        )

        // When
        sut.initialize(assistantId: assistantId, customization: customization)

        // Then
        XCTAssertNotNil(sut.customization)
        XCTAssertEqual(sut.customization?.audioVisualizerColor, "twilight")
    }

    // MARK: - State Transition Tests

    func testStartCall_fromCollapsedState_shouldTransitionToConnecting() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .collapsed(settings: settings)

        let expectation = XCTestExpectation(description: "State should change to connecting")

        sut.$widgetState
            .dropFirst() // Skip initial collapsed state
            .sink { state in
                if case .connecting = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.startCall()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testStartCall_fromNonCollapsedState_shouldNotTransition() {
        // Given
        sut.widgetState = .idle

        // When
        sut.startCall()

        // Then
        XCTAssertEqual(sut.widgetState, .idle)
    }

    func testEndCall_fromExpandedState_shouldTransitionToCollapsed() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // When
        sut.endCall()

        // Then
        if case .collapsed = sut.widgetState {
            XCTAssert(true)
        } else {
            XCTFail("State should be collapsed after ending call")
        }
    }

    func testEndCall_fromTranscriptViewState_shouldTransitionToCollapsed() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .transcriptView(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // When
        sut.endCall()

        // Then
        if case .collapsed = sut.widgetState {
            XCTAssert(true)
        } else {
            XCTFail("State should be collapsed after ending call")
        }
    }

    func testEndCall_shouldClearTranscriptItems() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )
        sut.transcriptItems = [
            TranscriptItem(id: "1", text: "Hello", isUser: true),
            TranscriptItem(id: "2", text: "Hi there", isUser: false)
        ]

        // When
        sut.endCall()

        // Then
        XCTAssertTrue(sut.transcriptItems.isEmpty)
    }

    func testEndCall_shouldClearAudioLevels() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )
        sut.audioLevels = [0.5, 0.6, 0.7, 0.8]

        // When
        sut.endCall()

        // Then
        XCTAssertTrue(sut.audioLevels.isEmpty)
    }

    // MARK: - Toggle Mute Tests

    func testToggleMute_fromExpandedState_shouldToggleMuteFlag() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // When
        sut.toggleMute()

        // Then
        if case .expanded(_, _, let isMuted, _) = sut.widgetState {
            XCTAssertTrue(isMuted)
        } else {
            XCTFail("State should remain expanded")
        }
    }

    func testToggleMute_multipleTimes_shouldToggleBetweenStates() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // When - Toggle twice
        sut.toggleMute()

        // Then - Should be muted
        if case .expanded(_, _, let isMuted, _) = sut.widgetState {
            XCTAssertTrue(isMuted)
        } else {
            XCTFail("State should remain expanded")
        }

        // When - Toggle again
        sut.toggleMute()

        // Then - Should be unmuted
        if case .expanded(_, _, let isMuted, _) = sut.widgetState {
            XCTAssertFalse(isMuted)
        } else {
            XCTFail("State should remain expanded")
        }
    }

    func testToggleMute_fromTranscriptViewState_shouldToggleMuteFlag() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .transcriptView(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .idle
        )

        // When
        sut.toggleMute()

        // Then
        if case .transcriptView(_, _, let isMuted, _) = sut.widgetState {
            XCTAssertTrue(isMuted)
        } else {
            XCTFail("State should remain transcriptView")
        }
    }

    // MARK: - Transcript View Tests

    func testShowTranscriptView_fromExpandedState_shouldTransitionToTranscriptView() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .expanded(
            settings: settings,
            isConnected: true,
            isMuted: false,
            agentStatus: .waiting
        )

        // When
        sut.showTranscriptView()

        // Then
        if case .transcriptView(let resultSettings, let isConnected, let isMuted, let agentStatus) = sut.widgetState {
            XCTAssertEqual(resultSettings, settings)
            XCTAssertTrue(isConnected)
            XCTAssertFalse(isMuted)
            XCTAssertEqual(agentStatus, .waiting)
        } else {
            XCTFail("State should be transcriptView")
        }
    }

    func testShowTranscriptView_fromNonExpandedState_shouldNotTransition() {
        // Given
        sut.widgetState = .idle

        // When
        sut.showTranscriptView()

        // Then
        XCTAssertEqual(sut.widgetState, .idle)
    }

    func testCollapseFromTranscriptView_shouldTransitionToExpanded() {
        // Given
        let settings = WidgetSettings(startCallText: "Start Call")
        sut.widgetState = .transcriptView(
            settings: settings,
            isConnected: true,
            isMuted: true,
            agentStatus: .thinking
        )

        // When
        sut.collapseFromTranscriptView()

        // Then
        if case .expanded(let resultSettings, let isConnected, let isMuted, let agentStatus) = sut.widgetState {
            XCTAssertEqual(resultSettings, settings)
            XCTAssertTrue(isConnected)
            XCTAssertTrue(isMuted)
            XCTAssertEqual(agentStatus, .thinking)
        } else {
            XCTFail("State should be expanded")
        }
    }

    // MARK: - User Input Tests

    func testUpdateUserInput_shouldUpdateUserInputProperty() {
        // Given
        let input = "Hello, AI!"

        // When
        sut.updateUserInput(input)

        // Then
        XCTAssertEqual(sut.userInput, input)
    }

    func testSendMessage_withValidInput_shouldClearUserInput() async {
        // Given
        sut.userInput = "Test message"

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
        XCTAssertEqual(sut.userInput, "")
    }

    func testSendMessage_withEmptyInput_shouldNotClearUserInput() {
        // Given
        sut.userInput = ""

        // When
        sut.sendMessage()

        // Then
        XCTAssertEqual(sut.userInput, "")
    }

    func testSendMessage_withWhitespaceOnly_shouldNotSend() {
        // Given
        sut.userInput = "   \n   "

        // When
        sut.sendMessage()

        // Then
        // Input should remain unchanged since message is empty after trimming
        XCTAssertEqual(sut.userInput, "   \n   ")
    }

    // MARK: - Published Properties Observable Tests

    func testWidgetState_isPublished() {
        // Given
        let expectation = XCTestExpectation(description: "widgetState should publish changes")
        let settings = WidgetSettings(startCallText: "Start Call")

        sut.$widgetState
            .dropFirst() // Skip initial value
            .sink { state in
                if case .collapsed = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.widgetState = .collapsed(settings: settings)

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testTranscriptItems_isPublished() {
        // Given
        let expectation = XCTestExpectation(description: "transcriptItems should publish changes")
        let items = [TranscriptItem(id: "1", text: "Hello", isUser: true)]

        sut.$transcriptItems
            .dropFirst() // Skip initial value
            .sink { transcriptItems in
                if !transcriptItems.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.transcriptItems = items

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testUserInput_isPublished() {
        // Given
        let expectation = XCTestExpectation(description: "userInput should publish changes")

        sut.$userInput
            .dropFirst() // Skip initial value
            .sink { input in
                if input == "Test input" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.userInput = "Test input"

        // Then
        wait(for: [expectation], timeout: 1.0)
    }

    func testAudioLevels_isPublished() {
        // Given
        let expectation = XCTestExpectation(description: "audioLevels should publish changes")
        let levels: [Float] = [0.5, 0.6, 0.7]

        sut.$audioLevels
            .dropFirst() // Skip initial value
            .sink { audioLevels in
                if !audioLevels.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.audioLevels = levels

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
