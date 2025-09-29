//
//  TelnyxVoiceAIWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Guillermo Battistel on 31-07-25.
//

import Foundation
import SwiftUI
import TelnyxRTC

/// TelnyxVoiceAIWidget SDK
public class TelnyxVoiceAIWidget: NSObject {
    
    /// Version of the TelnyxVoiceAIWidget SDK
    public static let version = "1.0.0"
    
    /// Shared instance of TelnyxVoiceAIWidget
    public static let shared = TelnyxVoiceAIWidget()
    
    private override init() {
        super.init()
        print("TelnyxVoiceAIWidget v\(TelnyxVoiceAIWidget.version) initialized")
    }
    
    /// Initialize the TelnyxVoiceAIWidget
    public func initialize() {
        print("TelnyxVoiceAIWidget v\(TelnyxVoiceAIWidget.version) initialized")
    }
    
    /// Start voice AI session
    public func startVoiceSession() {
        print("Starting voice AI session...")
    }
    
    /// Stop voice AI session
    public func stopVoiceSession() {
        print("Stopping voice AI session...")
    }
}

// MARK: - Public Exports

// Export the main widget view
public typealias AIAssistantWidget = AIAssistantWidget

// Export the state models
public typealias WidgetState = WidgetState
public typealias AgentStatus = AgentStatus
public typealias TranscriptItem = TranscriptItem
public typealias ErrorType = ErrorType
public typealias WidgetSettings = WidgetSettings

// Export the view model
public typealias WidgetViewModel = WidgetViewModel

