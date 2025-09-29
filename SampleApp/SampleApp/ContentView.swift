//
//  ContentView.swift
//  SampleApp
//
//  Created by Guillermo Battistel on 31-07-25.
//

import SwiftUI
import TelnyxVoiceAIWidget
import AVFoundation

struct ContentView: View {
    @State private var assistantId: String = ""
    @State private var shouldInitialize: Bool = false
    @State private var iconOnly: Bool = false
    @State private var microphonePermissionGranted: Bool = false
    @State private var showPermissionAlert: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "mic.circle.fill")
                    .imageScale(.large)
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Telnyx Voice AI Widget")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Sample App")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)

            // Configuration Form
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Assistant ID")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextField("Enter your Assistant ID", text: $assistantId)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Text("Get your Assistant ID from the Telnyx Portal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Widget Mode Toggle
                VStack(alignment: .leading, spacing: 8) {
                    Text("Widget Mode")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Toggle(isOn: $iconOnly) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Icon-Only Mode")
                                .font(.body)
                            Text("Display as floating action button")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to use:")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Enter your Assistant ID above", systemImage: "1.circle.fill")
                        Label("Toggle widget mode if desired", systemImage: "2.circle.fill")
                        Label("Tap 'Show Widget' to display the AI assistant", systemImage: "3.circle.fill")
                        Label("Tap the widget to start a voice call", systemImage: "4.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(20)

            Spacer()

            // Widget Display Area
            if shouldInitialize && !assistantId.isEmpty {
                VStack {
                    Text("Widget Active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)

                    AIAssistantWidget(
                        assistantId: assistantId,
                        shouldInitialize: true,
                        iconOnly: iconOnly
                    )
                    .frame(maxWidth: iconOnly ? 80 : .infinity)
                    .frame(height: iconOnly ? 80 : 60)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            // Action Buttons
            VStack(spacing: 12) {
                if !shouldInitialize {
                    Button(action: {
                        if !assistantId.isEmpty {
                            requestMicrophonePermission()
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Show Widget")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(assistantId.isEmpty ? Color.gray : Color.accentColor)
                        .cornerRadius(12)
                    }
                    .disabled(assistantId.isEmpty)
                } else {
                    Button(action: {
                        shouldInitialize = false
                    }) {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                            Text("Hide Widget")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
            }
            .padding(20)
        }
        .alert("Microphone Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in Settings to use voice features")
        }
    }

    // MARK: - Helper Methods

    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                microphonePermissionGranted = granted
                if granted {
                    shouldInitialize = true
                } else {
                    showPermissionAlert = true
                }
            }
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    ContentView()
}
