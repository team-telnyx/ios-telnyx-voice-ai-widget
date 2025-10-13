# iOS Telnyx Voice AI Widget

A drop-in iOS widget library for integrating Telnyx AI Assistant functionality into your applications.

## Features

- 🎯 **Drop-in Solution**: Easy integration with minimal setup
- 🎨 **Multiple UI States**: Collapsed, loading, expanded, and transcript views
- 🎵 **Audio Visualizer**: Real-time audio visualization during conversations
- 🌓 **Theme Support**: Light and dark theme compatibility
- 📱 **Responsive Design**: Optimized for various screen sizes and orientations
- 🔊 **Voice Controls**: Mute/unmute and call management
- 💬 **Transcript View**: Full conversation history with text input
- 🎛️ **Customizable UI**: Extensive customization options for branding
- 🔒 **Secure**: Built-in security best practices for voice communication

## Installation

### Swift Package Manager (Recommended)

Add the widget library to your iOS project using Swift Package Manager:

#### Through Xcode:
1. File → Add Package Dependencies
2. Enter repository URL: `https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git`
3. Select version and add to your target

#### Through Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git", from: "1.0.0")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'TelnyxVoiceAIWidget', '~> 1.0.0'
```

Then run:
```bash
pod install
```

## Quick Start

### 1. Add Required Permissions

Add these permissions to your `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to enable voice conversations with the AI assistant.</string>
<key>NSCameraUsageDescription</key>
<string>This app may need camera access for enhanced AI interactions.</string>
```

### 2. Basic Usage

```swift
import TelnyxVoiceAIWidget
import SwiftUI

struct ContentView: View {
    @State private var showWidget = false
    
    var body: some View {
        VStack {
            // Your app content
            
            TelnyxVoiceAIWidgetView(
                assistantId: "your-assistant-id",
                shouldInitialize: showWidget
            )
        }
        .onAppear {
            showWidget = true
        }
    }
}
```

### 3. Icon-Only Mode (Floating Action Button)

The widget supports an icon-only mode that displays as a floating action button:

```swift
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    iconOnly: true // Enables floating action button mode
)
```

#### Icon-Only Mode Features:

- **Compact Design**: Displays only the icon in a circular floating action button
- **Direct Access**: Tapping starts the call and opens directly into the full-screen transcript view
- **No Expanded State**: Skips the intermediate expanded widget state
- **Error Handling**: Shows a red error icon when there are connection issues
- **Background Color**: Uses the theme's primary color for the button background

#### Icon-Only vs Regular Mode:

| Feature | Regular Mode | Icon-Only Mode |
|---------|-------------|----------------|
| **Collapsed State** | Button with text and icon | Circular floating button with icon only |
| **Tap Behavior** | Opens to expanded widget | Starts call and opens transcript view directly |
| **Expanded State** | Shows audio visualizer and controls | Skipped - goes directly to transcript |
| **Error State** | Shows detailed error card | Shows red error icon in floating button |
| **Use Case** | Full-featured integration | Minimal, space-efficient integration |

### 4. Understanding `shouldInitialize` Parameter

The `shouldInitialize` parameter controls when the widget establishes its network connection to Telnyx servers. This is crucial for controlling:

- **Network Usage**: Prevents unnecessary connections until needed
- **User Consent**: Initialize only after user grants permissions
- **Performance**: Defer connection for better app startup performance
- **Conditional Loading**: Connect based on user subscription, feature flags, etc.

#### Key Behaviors:

- **`false`**: Widget remains dormant with no network activity or UI display
- **`true`**: Triggers socket connection and loads assistant configuration
- **State Change**: Changing from `false` to `true` will initialize the connection
- **Active Sessions**: Changing from `true` to `false` does NOT disconnect active calls

#### Network Connection Lifecycle:

1. **shouldInitialize = false**: No socket connection, widget in idle state
2. **shouldInitialize = true**: Socket connects to Telnyx, widget settings load
3. **User initiates call**: WebRTC connection established for audio
4. **Call ends**: WebRTC disconnects, socket remains for future calls  
5. **shouldInitialize = false**: Does NOT affect active socket (by design)

#### Common Patterns:

```swift
// 1. Initialize immediately (default behavior)
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id",
    shouldInitialize: true  // Can be omitted as it defaults to true
)

// 2. Conditional initialization based on user action
struct ConditionalWidget: View {
    @State private var userWantsAssistant = false
    
    var body: some View {
        VStack {
            Button("Enable AI Assistant") {
                userWantsAssistant = true
            }
            
            TelnyxVoiceAIWidgetView(
                assistantId: "your-assistant-id",
                shouldInitialize: userWantsAssistant
            )
        }
    }
}

// 3. Initialize after permissions are granted
struct PermissionAwareWidget: View {
    @State private var hasPermissions = false
    
    var body: some View {
        TelnyxVoiceAIWidgetView(
            assistantId: "your-assistant-id",
            shouldInitialize: hasPermissions
        )
        .onAppear {
            checkAudioPermissions { granted in
                hasPermissions = granted
            }
        }
    }
}

// 4. Deferred initialization for performance
struct DeferredWidget: View {
    @State private var initializeWidget = false
    
    var body: some View {
        TelnyxVoiceAIWidgetView(
            assistantId: "your-assistant-id",
            shouldInitialize: initializeWidget
        )
        .onAppear {
            // Initialize after a delay or user interaction
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                initializeWidget = true
            }
        }
    }
}
```

## Customization with View Modifiers

The `TelnyxVoiceAIWidgetView` supports additional view modifiers for fine-tuned UI customization:

### Available Modifiers

```swift
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    iconOnly: false // Enable floating action button mode
)
.widgetButtonStyle(.bordered) // Applied to collapsed button
.expandedWidgetStyle(.card) // Applied to expanded widget
.buttonTextStyle(.headline) // Applied to button text
.buttonImageStyle(.circular) // Applied to button icon/logo
```

### Parameters

| Parameter | Type | Description | Applied To |
|-----------|------|-------------|------------|
| `assistantId` | String | Your Telnyx Assistant ID | Required for initialization |
| `shouldInitialize` | Bool | Controls when to establish network connection | Widget initialization |
| `iconOnly` | Bool | Enable floating action button mode | Widget display mode |

### View Modifiers

| Modifier | Description | Applied To |
|----------|-------------|------------|
| `.widgetButtonStyle(_)` | Styling for the collapsed widget button | The entire button in collapsed state |
| `.expandedWidgetStyle(_)` | Styling for the expanded widget | The entire expanded widget |
| `.buttonTextStyle(_)` | Styling for the button text | The start call text in the collapsed button (ignored in iconOnly mode) |
| `.buttonImageStyle(_)` | Styling for the button icon/logo | The image or icon displayed in the collapsed button |

### Usage Examples

```swift
// Custom button styling with rounded corners and shadow
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id"
)
.widgetButtonStyle(.bordered)
.shadow(radius: 12)
.clipShape(RoundedRectangle(cornerRadius: 32))

// Styled text and circular icon
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id"
)
.buttonTextStyle(.title2)
.buttonImageStyle(.circular)
.padding(.horizontal, 8)

// Custom expanded widget appearance
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id"
)
.expandedWidgetStyle(.card)
.background(
    LinearGradient(
        colors: [Color.blue.opacity(0.1), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )
)
```

### Combining with Overall Layout

```swift
// Complete customization example
TelnyxVoiceAIWidgetView(
    assistantId: "your-assistant-id"
)
.frame(maxWidth: .infinity) // Overall positioning
.frame(height: 64) // Custom button height
.widgetButtonStyle(.borderedProminent)
.buttonTextStyle(.headline)
.buttonImageStyle(.circular)
.padding(.horizontal, 16)
```

## Widget States

The widget automatically transitions between different states:

### 1. Collapsed State
- **Regular Mode**: Shows a compact button with customizable text and logo icon
- **Icon-Only Mode**: Shows a circular floating action button with only the icon
- Tap to initiate a call

### 2. Loading/Connecting State
- Shows loading indicator during initialization and connection
- Same behavior in both regular and icon-only modes

### 3. Expanded State
- **Regular Mode**: Audio visualizer, mute/unmute controls, agent status indicators
- **Icon-Only Mode**: This state is skipped - goes directly to transcript view
- Tap to open full transcript view (regular mode only)

### 4. Transcript View
- Full conversation history
- Text input for typing messages
- Audio controls and visualizer
- **Regular Mode**: Collapsible back to expanded view
- **Icon-Only Mode**: Primary interface for interaction

### 5. Error State
- **Regular Mode**: Shows detailed error card with retry button
- **Icon-Only Mode**: Shows red error icon in floating button

## Advanced Configuration

### Custom Configuration

```swift
let configuration = TelnyxVoiceAIConfiguration(
    assistantId: "your-assistant-id",
    apiKey: "your-api-key", // Optional: for additional authentication
    debugMode: true, // Enable debug logging
    customEndpoint: "wss://your-custom-endpoint.com" // Optional: custom WebSocket endpoint
)

TelnyxVoiceAIWidget.shared.initialize(with: configuration)
```

### Delegate Pattern

Implement the `TelnyxVoiceAIWidgetDelegate` to receive callbacks:

```swift
class ViewController: UIViewController, TelnyxVoiceAIWidgetDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        TelnyxVoiceAIWidget.shared.delegate = self
    }
    
    // MARK: - TelnyxVoiceAIWidgetDelegate
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didChangeState state: TelnyxVoiceAIWidgetState) {
        print("Widget state changed to: \(state)")
    }
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveError error: Error) {
        print("Widget error: \(error.localizedDescription)")
    }
    
    func voiceAIWidget(_ widget: TelnyxVoiceAIWidget, didReceiveTranscript transcript: String) {
        print("New transcript: \(transcript)")
    }
}
```

## Customization

The widget automatically fetches configuration from your Telnyx Assistant settings, including:

- Custom button text
- Logo/icon URLs
- Theme preferences
- Audio visualizer settings
- Status messages

## Sample App

Check out the included sample app in the `SampleApp` directory for a complete implementation:

1. Open `TelnyxVoiceAIWidget.xcworkspace` in Xcode
2. Select the SampleApp target
3. Build and run to see the widget in action

## Architecture

The widget is built using:

- **SwiftUI** for modern, declarative UI
- **Combine** for reactive programming
- **AVFoundation** for audio processing
- **WebRTC** for real-time communication
- **Starscream** for WebSocket connections

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## Development

### Building the Project

```bash
# Using Xcode
open TelnyxVoiceAIWidget.xcworkspace

# Using Swift Package Manager
swift build
```

### Running Tests

```bash
swift test
```

### Running the Sample App

1. Open `TelnyxVoiceAIWidget.xcworkspace` in Xcode
2. Select the SampleApp scheme
3. Build and run on simulator or device

## API Reference

For detailed API documentation, see [Documentation/API.md](Documentation/API.md).

## Installation Guide

For step-by-step installation instructions, see [Documentation/INSTALLATION.md](Documentation/INSTALLATION.md).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Contact Telnyx support
- Check the documentation at [telnyx.com](https://telnyx.com)
