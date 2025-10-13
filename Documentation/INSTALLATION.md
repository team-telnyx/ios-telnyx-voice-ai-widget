# TelnyxVoiceAIWidget Installation Guide

This guide provides step-by-step instructions for installing and setting up the TelnyxVoiceAIWidget in your iOS application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Project Configuration](#project-configuration)
- [Permissions Setup](#permissions-setup)
- [Basic Integration](#basic-integration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before installing the TelnyxVoiceAIWidget, ensure your project meets the following requirements:

- **iOS Deployment Target**: iOS 13.0 or later
- **Xcode Version**: Xcode 12.0 or later
- **Swift Version**: Swift 5.0 or later
- **Telnyx Account**: Active Telnyx account with AI Assistant configured

## Installation Methods

### Method 1: Swift Package Manager (Recommended)

Swift Package Manager is the recommended way to install the TelnyxVoiceAIWidget.

#### Through Xcode (GUI Method)

1. **Open your project in Xcode**
2. **Navigate to File → Add Package Dependencies**
3. **Enter the repository URL:**
   ```
   https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git
   ```
4. **Select the version:**
   - Choose "Up to Next Major Version" and enter `1.0.0`
   - Or select a specific version/branch as needed
5. **Add to target:**
   - Select your app target
   - Click "Add Package"
6. **Import in your code:**
   ```swift
   import TelnyxVoiceAIWidget
   ```

#### Through Package.swift (Command Line Method)

If you're using Swift Package Manager from the command line:

1. **Add the dependency to your `Package.swift` file:**
   ```swift
   // swift-tools-version:5.9
   import PackageDescription

   let package = Package(
       name: "YourApp",
       platforms: [
           .iOS(.v13)
       ],
       dependencies: [
           .package(url: "https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git", from: "1.0.0")
       ],
       targets: [
           .target(
               name: "YourApp",
               dependencies: [
                   .product(name: "TelnyxVoiceAIWidget", package: "ios-telnyx-voice-ai-widget")
               ]
           )
       ]
   )
   ```

2. **Run the following command:**
   ```bash
   swift package resolve
   ```

### Method 2: CocoaPods

If you prefer using CocoaPods:

1. **Install CocoaPods** (if not already installed):
   ```bash
   sudo gem install cocoapods
   ```

2. **Create or update your `Podfile`:**
   ```ruby
   platform :ios, '13.0'
   use_frameworks!

   target 'YourAppTarget' do
     pod 'TelnyxVoiceAIWidget', '~> 1.0.0'
   end
   ```

3. **Install the pod:**
   ```bash
   pod install
   ```

4. **Open the `.xcworkspace` file** (not the `.xcodeproj` file):
   ```bash
   open YourApp.xcworkspace
   ```

5. **Import in your code:**
   ```swift
   import TelnyxVoiceAIWidget
   ```

### Method 3: Manual Installation

For manual installation (not recommended for production):

1. **Download the source code** from the GitHub repository
2. **Drag the `TelnyxVoiceAIWidget` folder** into your Xcode project
3. **Ensure "Copy items if needed" is checked**
4. **Add to your target** and verify it appears in your project navigator
5. **Import in your code:**
   ```swift
   import TelnyxVoiceAIWidget
   ```

## Project Configuration

### 1. Update Info.plist

Add the required permissions to your `Info.plist` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Existing keys... -->
    
    <!-- Microphone permission (Required) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>This app needs microphone access to enable voice conversations with the AI assistant.</string>
    
    <!-- Camera permission (Optional - for enhanced AI interactions) -->
    <key>NSCameraUsageDescription</key>
    <string>This app may need camera access for enhanced AI interactions.</string>
    
    <!-- Network usage (Automatically handled, but good to be explicit) -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>telnyx.com</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <false/>
                <key>NSExceptionMinimumTLSVersion</key>
                <string>TLSv1.2</string>
            </dict>
        </dict>
    </dict>
</dict>
</plist>
```

### 2. Configure App Delegate (Optional)

For advanced configuration, you can initialize the SDK in your App Delegate:

```swift
import UIKit
import TelnyxVoiceAIWidget

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure the SDK early in app lifecycle
        let configuration = TelnyxVoiceAIConfiguration(
            assistantId: "your-assistant-id",
            debugMode: false // Set to true for development
        )
        
        TelnyxVoiceAIWidget.shared.initialize(with: configuration)
        
        return true
    }
}
```

### 3. Configure Scene Delegate (iOS 13+)

If using Scene Delegate:

```swift
import UIKit
import SwiftUI
import TelnyxVoiceAIWidget

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Configure the SDK
        let configuration = TelnyxVoiceAIConfiguration(
            assistantId: "your-assistant-id",
            debugMode: false
        )
        
        TelnyxVoiceAIWidget.shared.initialize(with: configuration)
        
        // Create the SwiftUI view
        let contentView = ContentView()
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
```

## Permissions Setup

### Runtime Permission Handling

Implement proper permission handling in your app:

```swift
import AVFoundation
import SwiftUI

struct PermissionManager {
    
    static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    static func checkMicrophonePermission() -> Bool {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
}

// Usage in SwiftUI
struct ContentView: View {
    @State private var hasPermission = false
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack {
            if hasPermission {
                TelnyxVoiceAIWidgetView(
                    assistantId: "your-assistant-id"
                )
            } else {
                Button("Enable Voice AI") {
                    requestPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            hasPermission = PermissionManager.checkMicrophonePermission()
        }
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone access in Settings to use voice features.")
        }
    }
    
    private func requestPermission() {
        PermissionManager.requestMicrophonePermission { granted in
            if granted {
                hasPermission = true
            } else {
                showingPermissionAlert = true
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
```

## Basic Integration

### SwiftUI Integration

Here's a complete example of integrating the widget in a SwiftUI app:

```swift
import SwiftUI
import TelnyxVoiceAIWidget

struct ContentView: View {
    @State private var showWidget = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Your app content
                Text("Welcome to My App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Tap the button below to start a voice conversation with our AI assistant.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // Telnyx Voice AI Widget
                TelnyxVoiceAIWidgetView(
                    assistantId: "your-assistant-id",
                    shouldInitialize: showWidget
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("My App")
            .onAppear {
                // Initialize widget when view appears
                showWidget = true
            }
        }
    }
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### UIKit Integration

For UIKit-based apps:

```swift
import UIKit
import SwiftUI
import TelnyxVoiceAIWidget

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVoiceAIWidget()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "My App"
    }
    
    private func setupVoiceAIWidget() {
        // Create SwiftUI view
        let widgetView = TelnyxVoiceAIWidgetView(
            assistantId: "your-assistant-id"
        )
        
        // Wrap in UIHostingController
        let hostingController = UIHostingController(rootView: widgetView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Setup constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            hostingController.view.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Build Errors

**Issue**: "No such module 'TelnyxVoiceAIWidget'"

**Solutions**:
- Ensure the package is properly added to your project
- Clean build folder (Product → Clean Build Folder)
- Restart Xcode
- Check that the target is correctly selected

#### 2. Permission Issues

**Issue**: Widget not working due to microphone permissions

**Solutions**:
- Verify `NSMicrophoneUsageDescription` is in Info.plist
- Check permission status programmatically
- Guide users to Settings if permission is denied

#### 3. Network Issues

**Issue**: Widget fails to connect

**Solutions**:
- Check internet connectivity
- Verify assistant ID is correct
- Enable debug mode to see detailed logs
- Check App Transport Security settings

#### 4. CocoaPods Issues

**Issue**: Pod installation fails

**Solutions**:
```bash
# Update CocoaPods
sudo gem install cocoapods

# Clean and reinstall
rm -rf Pods
rm Podfile.lock
pod install

# If still failing, try:
pod install --repo-update
```

#### 5. Swift Package Manager Issues

**Issue**: Package resolution fails

**Solutions**:
- File → Packages → Reset Package Caches
- File → Packages → Resolve Package Versions
- Delete derived data: ~/Library/Developer/Xcode/DerivedData

### Debug Mode

Enable debug mode for troubleshooting:

```swift
let configuration = TelnyxVoiceAIConfiguration(
    assistantId: "your-assistant-id",
    debugMode: true // Enable detailed logging
)

TelnyxVoiceAIWidget.shared.initialize(with: configuration)
```

### Logging

Check Xcode console for detailed logs when debug mode is enabled. Look for logs prefixed with `[TelnyxVoiceAI]`.

### Support

If you encounter issues not covered in this guide:

1. **Check the GitHub Issues**: [Repository Issues](https://github.com/team-telnyx/ios-telnyx-voice-ai-widget/issues)
2. **Create a new issue** with:
   - iOS version
   - Xcode version
   - SDK version
   - Detailed error description
   - Code snippets (without sensitive data)
3. **Contact Telnyx Support**: [support@telnyx.com](mailto:support@telnyx.com)

## Next Steps

After successful installation:

1. **Review the [API Documentation](API.md)** for detailed usage information
2. **Check out the sample app** in the repository
3. **Customize the widget** appearance to match your app's design
4. **Implement delegate methods** for advanced functionality
5. **Test thoroughly** on different devices and iOS versions

## Version Compatibility

| SDK Version | iOS Version | Xcode Version | Swift Version |
|-------------|-------------|---------------|---------------|
| 1.0.x       | 13.0+       | 12.0+         | 5.0+          |

For the latest compatibility information, check the [repository README](../README.md).