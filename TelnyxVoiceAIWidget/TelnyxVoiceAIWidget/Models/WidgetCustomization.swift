//
//  WidgetCustomization.swift
//  TelnyxVoiceAIWidget
//
//  Created by Telnyx on 01-10-25.
//

import SwiftUI

/// Customization options for the AI Assistant Widget
/// These colors take priority over socket-received theme colors
public struct WidgetCustomization {
    /// Custom audio visualizer gradient color scheme
    /// Options: "verdant", "twilight", "bloom", "mystic", "flare", "glacier"
    public var audioVisualizerColor: String?

    /// Custom background color for transcript view
    public var transcriptBackgroundColor: Color?

    /// Custom background color for user message bubbles
    public var userBubbleBackgroundColor: Color?

    /// Custom background color for agent message bubbles
    public var agentBubbleBackgroundColor: Color?

    /// Custom text color for user messages
    public var userBubbleTextColor: Color?

    /// Custom text color for agent messages
    public var agentBubbleTextColor: Color?

    /// Custom background color for mute button when not muted
    public var muteButtonBackgroundColor: Color?

    /// Custom background color for mute button when muted
    public var muteButtonActiveBackgroundColor: Color?

    /// Custom icon color for mute button
    public var muteButtonIconColor: Color?

    /// Custom widget surface/background color
    public var widgetSurfaceColor: Color?

    /// Custom primary text color
    public var primaryTextColor: Color?

    /// Custom secondary text color
    public var secondaryTextColor: Color?

    /// Custom input field background color
    public var inputBackgroundColor: Color?

    public init(
        audioVisualizerColor: String? = nil,
        transcriptBackgroundColor: Color? = nil,
        userBubbleBackgroundColor: Color? = nil,
        agentBubbleBackgroundColor: Color? = nil,
        userBubbleTextColor: Color? = nil,
        agentBubbleTextColor: Color? = nil,
        muteButtonBackgroundColor: Color? = nil,
        muteButtonActiveBackgroundColor: Color? = nil,
        muteButtonIconColor: Color? = nil,
        widgetSurfaceColor: Color? = nil,
        primaryTextColor: Color? = nil,
        secondaryTextColor: Color? = nil,
        inputBackgroundColor: Color? = nil
    ) {
        self.audioVisualizerColor = audioVisualizerColor
        self.transcriptBackgroundColor = transcriptBackgroundColor
        self.userBubbleBackgroundColor = userBubbleBackgroundColor
        self.agentBubbleBackgroundColor = agentBubbleBackgroundColor
        self.userBubbleTextColor = userBubbleTextColor
        self.agentBubbleTextColor = agentBubbleTextColor
        self.muteButtonBackgroundColor = muteButtonBackgroundColor
        self.muteButtonActiveBackgroundColor = muteButtonActiveBackgroundColor
        self.muteButtonIconColor = muteButtonIconColor
        self.widgetSurfaceColor = widgetSurfaceColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.inputBackgroundColor = inputBackgroundColor
    }
}
