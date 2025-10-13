# TelnyxVoiceAIWidget API Reference

This document provides comprehensive API documentation for the TelnyxVoiceAIWidget iOS SDK.

## Table of Contents

- [Core Classes](#core-classes)
- [SwiftUI Views](#swiftui-views)
- [Configuration](#configuration)
- [Delegates](#delegates)
- [Enums](#enums)
- [Error Handling](#error-handling)
- [Examples](#examples)

## Core Classes

### TelnyxVoiceAIWidget

The main SDK class that provides the core functionality for voice AI integration.

```swift
public class TelnyxVoiceAIWidget: NSObject
```

#### Properties

##### version
```swift
public static let version: String
```
Returns the current version of the SDK.

**Example:**
```swift
print("SDK Version: \(TelnyxVoiceAIWidget.version)")
```

##### shared
```swift
public static let shared: TelnyxVoiceAIWidget
```
Singleton instance of the TelnyxVoiceAIWidget.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.initialize(with: configuration)
```

##### delegate
```swift
public weak var delegate: TelnyxVoiceAIWidgetDelegate?
```
Delegate to receive widget events and callbacks.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.delegate = self
```

#### Methods

##### initialize(with:)
```swift
public func initialize(with configuration: TelnyxVoiceAIConfiguration)
```
Initializes the SDK with the provided configuration.

**Parameters:**
- `configuration`: A `TelnyxVoiceAIConfiguration` object containing the initialization parameters.

**Example:**
```swift
let configuration = TelnyxVoiceAIConfiguration(
    assistantId: "your-assistant-id",
    apiKey: "your-api-key",
    debugMode: true
)
TelnyxVoiceAIWidget.shared.initialize(with: configuration)
```

##### startVoiceSession()
```swift
public func startVoiceSession()
```
Starts a new voice AI session.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.startVoiceSession()
```

##### stopVoiceSession()
```swift
public func stopVoiceSession()
```
Stops the current voice AI session.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.stopVoiceSession()
```

##### muteAudio()
```swift
public func muteAudio()
```
Mutes the audio input during an active session.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.muteAudio()
```

##### unmuteAudio()
```swift
public func unmuteAudio()
```
Unmutes the audio input during an active session.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.unmuteAudio()
```

##### sendTextMessage(_:)
```swift
public func sendTextMessage(_ message: String)
```
Sends a text message to the AI assistant during an active session.

**Parameters:**
- `message`: The text message to send.

**Example:**
```swift
TelnyxVoiceAIWidget.shared.sendTextMessage("Hello, how can you help me?")
```

## SwiftUI Views

### TelnyxVoiceAIWidgetView

The main SwiftUI view component for integrating the voice AI widget.

```swift
public struct TelnyxVoiceAIWidgetView: View
```

#### Initializers

##### init(assistantId:shouldInitialize:iconOnly:)
```swift
public init(
    assistantId: String,
    shouldInitialize: Bool = true,
    iconOnly: Bool = false
)
```

**Parameters:**
- `assistantId`: Your Telnyx Assistant ID (required)
- `shouldInitialize`: Controls when to establish network connection (default: `true`)
- `iconOnly`: Enable floating action button mode (default: `false`)

**Example:**
```swift
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    iconOnly: false
)
```

#### View Modifiers

##### widgetButtonStyle(_:)
```swift
public func widgetButtonStyle(_ style: TelnyxWidgetButtonStyle) -> some View
```
Applies styling to the collapsed widget button.

**Parameters:**
- `style`: The button style to apply.

**Example:**
```swift
TelnyxVoiceAIWidgetView(assistantId: "your-assistant-id")
    .widgetButtonStyle(.bordered)
```

##### expandedWidgetStyle(_:)
```swift
public func expandedWidgetStyle(_ style: TelnyxExpandedWidgetStyle) -> some View
```
Applies styling to the expanded widget.

**Parameters:**
- `style`: The expanded widget style to apply.

**Example:**
```swift
TelnyxVoiceAIWidgetView(assistantId: "your-assistant-id")
    .expandedWidgetStyle(.card)
```

##### buttonTextStyle(_:)
```swift
public func buttonTextStyle(_ style: Font) -> some View
```
Applies text styling to the button text.

**Parameters:**
- `style`: The font style to apply.

**Example:**
```swift
TelnyxVoiceAIWidgetView(assistantId: "your-assistant-id")
    .buttonTextStyle(.headline)
```

##### buttonImageStyle(_:)
```swift
public func buttonImageStyle(_ style: TelnyxImageStyle) -> some View
```
Applies styling to the button icon/logo.

**Parameters:**
- `style`: The image style to apply.

**Example:**
```swift
TelnyxVoiceAIWidgetView(assistantId: "your-assistant-id")
    .buttonImageStyle(.circular)
```

## Configuration

### TelnyxVoiceAIConfiguration

Configuration object for initializing the SDK.

```swift
public struct TelnyxVoiceAIConfiguration
```

#### Properties

##### assistantId
```swift
public let assistantId: String
```
Your Telnyx Assistant ID (required).

##### apiKey
```swift
public let apiKey: String?
```
Optional API key for additional authentication.

##### debugMode
```swift
public let debugMode: Bool
```
Enable debug logging (default: `false`).

##### customEndpoint
```swift
public let customEndpoint: String?
```
Optional custom WebSocket endpoint URL.

##### audioSettings
```swift
public let audioSettings: TelnyxAudioSettings?
```
Optional audio configuration settings.

#### Initializers

##### init(assistantId:apiKey:debugMode:customEndpoint:audioSettings:)
```swift
public init(
    assistantId: String,
    apiKey: String? = nil,
    debugMode: Bool = false,
    customEndpoint: String? = nil,
    audioSettings: TelnyxAudioSettings? = nil
)
```

**Example:**
```swift
let configuration = TelnyxVoiceAIConfiguration(
    assistantId: "your-assistant-id",
    apiKey: "your-api-key",
    debugMode: true,
    customEndpoint: "wss://custom-endpoint.com",
    audioSettings: TelnyxAudioSettings(
        sampleRate: 16000,
        channels: 1
    )
)
```

### TelnyxAudioSettings

Audio configuration settings.

```swift
public struct TelnyxAudioSettings
```

#### Properties

##### sampleRate
```swift
public let sampleRate: Int
```
Audio sample rate in Hz (default: 16000).

##### channels
```swift
public let channels: Int
```
Number of audio channels (default: 1).

##### bitDepth
```swift
public let bitDepth: Int
```
Audio bit depth (default: 16).

#### Initializers

##### init(sampleRate:channels:bitDepth:)
```swift
public init(
    sampleRate: Int = 16000,
    channels: Int = 1,
    bitDepth: Int = 16
)
```

## Delegates

### TelnyxVoiceAIWidgetDelegate

Protocol for receiving widget events and callbacks.

```swift
public protocol TelnyxVoiceAIWidgetDelegate: AnyObject
```

#### Methods

##### voiceAIWidget(_:didChangeState:)
```swift
func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didChangeState state: TelnyxVoiceAIWidgetState)
```
Called when the widget state changes.

**Parameters:**
- `widget`: The widget instance
- `state`: The new widget state

**Example:**
```swift
func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didChangeState state: TelnyxVoiceAIWidgetState) {
    switch state {
    case .idle:
        print("Widget is idle")
    case .connecting:
        print("Widget is connecting")
    case .connected:
        print("Widget is connected")
    case .inCall:
        print("Widget is in call")
    case .error(let error):
        print("Widget error: \(error.localizedDescription)")
    }
}
```

##### voiceAIWidget(_:didReceiveError:)
```swift
func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveError error: Error)
```
Called when an error occurs.

**Parameters:**
- `widget`: The widget instance
- `error`: The error that occurred

##### voiceAIWidget(_:didReceiveTranscript:)
```swift
func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveTranscript transcript: String)
```
Called when a new transcript is received.

**Parameters:**
- `widget`: The widget instance
- `transcript`: The transcript text

##### voiceAIWidget(_:didReceiveAudioLevel:)
```swift
func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveAudioLevel level: Float)
```
Called when audio level changes (for visualizer).

**Parameters:**
- `widget`: The widget instance
- `level`: The audio level (0.0 to 1.0)

## Enums

### TelnyxVoiceAIWidgetState

Represents the current state of the widget.

```swift
public enum TelnyxVoiceAIWidgetState
```

#### Cases

##### idle
```swift
case idle
```
Widget is idle and ready to start a session.

##### connecting
```swift
case connecting
```
Widget is establishing connection.

##### connected
```swift
case connected
```
Widget is connected and ready for voice interaction.

##### inCall
```swift
case inCall
```
Widget is in an active voice session.

##### error
```swift
case error(Error)
```
Widget encountered an error.

### TelnyxWidgetButtonStyle

Button styling options for the collapsed widget.

```swift
public enum TelnyxWidgetButtonStyle
```

#### Cases

##### plain
```swift
case plain
```
Plain button style.

##### bordered
```swift
case bordered
```
Bordered button style.

##### borderedProminent
```swift
case borderedProminent
```
Prominent bordered button style.

### TelnyxExpandedWidgetStyle

Styling options for the expanded widget.

```swift
public enum TelnyxExpandedWidgetStyle
```

#### Cases

##### card
```swift
case card
```
Card-style appearance.

##### minimal
```swift
case minimal
```
Minimal appearance.

### TelnyxImageStyle

Image styling options for button icons.

```swift
public enum TelnyxImageStyle
```

#### Cases

##### square
```swift
case square
```
Square image style.

##### circular
```swift
case circular
```
Circular image style.

##### rounded
```swift
case rounded
```
Rounded corners image style.

## Error Handling

### TelnyxVoiceAIError

Error types that can occur during SDK usage.

```swift
public enum TelnyxVoiceAIError: Error
```

#### Cases

##### invalidConfiguration
```swift
case invalidConfiguration(String)
```
Configuration is invalid.

##### connectionFailed
```swift
case connectionFailed(String)
```
Failed to establish connection.

##### authenticationFailed
```swift
case authenticationFailed
```
Authentication failed.

##### permissionDenied
```swift
case permissionDenied(String)
```
Required permission was denied.

##### networkError
```swift
case networkError(Error)
```
Network-related error occurred.

##### audioError
```swift
case audioError(String)
```
Audio-related error occurred.

## Examples

### Basic Integration

```swift
import SwiftUI
import TelnyxVoiceAIWidget

struct ContentView: View {
    var body: some View {
        VStack {
            Text("My App")
                .font(.title)
            
            Spacer()
            
            TelnyxVoiceAIWidgetView(
                assistantId: "your-assistant-id"
            )
            .padding()
        }
    }
}
```

### Advanced Integration with Delegate

```swift
import SwiftUI
import TelnyxVoiceAIWidget

class VoiceAIManager: ObservableObject, TelnyxVoiceAIWidgetDelegate {
    @Published var isConnected = false
    @Published var currentTranscript = ""
    @Published var audioLevel: Float = 0.0
    
    init() {
        let configuration = TelnyxVoiceAIConfiguration(
            assistantId: "your-assistant-id",
            debugMode: true
        )
        
        TelnyxVoiceAIWidget.shared.initialize(with: configuration)
        TelnyxVoiceAIWidget.shared.delegate = self
    }
    
    // MARK: - TelnyxVoiceAIWidgetDelegate
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didChangeState state: TelnyxVoiceAIWidgetState) {
        DispatchQueue.main.async {
            switch state {
            case .connected, .inCall:
                self.isConnected = true
            case .idle, .connecting:
                self.isConnected = false
            case .error(let error):
                self.isConnected = false
                print("Widget error: \(error.localizedDescription)")
            }
        }
    }
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveTranscript transcript: String) {
        DispatchQueue.main.async {
            self.currentTranscript = transcript
        }
    }
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveAudioLevel level: Float) {
        DispatchQueue.main.async {
            self.audioLevel = level
        }
    }
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveError error: Error) {
        print("Widget error: \(error.localizedDescription)")
    }
}

struct ContentView: View {
    @StateObject private var voiceAIManager = VoiceAIManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Voice AI Status: \(voiceAIManager.isConnected ? "Connected" : "Disconnected")")
                .foregroundColor(voiceAIManager.isConnected ? .green : .red)
            
            if !voiceAIManager.currentTranscript.isEmpty {
                Text("Transcript: \(voiceAIManager.currentTranscript)")
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Audio level indicator
            ProgressView(value: voiceAIManager.audioLevel)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 10)
            
            TelnyxVoiceAIWidgetView(
                assistantId: "your-assistant-id"
            )
            .widgetButtonStyle(.borderedProminent)
            .buttonTextStyle(.headline)
            .padding()
        }
        .padding()
    }
}
```

### Custom Styling Example

```swift
struct CustomStyledWidget: View {
    var body: some View {
        TelnyxVoiceAIWidgetView(
            assistantId: "your-assistant-id",
            iconOnly: false
        )
        .widgetButtonStyle(.bordered)
        .buttonTextStyle(.title2)
        .buttonImageStyle(.circular)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(30)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
    }
}
```

### Permission Handling Example

```swift
import AVFoundation

struct PermissionAwareWidget: View {
    @State private var hasAudioPermission = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack {
            if hasAudioPermission {
                TelnyxVoiceAIWidgetView(
                    assistantId: "your-assistant-id",
                    shouldInitialize: hasAudioPermission
                )
            } else {
                Button("Enable Voice AI") {
                    requestAudioPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone access in Settings to use voice features.")
        }
        .onAppear {
            checkAudioPermission()
        }
    }
    
    private func checkAudioPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasAudioPermission = true
        case .denied:
            hasAudioPermission = false
        case .undetermined:
            hasAudioPermission = false
        @unknown default:
            hasAudioPermission = false
        }
    }
    
    private func requestAudioPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    hasAudioPermission = true
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
}
```

This API reference provides comprehensive documentation for all public interfaces of the TelnyxVoiceAIWidget SDK. For additional examples and implementation details, refer to the sample app included in the repository.