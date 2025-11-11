//
//  ContentView.swift
//  SampleApp
//
//  Created by Guillermo Battistel on 31-07-25.
//

import AVFoundation
import SwiftUI
import TelnyxVoiceAIWidget

struct ContentView: View {
    @State private var assistantId: String = ""
    @State private var shouldInitialize: Bool = false
    @State private var iconOnly: Bool = false
    @State private var microphonePermissionGranted: Bool = false
    @State private var showPermissionAlert: Bool = false
    @State private var showEmptyIdAlert: Bool = false

    // Call Parameters
    @State private var useCustomCallParams: Bool = false
    @State private var callerName: String = "John Doe"
    @State private var callerNumber: String = "+1234567890"
    @State private var destinationNumber: String = ""

    // Custom Headers (X- prefix headers that map to AI assistant variables)
    @State private var customHeaderKey1: String = "X-User-ID"
    @State private var customHeaderValue1: String = "user_12345"
    @State private var customHeaderKey2: String = "X-Session-ID"
    @State private var customHeaderValue2: String = "session_abc123"
    @State private var customHeaderKey3: String = "X-Account-Number"
    @State private var customHeaderValue3: String = "ACC-98765"

    private let assistantIdKey = "lastAssistantId"

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

                            ZStack(alignment: .leading) {
                                if assistantId.isEmpty {
                                    Text("Enter your Assistant ID")
                                        .foregroundColor(Color(hex: "94A3B8"))
                                        .padding(.horizontal, 12)
                                }

                                TextField("", text: $assistantId)
                                    .padding(12)
                                    .foregroundColor(Color(hex: "1E293B"))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "CBD5E1"), lineWidth: 1)
                            )
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

                        // Call Parameters Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Call Parameters")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "475569"))

                                Spacer()

                                Toggle("", isOn: $useCustomCallParams)
                                    .labelsHidden()
                            }

                            if useCustomCallParams {
                                VStack(spacing: 12) {
                                    CallParamField(
                                        title: "Caller Name",
                                        text: $callerName,
                                        placeholder: "e.g., John Doe"
                                    )
                                    CallParamField(
                                        title: "Caller Number",
                                        text: $callerNumber,
                                        placeholder: "e.g., +1234567890",
                                        keyboardType: .phonePad
                                    )
                                    CallParamField(
                                        title: "Destination Number",
                                        text: $destinationNumber,
                                        placeholder: "e.g., xxx"
                                    )

                                    // Custom Headers Section
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Custom Headers")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color(hex: "475569"))
                                            .padding(.top, 8)

                                        Text("Headers with X- prefix map to AI assistant variables (e.g., X-Account-Number → {{account_number}})")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(hex: "64748B"))
                                            .fixedSize(horizontal: false, vertical: true)

                                        CustomHeaderRow(
                                            key: $customHeaderKey1,
                                            value: $customHeaderValue1
                                        )
                                        CustomHeaderRow(
                                            key: $customHeaderKey2,
                                            value: $customHeaderValue2
                                        )
                                        CustomHeaderRow(
                                            key: $customHeaderKey3,
                                            value: $customHeaderValue3
                                        )
                                    }
                                }
                                .padding(.top, 8)
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
                            Text(shouldInitialize ? "Disconnect" : "Create Widget")
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
                        let customHeaders: [String: String]? = {
                            guard useCustomCallParams else { return nil }
                            var headers: [String: String] = [:]
                            if !customHeaderValue1.isEmpty {
                                headers[customHeaderKey1] = customHeaderValue1
                            }
                            if !customHeaderValue2.isEmpty {
                                headers[customHeaderKey2] = customHeaderValue2
                            }
                            if !customHeaderValue3.isEmpty {
                                headers[customHeaderKey3] = customHeaderValue3
                            }
                            return headers.isEmpty ? nil : headers
                        }()

                        let callParams = useCustomCallParams ? CallParams(
                            callerName: callerName.isEmpty ? nil : callerName,
                            callerNumber: callerNumber.isEmpty ? nil : callerNumber,
                            destinationNumber: destinationNumber.isEmpty ? nil : destinationNumber,
                            clientState: "custom-state-data",  // Example: pass custom state to AI assistant
                            customHeaders: customHeaders
                        ) : nil

                        if iconOnly {
                            // Icon-only mode: fixed size floating button
                            AIAssistantWidget(
                                assistantId: assistantId,
                                shouldInitialize: true,
                                iconOnly: iconOnly,
                                callParams: callParams
                            )
                            .frame(width: 80, height: 80)
                        } else {
                            // Regular mode: flexible height for expanded states
                            AIAssistantWidget(
                                assistantId: assistantId,
                                shouldInitialize: true,
                                iconOnly: iconOnly,
                                callParams: callParams
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
                            InstructionRow(number: "3", text: "Optionally configure call parameters to customize caller info")
                            InstructionRow(number: "4", text: "Tap 'Create Widget' to initialize the assistant")
                            InstructionRow(number: "5", text: "Tap the widget to start a voice conversation")
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
        .onAppear {
            loadSavedAssistantId()
        }
    }

    // MARK: - Helper Methods

    private func requestMicrophonePermission() {
        // If already initialized, disconnect
        if shouldInitialize {
            shouldInitialize = false
            return
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                microphonePermissionGranted = granted
                if granted {
                    shouldInitialize = true
                    // Save assistant ID to UserDefaults
                    UserDefaults.standard.set(assistantId, forKey: assistantIdKey)
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

    private func loadSavedAssistantId() {
        if let savedId = UserDefaults.standard.string(forKey: assistantIdKey), !savedId.isEmpty {
            assistantId = savedId
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

struct CallParamField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "64748B"))

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(hex: "94A3B8"))
                        .padding(.horizontal, 10)
                }

                TextField("", text: $text)
                    .padding(10)
                    .foregroundColor(Color(hex: "1E293B"))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(keyboardType)
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(hex: "E2E8F0"), lineWidth: 1)
            )
        }
    }
}

struct CustomHeaderRow: View {
    @Binding var key: String
    @Binding var value: String

    var body: some View {
        HStack(spacing: 8) {
            // Header Key Field
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .leading) {
                    if key.isEmpty {
                        Text("X-Header-Name")
                            .foregroundColor(Color(hex: "94A3B8"))
                            .padding(.horizontal, 10)
                    }

                    TextField("", text: $key)
                        .padding(10)
                        .foregroundColor(Color(hex: "1E293B"))
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "E2E8F0"), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)

            Text(":")
                .foregroundColor(Color(hex: "64748B"))
                .font(.system(size: 14, weight: .medium))

            // Header Value Field
            VStack(alignment: .leading, spacing: 4) {
                ZStack(alignment: .leading) {
                    if value.isEmpty {
                        Text("value")
                            .foregroundColor(Color(hex: "94A3B8"))
                            .padding(.horizontal, 10)
                    }

                    TextField("", text: $value)
                        .padding(10)
                        .foregroundColor(Color(hex: "1E293B"))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "E2E8F0"), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

#Preview {
    ContentView()
}
