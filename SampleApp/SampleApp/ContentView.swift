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
    @State private var showEmptyIdAlert: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Configuration Form
                    VStack(alignment: .leading, spacing: 16) {
                        // Assistant ID Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assistant ID")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "475569"))

                            TextField("Enter your Assistant ID", text: $assistantId)
                                .padding(12)
                                .background(Color.white)
                                .foregroundColor(Color(hex: "1E293B"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "CBD5E1"), lineWidth: 1)
                                )
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }

                        // Widget Mode Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Widget Mode")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "475569"))

                            VStack(alignment: .leading, spacing: 8) {
                                RadioButton(
                                    isSelected: !iconOnly,
                                    title: "Regular",
                                    subtitle: "Full widget with transcript view",
                                    onTap: { iconOnly = false }
                                )

                                RadioButton(
                                    isSelected: iconOnly,
                                    title: "Icon Only",
                                    subtitle: "Compact floating button",
                                    onTap: { iconOnly = true }
                                )
                            }
                        }

                        // Create Widget Button
                        Button(action: {
                            if assistantId.isEmpty {
                                showEmptyIdAlert = true
                            } else {
                                requestMicrophonePermission()
                            }
                        }) {
                            Text(shouldInitialize ? "Hide Widget" : "Create Widget")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(shouldInitialize ? Color.red : Color(hex: "6366F1"))
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)

                    // Widget Display Area
                    if shouldInitialize && !assistantId.isEmpty {
                        if iconOnly {
                            // Icon-only mode: fixed size floating button
                            AIAssistantWidget(
                                assistantId: assistantId,
                                shouldInitialize: true,
                                iconOnly: iconOnly
                            )
                            .frame(width: 80, height: 80)
                        } else {
                            // Regular mode: flexible height for expanded states
                            AIAssistantWidget(
                                assistantId: assistantId,
                                shouldInitialize: true,
                                iconOnly: iconOnly
                            )
                            .padding(.horizontal, 20)
                        }
                    }

                    // Instructions Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1E293B"))

                        VStack(alignment: .leading, spacing: 8) {
                            InstructionRow(number: "1", text: "Enter your Assistant ID from the Telnyx Portal")
                            InstructionRow(number: "2", text: "Choose your preferred widget mode")
                            InstructionRow(number: "3", text: "Tap 'Create Widget' to initialize the assistant")
                            InstructionRow(number: "4", text: "Tap the widget to start a voice conversation")
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "F8FAFC"))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(Color.white)
            .navigationBarTitle("Telnyx Voice AI Widget", displayMode: .large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert("Assistant ID Required", isPresented: $showEmptyIdAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter an Assistant ID to continue")
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

// MARK: - Helper Views

struct RadioButton: View {
    let isSelected: Bool
    let title: String
    let subtitle: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "6366F1") : Color(hex: "CBD5E1"), lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(Color(hex: "6366F1"))
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "1E293B"))

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "64748B"))
                }

                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color(hex: "6366F1") : Color(hex: "E2E8F0"), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InstructionRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "6366F1"))
                .frame(width: 24, height: 24)
                .background(Color(hex: "6366F1").opacity(0.1))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "475569"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
