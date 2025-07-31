# TelnyxVoiceAIWidget

A comprehensive iOS SDK for integrating Telnyx Voice AI capabilities into your applications.

## Features

- 🎤 Voice AI integration
- 📱 Easy-to-use Swift API
- 🔧 Configurable settings
- 📦 SPM and CocoaPods support
- ✅ iOS 13+ support

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

## Usage

### Import the SDK

```swift
import TelnyxVoiceAIWidget
```

### Initialize the SDK

```swift
let configuration = TelnyxVoiceAIConfiguration(
    apiKey: "your-api-key-here",
    debugMode: true
)

TelnyxVoiceAIWidget.shared.initialize(with: configuration)
```

### Get SDK Version

```swift
print("SDK Version: \(TelnyxVoiceAIWidget.version)")
```

### Start Voice Session

```swift
TelnyxVoiceAIWidget.shared.startVoiceSession()
```

## Sample App

The repository includes a sample app demonstrating the SDK usage. Open `TelnyxVoiceAIWidget.xcworkspace` in Xcode to see the SDK and sample app together.

## Requirements

- iOS 13.0+
- Xcode 12.0+
- Swift 5.0+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
