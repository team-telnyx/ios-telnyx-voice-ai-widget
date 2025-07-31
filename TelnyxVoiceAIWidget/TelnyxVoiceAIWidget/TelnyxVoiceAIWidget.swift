//
//  TelnyxVoiceAIWidget.swift
//  TelnyxVoiceAIWidget
//
//  Created by Guillermo Battistel on 31-07-25.
//

import Foundation

/// TelnyxVoiceAIWidget SDK
@objc public class TelnyxVoiceAIWidget: NSObject {
    
    /// Version of the TelnyxVoiceAIWidget SDK
    public static let version = "1.0.0"
    
    /// Shared instance of TelnyxVoiceAIWidget
    @objc public static let shared = TelnyxVoiceAIWidget()
    
    private override init() {
        super.init()
    }
    
    /// Initialize the TelnyxVoiceAIWidget
    @objc public func initialize() {
        print("TelnyxVoiceAIWidget v\(TelnyxVoiceAIWidget.version) initialized")
    }
    
    /// Start voice AI session
    @objc public func startVoiceSession() {
        print("Starting voice AI session...")
    }
    
    /// Stop voice AI session
    @objc public func stopVoiceSession() {
        print("Stopping voice AI session...")
    }
}

