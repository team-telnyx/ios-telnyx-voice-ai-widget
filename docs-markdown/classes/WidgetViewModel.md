**CLASS**

# `WidgetViewModel`

```swift
public class WidgetViewModel: ObservableObject
```

ViewModel for managing the AI Assistant Widget state and interactions

## Properties
### `widgetState`

```swift
@Published public var widgetState: WidgetState = .idle
```

### `widgetSettings`

```swift
@Published public var widgetSettings = WidgetSettings()
```

### `transcriptItems`

```swift
@Published public var transcriptItems = [TranscriptItem]()
```

### `userInput`

```swift
@Published public var userInput: String = ""
```

### `audioLevels`

```swift
@Published public var audioLevels: [Float] = []
```

### `customization`

```swift
public var customization: WidgetCustomization?
```

Custom color configuration that takes priority over socket-received theme

### `callParams`

```swift
public var callParams: CallParams?
```

Call parameters for customizing call initialization

## Methods
### `init()`

```swift
public init()
```

### `deinit`

```swift
deinit
```

### `initialize(assistantId:iconOnly:callParams:customization:)`

```swift
public func initialize(assistantId: String, iconOnly: Bool = false, callParams: CallParams? = nil, customization: WidgetCustomization? = nil)
```

Initialize the widget with assistant ID
- Parameters:
  - assistantId: The Assistant ID from your Telnyx AI configuration
  - iconOnly: When true, displays as a floating action button
  - callParams: Optional parameters for customizing call initialization
  - customization: Optional custom colors that override theme-based colors

#### Parameters

| Name | Description |
| ---- | ----------- |
| assistantId | The Assistant ID from your Telnyx AI configuration |
| iconOnly | When true, displays as a floating action button |
| callParams | Optional parameters for customizing call initialization |
| customization | Optional custom colors that override theme-based colors |

### `startCall()`

```swift
public func startCall()
```

Start a call to the AI assistant

### `endCall()`

```swift
public func endCall()
```

End the current call

### `toggleMute()`

```swift
public func toggleMute()
```

Toggle mute state

### `showTranscriptView()`

```swift
public func showTranscriptView()
```

Expand to transcript view

### `collapseFromTranscriptView()`

```swift
public func collapseFromTranscriptView()
```

Collapse from transcript view to expanded view

### `updateUserInput(_:)`

```swift
public func updateUserInput(_ input: String)
```

Update user input text

### `sendMessage()`

```swift
public func sendMessage()
```

Send user message

### `sendMessageWithImages(_:)`

```swift
public func sendMessageWithImages(_ images: [UIImage])
```

Send user message with images
