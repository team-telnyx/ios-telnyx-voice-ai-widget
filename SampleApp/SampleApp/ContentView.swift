//
//  ContentView.swift
//  SampleApp
//
//  Created by Guillermo Battistel on 31-07-25.
//

import SwiftUI
import TelnyxVoiceAIWidget

struct ContentView: View {
    @State private var shouldInitialize = false
    @State private var iconOnly = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "mic.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 60))
                
                Text("Telnyx Voice AI Widget")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("SDK Version: \(TelnyxVoiceAIWidget.version)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Controls
            VStack(spacing: 15) {
                Toggle("Initialize Widget", isOn: $shouldInitialize)
                    .toggleStyle(SwitchToggleStyle())
                
                Toggle("Icon Only Mode", isOn: $iconOnly)
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(!shouldInitialize)
            }
            .padding(.horizontal)
            
            // Widget Demo
            VStack(spacing: 20) {
                Text("Widget Demo")
                    .font(.headline)
                
                if shouldInitialize {
                    AIAssistantWidget(
                        assistantId: "demo-assistant-id",
                        shouldInitialize: shouldInitialize,
                        iconOnly: iconOnly
                    )
                } else {
                    Text("Enable 'Initialize Widget' to see the widget")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            // Legacy SDK methods
            VStack(spacing: 10) {
                Text("Legacy SDK Methods")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 15) {
                    Button("Initialize SDK") {
                        TelnyxVoiceAIWidget.shared.initialize()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Start Voice Session") {
                        TelnyxVoiceAIWidget.shared.startVoiceSession()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
