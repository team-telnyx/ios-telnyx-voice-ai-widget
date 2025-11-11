//
//  AIAssistantWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 29-09-25.
//

import Combine
import SwiftUI

/// Main AI Assistant Widget component
///
/// This is the entry point for integrating the AI Assistant Widget into your application.
/// The widget handles the complete lifecycle of AI Assistant interactions, including socket
/// connection, call management, and UI state transitions.
///
/// - Parameters:
///   - assistantId: The Assistant ID from your Telnyx AI configuration used to establish
///                  the connection to the AI service. This ID determines which AI assistant
///                  configuration and capabilities are loaded.
///   - shouldInitialize: Controls when the widget establishes its socket connection to Telnyx.
///                       When false, the widget remains in Idle state with no network activity.
///                       When true, triggers socket connection initialization and loads widget settings.
///   - iconOnly: When true, displays the widget as a floating action button with only the icon.
///               In this mode, tapping starts the call and opens directly into the full screen
///               text view. When false, displays the regular widget button with text.
///   - callParams: Optional parameters for customizing call initialization. When provided,
///                 these values override the default caller name, caller number, destination number,
///                 and client state used when creating a call.
///   - widgetButtonModifier: ViewModifier applied to the widget button in collapsed state
///   - expandedWidgetModifier: ViewModifier applied to the expanded widget
///   - buttonTextModifier: ViewModifier applied to the text visible on the widget button
///   - buttonImageModifier: ViewModifier applied to the image/icon visible on the widget button
///   - customization: Optional custom colors that take priority over socket-received theme colors
public struct AIAssistantWidget: View {
    // MARK: - Properties
    let assistantId: String
    let shouldInitialize: Bool
    let iconOnly: Bool
    let callParams: CallParams?
    let customization: WidgetCustomization?

    // MARK: - ViewModifiers
    let widgetButtonModifier: AnyView?
    let expandedWidgetModifier: AnyView?
    let buttonTextModifier: AnyView?
    let buttonImageModifier: AnyView?

    // MARK: - State
    @ObservedObject private var viewModel: WidgetViewModel
    @Environment(\.colorScheme) private var systemColorScheme
    @State private var floatingButtonErrorState: WidgetState?
    @State private var showTranscriptView: Bool = false

    // MARK: - Initialization
    public init(
        assistantId: String,
        shouldInitialize: Bool = true,
        iconOnly: Bool = false,
        callParams: CallParams? = nil,
        customization: WidgetCustomization? = nil,
        widgetButtonModifier: AnyView? = nil,
        expandedWidgetModifier: AnyView? = nil,
        buttonTextModifier: AnyView? = nil,
        buttonImageModifier: AnyView? = nil
    ) {
        self.assistantId = assistantId
        self.shouldInitialize = shouldInitialize
        self.iconOnly = iconOnly
        self.callParams = callParams
        self.customization = customization
        self.widgetButtonModifier = widgetButtonModifier
        self.expandedWidgetModifier = expandedWidgetModifier
        self.buttonTextModifier = buttonTextModifier
        self.buttonImageModifier = buttonImageModifier
        self.viewModel = WidgetViewModel()
    }

    // MARK: - Body
    public var body: some View {
        ZStack {
            mainContent
        }
        .preferredColorScheme(preferredTheme)
        .onAppear {
            if shouldInitialize {
                viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly, callParams: callParams, customization: customization)
            }
        }
        .onReceive(viewModel.$widgetState) { newState in
            // Show/hide transcript view based on state (iOS 13+ compatible)
            if case .transcriptView = newState {
                showTranscriptView = true
            } else {
                showTranscriptView = false
            }
        }
        .sheet(isPresented: $showTranscriptView) {
            transcriptFullScreenView
        }
        .sheet(item: Binding(
            get: { floatingButtonErrorState.flatMap { state -> ErrorSheetItem? in
                if case .error(let message, let type) = state {
                    return ErrorSheetItem(message: message, type: type)
                }
                return nil
            }},
            set: { newValue in
                floatingButtonErrorState = newValue.map { .error(message: $0.message, type: $0.type) }
            }
        )) { errorItem in
            ErrorWidget(
                message: errorItem.message,
                type: errorItem.type,
                assistantId: assistantId,
                onRetry: {
                    viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly, callParams: callParams, customization: customization)
                    floatingButtonErrorState = nil
                }
            )
        }
    }

    // MARK: - View Builders
    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.widgetState {
        case .idle:
            EmptyView()

        case .loading:
            LoadingWidget(isCircular: iconOnly)

        case .collapsed(let settings):
            if iconOnly {
                FloatingButton(
                    settings: settings,
                    onClick: {
                        viewModel.startCall()
                    },
                    buttonImageModifier: buttonImageModifier
                )
            } else {
                WidgetButton(
                    settings: settings,
                    onClick: {
                        viewModel.startCall()
                    },
                    widgetButtonModifier: widgetButtonModifier,
                    buttonTextModifier: buttonTextModifier,
                    buttonImageModifier: buttonImageModifier
                )
            }

        case .connecting:
            LoadingWidget(isCircular: iconOnly)

        case .expanded(let settings, let isConnected, let isMuted, let agentStatus):
            if !iconOnly {
                ExpandedWidget(
                    settings: settings,
                    customization: viewModel.customization,
                    isConnected: isConnected,
                    isMuted: isMuted,
                    agentStatus: agentStatus,
                    audioLevels: viewModel.audioLevels,
                    onToggleMute: { viewModel.toggleMute() },
                    onEndCall: { viewModel.endCall() },
                    onTap: { viewModel.showTranscriptView() },
                    expandedWidgetModifier: expandedWidgetModifier
                )
            }

        case .transcriptView(let settings, let isConnected, let isMuted, let agentStatus):
            if !iconOnly {
                // Keep the expanded widget visible behind the fullscreen transcript (only in regular mode)
                ExpandedWidget(
                    settings: settings,
                    customization: viewModel.customization,
                    isConnected: isConnected,
                    isMuted: isMuted,
                    agentStatus: agentStatus,
                    audioLevels: viewModel.audioLevels,
                    onToggleMute: { viewModel.toggleMute() },
                    onEndCall: { viewModel.endCall() },
                    onTap: { /* Do nothing - already in transcript view */ },
                    expandedWidgetModifier: expandedWidgetModifier
                )
            }
            // TranscriptView is now shown via fullScreenCover

        case .error(let message, let type):
            if iconOnly {
                FloatingButton(
                    settings: viewModel.widgetSettings,
                    onClick: {
                        floatingButtonErrorState = .error(message: message, type: type)
                    },
                    isError: true,
                    buttonImageModifier: buttonImageModifier
                )
            } else {
                ErrorWidget(
                    message: message,
                    type: type,
                    assistantId: assistantId,
                    onRetry: {
                        viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly, callParams: callParams, customization: customization)
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var transcriptFullScreenView: some View {
        if case .transcriptView(let settings, let isConnected, let isMuted, let agentStatus) = viewModel.widgetState {
            TranscriptView(
                settings: settings,
                customization: viewModel.customization,
                transcriptItems: viewModel.transcriptItems,
                userInput: viewModel.userInput,
                isConnected: isConnected,
                isMuted: isMuted,
                agentStatus: agentStatus,
                audioLevels: viewModel.audioLevels,
                onUserInputChange: { viewModel.updateUserInput($0) },
                onSendMessage: { viewModel.sendMessage() },
                onToggleMute: { viewModel.toggleMute() },
                onEndCall: { viewModel.endCall() },
                onCollapse: { viewModel.collapseFromTranscriptView() },
                iconOnly: iconOnly
            )
        }
    }

    private var preferredTheme: ColorScheme? {
        switch viewModel.widgetSettings.theme?.lowercased() {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil // Use system theme
        }
    }
}

// MARK: - Error Sheet Item
private struct ErrorSheetItem: Identifiable {
    let id = UUID()
    let message: String
    let type: ErrorType
}

// MARK: - Preview
#Preview {
    AIAssistantWidget(
        assistantId: "assistant-test-123",
        shouldInitialize: true,
        iconOnly: false
    )
}
