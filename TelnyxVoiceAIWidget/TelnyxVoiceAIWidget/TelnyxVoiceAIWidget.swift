//
//  TelnyxVoiceAIWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Guillermo Battistel on 31-07-25.
//

import Foundation

/// TelnyxVoiceAIWidget SDK
public class TelnyxVoiceAIWidget: NSObject {
    
    /// Version of the TelnyxVoiceAIWidget SDK
    public static let version = "1.0.0"
    
    /// Shared instance of TelnyxVoiceAIWidget
    public static let shared = TelnyxVoiceAIWidget()
    
    private override init() {
        super.init()
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

