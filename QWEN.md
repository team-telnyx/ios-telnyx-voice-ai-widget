# Telnyx Voice AI Widget SDK for iOS

This repository contains the official iOS SDK for integrating Telnyx Voice AI Agent capabilities into iOS applications. The SDK provides a comprehensive solution for connecting to Telnyx's AI agent services using real-time voice communication.

## Overview

The TelnyxVoiceAIWidget SDK enables iOS developers to:
- **Integrate Voice AI**: Connect to Telnyx's AI agent services for natural voice interactions
- **Real-time Communication**: Establish WebRTC-based audio connections for seamless voice streaming
- **Customizable UI**: Use pre-built UI components or create custom interfaces
- **Cross-platform Consistency**: Maintain feature parity with the Android version of the SDK

## Key Features

### Core Functionality
- **Voice AI Integration**: Connect to Telnyx AI agents with real-time audio streaming
- **Session Management**: Comprehensive lifecycle management for voice sessions
- **Configuration Options**: Flexible setup for different use cases and environments
- **Error Handling**: Robust error management and recovery mechanisms

### Platform-Specific Features
- **Swift Integration**: Native Swift API designed for iOS development best practices
- **UIKit & SwiftUI Support**: Compatible with both UIKit and SwiftUI frameworks
- **iOS Ecosystem Integration**: Seamless integration with iOS audio and UI frameworks

## Technical Architecture

```
┌─────────────────────────────────────────┐
│           Your iOS Application          │
├─────────────────────────────────────────┤
│        TelnyxVoiceAIWidget SDK         │
│  ┌─────────────┬─────────────────────┐  │
│  │   UI Layer  │   Business Logic    │  │
│  │             │                     │  │
│  │ - Widgets   │ - Session Management│  │
│  │ - Views     │ - Configuration     │  │
│  │ - Controls  │ - Error Handling    │  │
│  └─────────────┴─────────────────────┘  │
├─────────────────────────────────────────┤
│        Telnyx Voice WebRTC SDK         │
├─────────────────────────────────────────┤
│           Telnyx AI Services           │
└─────────────────────────────────────────┘
```

## Requirements

### Minimum Requirements
- **iOS**: 14.0+
- **Xcode**: 16.0+
- **Swift**: 5.0+

### Dependencies
- **Telnyx Voice WebRTC iOS SDK**: Required for WebRTC audio communication
- **Starscream**: WebSocket library for real-time communication

## Installation

### Swift Package Manager (Recommended)

Add the following to your `Package.swift` file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourApp",
    dependencies: [
        .package(url: "https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: ["TelnyxVoiceAIWidget"]
        )
    ]
)
```

Or add through Xcode:
1. Go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git`
3. Select the version and add to your target

### CocoaPods

Add the following to your `Podfile`:

```ruby
platform :ios, '14.0'

target 'YourApp' do
  use_frameworks!
  pod 'TelnyxVoiceAIWidget', '~> 1.0.0'
end
```

Then run:
```bash
pod install
```

## Quick Start

### Basic Integration

```swift
import TelnyxVoiceAIWidget

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the SDK
        TelnyxVoiceAIWidget.shared.initialize()
        
        // Start a voice session
        TelnyxVoiceAIWidget.shared.startVoiceSession()
    }
}
```

### SwiftUI Integration

```swift
import SwiftUI
import TelnyxVoiceAIWidget

struct VoiceAIScreen: View {
    var body: some View {
        VStack {
            Button("Start Voice AI") {
                TelnyxVoiceAIWidget.shared.startVoiceSession()
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            TelnyxVoiceAIWidget.shared.initialize()
        }
    }
}
```

## Sample App

The repository includes a comprehensive sample application demonstrating:

### Sample App Features
- **SDK Initialization**: Proper setup and configuration
- **Voice Session Management**: Start, stop, and manage voice sessions
- **UI Integration**: Example integration with SwiftUI
- **Error Handling**: Comprehensive error management examples

### Running the Sample App
1. Open `TelnyxVoiceAIWidget.xcworkspace` in Xcode
2. Select the "SampleApp" scheme
3. Build and run on a simulator or physical device

## API Reference

### Core Classes

#### `TelnyxVoiceAIWidget`
Main entry point for the SDK functionality.

**Properties:**
- `static let version: String` - SDK version
- `static let shared: TelnyxVoiceAIWidget` - Shared instance

**Methods:**
- `initialize()` - Initialize the SDK
- `startVoiceSession()` - Start a voice AI session
- `stopVoiceSession()` - Stop the current voice session

### Usage Patterns

#### Basic Voice Session
```swift
// Initialize SDK
TelnyxVoiceAIWidget.shared.initialize()

// Start voice session
TelnyxVoiceAIWidget.shared.startVoiceSession()

// Stop when done
TelnyxVoiceAIWidget.shared.stopVoiceSession()
```

## Cross-Platform Considerations

This iOS SDK maintains feature parity with the Android version (`android-telnyx-voice-ai-widget`), ensuring consistent behavior across platforms:

### Common Features
- **Same API Structure**: Similar method names and patterns
- **Consistent Session Management**: Unified session lifecycle
- **Cross-platform Testing**: Coordinated testing across iOS and Android

### Platform Differences
- **Language**: Swift vs Kotlin/Java
- **UI Frameworks**: SwiftUI/UIKit vs Android XML/Jetpack Compose
- **Dependency Management**: Swift Package Manager vs Gradle

## Development

### Project Structure
```
TelnyxVoiceAIWidget/
├── TelnyxVoiceAIWidget/          # SDK source code
│   └── TelnyxVoiceAIWidget.swift # Main SDK class
├── Tests/                        # Unit tests
├── SampleApp/                    # Sample application
├── Documentation/                # Additional documentation
└── .swiftlint.yml                # SwiftLint configuration
```

### Building from Source
1. Clone the repository
2. Open `TelnyxVoiceAIWidget.xcworkspace` in Xcode
3. Select the appropriate scheme (SDK or SampleApp)
4. Build and test

### Code Quality and Style Guidelines

This project uses **SwiftLint** to enforce code quality and style consistency. All code contributions must adhere to the SwiftLint rules defined in `.swiftlint.yml`.

#### SwiftLint Rules
Before writing or modifying code:
1. **Review** the `.swiftlint.yml` file to understand the project's coding standards
2. **Follow** the enabled rules when writing new code
3. **Run** SwiftLint before committing: `swiftlint lint`
4. **Fix** any violations reported by SwiftLint

Key rules enforced:
- Sorted imports
- No force unwrapping
- Multiline parameters formatting
- Proper spacing and formatting
- Code documentation for public APIs

#### Running SwiftLint
```bash
# Lint all files
swiftlint lint

# Auto-fix violations where possible
swiftlint --fix

# Run via Fastlane
fastlane lint
```

**Note**: The CI pipeline automatically checks for SwiftLint violations. PRs with violations will fail the build.

## Support and Resources

### Documentation
- **API Reference**: In-code documentation and type definitions
- **Integration Guide**: Step-by-step integration instructions
- **Sample Code**: Working examples in the SampleApp

### Community and Support
- **GitHub Issues**: Report bugs and request features
- **Telnyx Developer Portal**: Comprehensive documentation and guides
- **Community Forums**: Connect with other developers

## Contributing

We welcome contributions! Please see the `CONTRIBUTING.md` file for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Version Information

- **Current Version**: 1.0.0
- **iOS Minimum**: 14.0+
- **Swift Version**: 5.0+

---

*This SDK is part of Telnyx's comprehensive voice AI ecosystem, providing consistent experiences across iOS and Android platforms.*