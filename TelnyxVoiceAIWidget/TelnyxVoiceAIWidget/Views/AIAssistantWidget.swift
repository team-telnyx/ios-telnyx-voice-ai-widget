//
//  AIAssistantWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by OpenHands on 29-09-25.
//

import SwiftUI

/// Main AI Assistant Widget component
/// 
/// This is the entry point for integrating the AI Assistant Widget into your application.
/// The widget handles the complete lifecycle of AI Assistant interactions, including socket
/// connection, call management, and UI state transitions.
public struct AIAssistantWidget: View {
    
    // MARK: - Parameters
    
    /// The Assistant ID from your Telnyx AI configuration used to establish
    /// the connection to the AI service. This ID determines which AI assistant
    /// configuration and capabilities are loaded.
    let assistantId: String
    
    /// Controls when the widget establishes its socket connection to Telnyx.
    /// When false, the widget remains in Idle state with no network activity.
    /// When true, triggers socket connection initialization and loads widget settings.
    /// This allows for conditional initialization (e.g., after user consent,
    /// network availability checks, or deferred loading for performance).
    /// Changing from false to true will trigger initialization.
    /// Changing from true to false does NOT disconnect an active session.
    let shouldInitialize: Bool
    
    /// When true, displays the widget as a floating action button with only the icon.
    /// In this mode, tapping starts the call and opens directly into the full screen
    /// text view. When false, displays the regular widget button with text.
    let iconOnly: Bool
    
    /// Modifier applied to the widget button in collapsed state
    let widgetButtonModifier: AnyView?
    
    /// Modifier applied to the expanded widget
    let expandedWidgetModifier: AnyView?
    
    /// Modifier applied to the text visible on the widget button
    let buttonTextModifier: AnyView?
    
    /// Modifier applied to the image/icon visible on the widget button
    let buttonImageModifier: AnyView?
    
    // MARK: - State
    
    @StateObject private var viewModel = WidgetViewModel()
    @State private var floatingButtonErrorState: WidgetState?
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Initializer
    
    /// Initialize the AI Assistant Widget
    /// - Parameters:
    ///   - assistantId: The Assistant ID from your Telnyx AI configuration
    ///   - shouldInitialize: Controls when the widget establishes its socket connection
    ///   - iconOnly: When true, displays as floating action button with only the icon
    ///   - widgetButtonModifier: Modifier applied to the widget button in collapsed state
    ///   - expandedWidgetModifier: Modifier applied to the expanded widget
    ///   - buttonTextModifier: Modifier applied to the text visible on the widget button
    ///   - buttonImageModifier: Modifier applied to the image/icon visible on the widget button
    public init(
        assistantId: String,
        shouldInitialize: Bool = true,
        iconOnly: Bool = false,
        widgetButtonModifier: AnyView? = nil,
        expandedWidgetModifier: AnyView? = nil,
        buttonTextModifier: AnyView? = nil,
        buttonImageModifier: AnyView? = nil
    ) {
        self.assistantId = assistantId
        self.shouldInitialize = shouldInitialize
        self.iconOnly = iconOnly
        self.widgetButtonModifier = widgetButtonModifier
        self.expandedWidgetModifier = expandedWidgetModifier
        self.buttonTextModifier = buttonTextModifier
        self.buttonImageModifier = buttonImageModifier
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            // Main widget content
            widgetContent
        }
        .onAppear {
            if shouldInitialize {
                viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly)
            }
        }
        .onChange(of: shouldInitialize) { newValue in
            if newValue {
                viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly)
            }
        }
        .sheet(item: Binding<WidgetState?>(
            get: { floatingButtonErrorState },
            set: { floatingButtonErrorState = $0 }
        )) { errorState in
            if case let .error(message, type) = errorState {
                ErrorWidget(
                    message: message,
                    type: type,
                    assistantId: assistantId,
                    onRetry: {
                        viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly)
                        floatingButtonErrorState = nil
                    }
                )
            }
        }
        .fullScreenCover(isPresented: .constant(shouldShowTranscriptView)) {
            if case let .transcriptView(settings, isConnected, isMuted, agentStatus) = viewModel.widgetState {
                TranscriptView(
                    settings: settings,
                    transcriptItems: viewModel.transcriptItems,
                    userInput: viewModel.userInput,
                    isConnected: isConnected,
                    isMuted: isMuted,
                    agentStatus: agentStatus,
                    audioLevels: viewModel.audioLevels,
                    onUserInputChange: viewModel.updateUserInput,
                    onSendMessage: viewModel.sendMessage,
                    onToggleMute: viewModel.toggleMute,
                    onEndCall: viewModel.endCall,
                    onCollapse: viewModel.collapseFromTranscriptView,
                    iconOnly: iconOnly
                )
            }
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var widgetContent: some View {
        switch viewModel.widgetState {
        case .idle:
            EmptyView()
            
        case .loading:
            LoadingWidget(isCircular: iconOnly)
            
        case let .collapsed(settings):
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
                    onClick: viewModel.startCall,
                    buttonTextModifier: buttonTextModifier,
                    buttonImageModifier: buttonImageModifier
                )
                .modifier(widgetButtonModifier ?? AnyView(EmptyView()))
            }
            
        case let .connecting(settings):
            LoadingWidget(isCircular: iconOnly)
            
        case let .expanded(settings, isConnected, isMuted, agentStatus):
            if !iconOnly {
                ExpandedWidget(
                    settings: settings,
                    isConnected: isConnected,
                    isMuted: isMuted,
                    agentStatus: agentStatus,
                    audioLevels: viewModel.audioLevels,
                    onToggleMute: viewModel.toggleMute,
                    onEndCall: viewModel.endCall,
                    onTap: viewModel.showTranscriptView
                )
                .modifier(expandedWidgetModifier ?? AnyView(EmptyView()))
            }
            
        case .transcriptView:
            // Handled by fullScreenCover
            if !iconOnly {
                // Keep the expanded widget visible behind the dialog (only in regular mode)
                if case let .transcriptView(settings, isConnected, isMuted, agentStatus) = viewModel.widgetState {
                    ExpandedWidget(
                        settings: settings,
                        isConnected: isConnected,
                        isMuted: isMuted,
                        agentStatus: agentStatus,
                        audioLevels: viewModel.audioLevels,
                        onToggleMute: viewModel.toggleMute,
                        onEndCall: viewModel.endCall,
                        onTap: { /* Do nothing - already in transcript view */ }
                    )
                    .modifier(expandedWidgetModifier ?? AnyView(EmptyView()))
                }
            }
            
        case let .error(message, type):
            if iconOnly {
                FloatingButton(
                    settings: viewModel.widgetSettings,
                    onClick: {
                        // In iconOnly mode, show error dialog when tapped
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
                        viewModel.initialize(assistantId: assistantId, iconOnly: iconOnly)
                    }
                )
            }
        }
    }
    
    private var shouldShowTranscriptView: Bool {
        if case .transcriptView = viewModel.widgetState {
            return true
        }
        return false
    }
    
    private var themeToUse: ColorScheme {
        switch viewModel.widgetSettings.theme?.lowercased() {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return colorScheme
        }
    }
}

/// Error widget component
struct ErrorWidget: View {
    let message: String
    let type: ErrorType
    let assistantId: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            if type == .initialization {
                VStack(spacing: 12) {
                    Text("Unable to initialize the AI Assistant. Please check your configuration.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Link("Check Assistant Settings", 
                         destination: URL(string: "https://portal.telnyx.com/#/ai/assistants/edit/\(assistantId)?tab=telephony")!)
                        .foregroundColor(.blue)
                }
            } else {
                let messageToShow = switch type {
                case .connection:
                    "Connection error: \(message)"
                case .other:
                    "Error: \(message)"
                default:
                    message
                }
                
                Text(messageToShow)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .stroke(Color.red, lineWidth: 1)
        )
        .padding()
    }
}

// MARK: - WidgetState Identifiable Extension

extension WidgetState: Identifiable {
    public var id: String {
        switch self {
        case .idle: return "idle"
        case .loading: return "loading"
        case .collapsed: return "collapsed"
        case .connecting: return "connecting"
        case .expanded: return "expanded"
        case .transcriptView: return "transcriptView"
        case .error: return "error"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        AIAssistantWidget(
            assistantId: "test-assistant-id",
            shouldInitialize: true,
            iconOnly: false
        )
        
        AIAssistantWidget(
            assistantId: "test-assistant-id",
            shouldInitialize: true,
            iconOnly: true
        )
    }
    .padding()
}