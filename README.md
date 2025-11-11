# iOS Telnyx Voice AI Widget

A drop-in iOS widget library for integrating Telnyx AI Assistant functionality into your applications.

## Features

- 🎯 **Drop-in Solution**: Easy integration with minimal setup using SwiftUI
- 🎨 **Multiple UI States**: Collapsed, loading, expanded, and transcript views
- 🎵 **Audio Visualizer**: Real-time audio visualization during conversations
- 🌓 **Theme Support**: Light and dark theme compatibility
- 📱 **Responsive Design**: Optimized for various screen sizes
- 🔊 **Voice Controls**: Mute/unmute and call management
- 💬 **Transcript View**: Full conversation history with text input
- 🎨 **Icon-Only Mode**: Floating action button for minimal space usage

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter repository URL: `https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git`
3. Select version and add to your target

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
<string>We need access to your microphone to enable voice conversations with the AI assistant</string>
```

### 2. Basic Usage

```swift
import SwiftUI
import TelnyxVoiceAIWidget

struct ContentView: View {
    @State private var showWidget = false

    var body: some View {
        VStack {
            AIAssistantWidget(
                assistantId: "your-assistant-id",
                shouldInitialize: showWidget
            )
        }
    }
}
```

### 3. Icon-Only Mode (Floating Action Button)

The widget supports an icon-only mode that displays as a floating action button:

```swift
AIAssistantWidget(
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

### 4. Call Parameters Customization

The widget supports customizing call parameters through the `CallParams` struct. This allows you to override default values for caller information and pass dynamic data to your AI assistant through custom headers:

```swift
import TelnyxVoiceAIWidget

// Create custom call parameters
let callParams = CallParams(
    callerName: "John Doe",
    callerNumber: "+1234567890",
    destinationNumber: "custom-destination",
    customHeaders: [
        "X-User-ID": "12345",
        "X-Session-ID": "abc-123",
        "X-Account-Number": "ACC-98765"
    ]
)

// Use with the widget
AIAssistantWidget(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    callParams: callParams
)
```

#### CallParams Properties:

All properties are optional and will use default values when not provided:

- **`callerName`**: The name displayed as the caller (default: "Anonymous User")
- **`callerNumber`**: The phone number used as caller ID (default: "anonymous")
- **`destinationNumber`**: The destination for the call (default: "xxx")
- **`clientState`**: Custom client state data to pass additional context (default: nil)
- **`customHeaders`**: Dictionary of custom headers to send with the call (default: empty)

#### Custom Headers

Custom headers allow you to pass dynamic data from your application to your AI assistant. These headers must follow specific conventions:

**Header Naming Convention:**
- Headers **must** start with the `X-` prefix (e.g., `X-User-ID`, `X-Account-Number`)
- Header names are converted to variable names in your AI assistant:
  - `X-User-ID` becomes `{{user_id}}`
  - `X-Account-Number` becomes `{{account_number}}`
  - `X-Session-ID` becomes `{{session_id}}`
- Hyphens in header names are automatically converted to underscores in variable names

**Common Use Cases:**
- **User Identification**: Pass user IDs or session tokens
- **Account Context**: Send account numbers or customer details
- **Session Management**: Track conversation sessions
- **Metadata**: Include any custom data your AI assistant needs

**Example:**
```swift
let callParams = CallParams(
    callerName: "Customer Support",
    customHeaders: [
        "X-User-ID": "user_12345",
        "X-Department": "sales",
        "X-Priority-Level": "high",
        "X-Customer-Tier": "premium"
    ]
)
```

In your AI assistant configuration, you can then reference these values:
- `{{user_id}}` → "user_12345"
- `{{department}}` → "sales"
- `{{priority_level}}` → "high"
- `{{customer_tier}}` → "premium"

#### Usage Examples:

```swift
// Minimal customization - only caller name
let basicParams = CallParams(callerName: "Customer Support")

// With client state for additional context
let stateParams = CallParams(
    callerName: "Jane Smith",
    clientState: "custom-state-data"
)

// With custom headers for user context
let contextParams = CallParams(
    callerName: "Jane Smith",
    customHeaders: [
        "X-User-ID": "usr_123",
        "X-Account-Type": "premium"
    ]
)

// Full customization with client state and headers
let fullParams = CallParams(
    callerName: "Jane Smith",
    callerNumber: "+1555123456",
    destinationNumber: "support-ai",
    clientState: "custom-state-data",
    customHeaders: [
        "X-User-ID": "usr_456",
        "X-Session-ID": "session_789",
        "X-Department": "sales",
        "X-Priority": "high",
        "X-Language": "en-US"
    ]
)

// Use empty values to explicitly use defaults
let defaultParams = CallParams() // All parameters will use defaults
```

### 5. Understanding `shouldInitialize` Parameter

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
AIAssistantWidget(
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

            AIAssistantWidget(
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
        AIAssistantWidget(
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
        AIAssistantWidget(
            assistantId: "your-assistant-id",
            shouldInitialize: initializeWidget
        )
        .onAppear {
            // Initialize after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                initializeWidget = true
            }
        }
    }
}
```

## Customization

### Color Customization

The widget supports extensive color customization through the `WidgetCustomization` struct:

```swift
let customization = WidgetCustomization(
    audioVisualizerColor: "twilight",        // Gradient preset name
    transcriptBackgroundColor: .white,       // Transcript background
    userBubbleBackgroundColor: .blue,        // User message bubbles
    agentBubbleBackgroundColor: .gray,       // Agent message bubbles
    userBubbleTextColor: .white,             // User message text
    agentBubbleTextColor: .black,            // Agent message text
    muteButtonBackgroundColor: .blue,        // Mute button default
    muteButtonActiveBackgroundColor: .red,   // Mute button when active
    muteButtonIconColor: .white,             // Mute button icon
    widgetSurfaceColor: .white,              // Widget background
    primaryTextColor: .black,                // Primary text
    secondaryTextColor: .gray,               // Secondary text
    inputBackgroundColor: .lightGray         // Input field background
)

AIAssistantWidget(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    customization: customization
)
```

### Audio Visualizer Presets

Available gradient presets for the audio visualizer:
- `"verdant"` - Green gradient
- `"twilight"` - Purple/blue gradient  
- `"bloom"` - Pink/orange gradient
- `"mystic"` - Teal gradient
- `"flare"` - Red/orange gradient
- `"glacier"` - Blue/cyan gradient

### View Customization (Advanced)

For advanced UI customization, you can provide custom views that completely replace the default button components. These parameters accept `AnyView` type, so you need to wrap your custom views with `AnyView()`:

```swift
AIAssistantWidget(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    iconOnly: false,
    customization: customization,
    widgetButtonModifier: AnyView(
        // This view completely replaces the button container's styling
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.blue.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue, lineWidth: 2)
            )
    ),
    buttonTextModifier: AnyView(
        // This view completely replaces the default button text
        Text("Start Conversation")
            .font(.headline)
            .foregroundColor(.blue)
    ),
    buttonImageModifier: AnyView(
        // This view completely replaces the default icon/image
        Image(systemName: "mic.fill")
            .resizable()
            .frame(width: 32, height: 32)
            .foregroundColor(.blue)
    )
)
```

**Important**: These parameters replace the entire view component, not just modify it. For example:
- `buttonTextModifier` replaces the entire text view (ignoring `settings.startCallText`)
- `buttonImageModifier` replaces the entire icon/logo view (ignoring `settings.logoIconUrl`)
- `widgetButtonModifier` replaces the button's container styling
- `expandedWidgetModifier` replaces the expanded widget's container styling

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `assistantId` | String | Your Telnyx Assistant ID (required) |
| `shouldInitialize` | Bool | Controls network connection lifecycle (default: `true`) |
| `iconOnly` | Bool | Enable floating action button mode (default: `false`) |
| `customization` | WidgetCustomization? | Custom color overrides (default: `nil`) |
| `widgetButtonModifier` | AnyView? | Custom view to replace the collapsed button's container styling (default: `nil`) |
| `expandedWidgetModifier` | AnyView? | Custom view to replace the expanded widget's container styling (default: `nil`) |
| `buttonTextModifier` | AnyView? | Custom view to completely replace the button's text (default: `nil`) |
| `buttonImageModifier` | AnyView? | Custom view to completely replace the button's icon/logo (default: `nil`) |

**Note**: All parameters except `assistantId` are optional. The view customization parameters completely replace their respective components and require wrapping your custom views with `AnyView()` - see the View Customization section above for examples.

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

## Customization

The widget automatically fetches configuration from your Telnyx Assistant settings, including:

- Custom button text
- Logo/icon URLs
- Theme preferences
- Audio visualizer settings
- Status messages

## Example App

Check out the included example app in the `SampleApp` folder for a complete implementation:

```bash
cd SampleApp
open SampleApp.xcodeproj
```

The sample app demonstrates:
- Basic widget integration
- Permission handling
- Icon-only vs regular mode
- Assistant ID configuration
- Real-time widget state management

## SDK Components

### Core Components

The SDK is organized into the following main components:

#### 1. **AIAssistantWidget**
The main entry point for integrating the widget into your application.

**Location**: `Views/AIAssistantWidget.swift`

**Purpose**: Provides the complete UI and lifecycle management for AI Assistant interactions.

**Key Parameters**:
- `assistantId: String` - Your Telnyx AI Assistant ID (required)
- `shouldInitialize: Bool` - Controls network connection lifecycle
- `iconOnly: Bool` - Toggle between full widget and floating action button mode
- `customization: WidgetCustomization?` - Custom color overrides

**Example**:
```swift
AIAssistantWidget(
    assistantId: "your-assistant-id",
    shouldInitialize: true,
    iconOnly: false,
    customization: WidgetCustomization(
        audioVisualizerColor: "twilight",
        userBubbleBackgroundColor: .blue
    )
)
```

#### 2. **WidgetViewModel**
Manages the widget's state, business logic, and WebRTC connections.

**Location**: `ViewModels/WidgetViewModel.swift`

**Purpose**: Handles socket connections, call management, transcript updates, and state transitions.

**Key Methods**:
- `initialize(assistantId:iconOnly:customization:)` - Initialize the widget with configuration
- `startCall()` - Initiate a call to the AI assistant
- `endCall()` - Terminate the active call
- `toggleMute()` - Toggle microphone mute state
- `sendTextMessage(_:)` - Send a text message during conversation

**Published Properties**:
- `widgetState: WidgetState` - Current widget state
- `widgetSettings: WidgetSettings` - Configuration from Telnyx
- `transcriptItems: [TranscriptItem]` - Conversation history
- `audioLevels: [Float]` - Real-time audio visualization data

#### 3. **WidgetState**
An enum representing all possible widget states.

**Location**: `State/WidgetState.swift`

**States**:
- `.idle` - Initial state before initialization
- `.loading` - Loading during connection
- `.collapsed(settings)` - Collapsed button state
- `.connecting(settings)` - Initiating call
- `.expanded(settings, isConnected, isMuted, agentStatus)` - Active call with visualizer
- `.transcriptView(settings, isConnected, isMuted, agentStatus)` - Full transcript view
- `.error(message, type)` - Error state with details

#### 4. **WidgetCustomization**
Configuration struct for custom color theming.

**Location**: `Models/WidgetCustomization.swift`

**Customizable Colors**:
```swift
WidgetCustomization(
    audioVisualizerColor: "twilight",        // Gradient preset name
    transcriptBackgroundColor: .white,       // Transcript background
    userBubbleBackgroundColor: .blue,        // User message bubbles
    agentBubbleBackgroundColor: .gray,       // Agent message bubbles
    userBubbleTextColor: .white,             // User message text
    agentBubbleTextColor: .black,            // Agent message text
    muteButtonBackgroundColor: .blue,        // Mute button default
    muteButtonActiveBackgroundColor: .red,   // Mute button when active
    muteButtonIconColor: .white,             // Mute button icon
    widgetSurfaceColor: .white,              // Widget background
    primaryTextColor: .black,                // Primary text
    secondaryTextColor: .gray,               // Secondary text
    inputBackgroundColor: .lightGray         // Input field background
)
```

**Audio Visualizer Presets**:
- `"verdant"` - Green gradient
- `"twilight"` - Purple/blue gradient
- `"bloom"` - Pink/orange gradient
- `"mystic"` - Teal gradient
- `"flare"` - Red/orange gradient
- `"glacier"` - Blue/cyan gradient

#### 5. **UI Components**

**AudioVisualizer** (`Views/Components/AudioVisualizer.swift`)
- Real-time audio visualization with configurable gradient colors
- Responds to audio levels from WebRTC stream

**TranscriptView** (`Views/Components/TranscriptView.swift`)
- Full conversation history display
- Text input for typing messages
- Auto-scroll to latest messages

**ExpandedWidget** (`Views/Components/ExpandedWidget.swift`)
- Active call interface with audio visualizer
- Mute/unmute controls
- Agent status indicators

**FloatingButton** (`Views/Components/FloatingButton.swift`)
- Circular floating action button for icon-only mode
- Error state visualization

### Data Models

#### **WidgetSettings**
Configuration received from Telnyx AI Assistant settings:

```swift
struct WidgetSettings {
    let agentThinkingText: String?           // Text shown when agent is processing
    let audioVisualizerConfig: AudioVisualizerConfig?
    let defaultState: String?                // Initial widget state
    let logoIconUrl: String?                 // Custom logo URL
    let startCallText: String?               // Custom button text
    let speakToInterruptText: String?        // Interrupt instruction text
    let theme: String?                       // Theme preference ("light"/"dark")
}
```

#### **TranscriptItem**
Represents a single message in the conversation:

```swift
struct TranscriptItem {
    let id: String           // Unique identifier
    let text: String         // Message content
    let isUser: Bool         // true if from user, false if from agent
    let timestamp: Date      // When the message was sent
}
```

#### **AgentStatus**
Current state of the AI agent:

```swift
enum AgentStatus {
    case idle      // No active conversation
    case thinking  // Processing user input
    case waiting   // Ready and can be interrupted
}
```

### Integration Patterns

#### Basic Integration
```swift
import TelnyxVoiceAIWidget

struct MyView: View {
    var body: some View {
        AIAssistantWidget(
            assistantId: "your-assistant-id",
            shouldInitialize: true
        )
    }
}
```

#### Advanced Integration with Custom Colors
```swift
struct AdvancedView: View {
    let customization = WidgetCustomization(
        audioVisualizerColor: "twilight",
        userBubbleBackgroundColor: Color(hex: "#007AFF"),
        agentBubbleBackgroundColor: Color(hex: "#E5E5EA"),
        widgetSurfaceColor: .white
    )

    var body: some View {
        AIAssistantWidget(
            assistantId: "your-assistant-id",
            shouldInitialize: true,
            customization: customization
        )
    }
}
```

#### Conditional Initialization
```swift
struct ConditionalView: View {
    @State private var hasPermissions = false
    @State private var isEnabled = false

    var body: some View {
        AIAssistantWidget(
            assistantId: "your-assistant-id",
            shouldInitialize: hasPermissions && isEnabled
        )
        .onAppear {
            checkMicrophonePermission { granted in
                hasPermissions = granted
            }
        }
    }
}
```

## Architecture

The widget is built using:

- **SwiftUI** for modern UI
- **Combine** for reactive state management
- **ObservableObject** and **@Published** for state updates
- **Telnyx WebRTC SDK** for voice communication

**Architecture Diagram**:
```
┌─────────────────────────┐
│   AIAssistantWidget     │  ← Main SwiftUI View
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   WidgetViewModel       │  ← State & Business Logic
│                         │
│  • TxClient (WebRTC)    │  ← Telnyx SDK Integration
│  • Socket Connection    │
│  • Call Management      │
│  • Transcript Updates   │
└───────────┬─────────────┘
            │
            ↓
┌─────────────────────────┐
│   WidgetState           │  ← State Machine
│                         │
│  • idle → loading       │
│  • collapsed → expanded │
│  • transcriptView       │
│  • error                │
└─────────────────────────┘
```

## Requirements

- iOS 13.0+
- Xcode 14.0+
- Swift 5.9+

## Development

### Building the Project

```bash
swift build
```

### Running Tests

```bash
swift test
```

### Running the Sample App

To run the example app and test the widget:

1. Open the workspace:
```bash
open TelnyxVoiceAIWidget.xcworkspace
```

2. Select the `SampleApp` scheme
3. Build and run (⌘R)

### CI/CD

This project includes:
- **Automated Testing**: Unit tests and build validation on every PR via Fastlane
- **GitHub Actions**: Continuous integration pipeline
- **Test Reports**: Generated test coverage and results in the `reports` directory

To run tests locally via Fastlane:

```bash
bundle install
bundle exec fastlane test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Troubleshooting

### Common Issues

**Widget not initializing:**
- Verify your Assistant ID is correct
- Check network connectivity
- Ensure microphone permissions are granted

**Audio not working:**
- Check microphone permissions in Settings
- Verify device is not in silent mode
- Test with different audio routes (speaker/earpiece)

**Build errors:**
- Ensure iOS 13.0+ deployment target
- Verify Swift 5.0+ compatibility
- Check that all dependencies are properly resolved

**Widget not responding:**
- Verify `shouldInitialize` is set to `true`
- Check console logs for WebRTC connection errors
- Ensure Assistant ID is valid and active

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support and questions:
- 📧 Email: support@telnyx.com
- 📖 Documentation: [Telnyx Developer Portal](https://developers.telnyx.com)
- 🐛 Issues: [GitHub Issues](https://github.com/team-telnyx/ios-telnyx-voice-ai-widget/issues)