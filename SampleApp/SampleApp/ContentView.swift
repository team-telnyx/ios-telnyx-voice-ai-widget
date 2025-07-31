//
//  ContentView.swift
//  SampleApp
//
//  Created by Guillermo Battistel on 31-07-25.
//

import SwiftUI
import TelnyxVoiceAIWidget

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
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
            
            Button("Initialize SDK") {
                TelnyxVoiceAIWidget.shared.initialize()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Start Voice Session") {
                TelnyxVoiceAIWidget.shared.startVoiceSession()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
