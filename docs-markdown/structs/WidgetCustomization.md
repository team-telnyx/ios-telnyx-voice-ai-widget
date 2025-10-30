**STRUCT**

# `WidgetCustomization`

```swift
public struct WidgetCustomization
```

Customization options for the AI Assistant Widget
These colors take priority over socket-received theme colors

## Properties
### `audioVisualizerColor`

```swift
public var audioVisualizerColor: String?
```

Custom audio visualizer gradient color scheme
Options: "verdant", "twilight", "bloom", "mystic", "flare", "glacier"

### `transcriptBackgroundColor`

```swift
public var transcriptBackgroundColor: Color?
```

Custom background color for transcript view

### `userBubbleBackgroundColor`

```swift
public var userBubbleBackgroundColor: Color?
```

Custom background color for user message bubbles

### `agentBubbleBackgroundColor`

```swift
public var agentBubbleBackgroundColor: Color?
```

Custom background color for agent message bubbles

### `userBubbleTextColor`

```swift
public var userBubbleTextColor: Color?
```

Custom text color for user messages

### `agentBubbleTextColor`

```swift
public var agentBubbleTextColor: Color?
```

Custom text color for agent messages

### `muteButtonBackgroundColor`

```swift
public var muteButtonBackgroundColor: Color?
```

Custom background color for mute button when not muted

### `muteButtonActiveBackgroundColor`

```swift
public var muteButtonActiveBackgroundColor: Color?
```

Custom background color for mute button when muted

### `muteButtonIconColor`

```swift
public var muteButtonIconColor: Color?
```

Custom icon color for mute button

### `widgetSurfaceColor`

```swift
public var widgetSurfaceColor: Color?
```

Custom widget surface/background color

### `primaryTextColor`

```swift
public var primaryTextColor: Color?
```

Custom primary text color

### `secondaryTextColor`

```swift
public var secondaryTextColor: Color?
```

Custom secondary text color

### `inputBackgroundColor`

```swift
public var inputBackgroundColor: Color?
```

Custom input field background color

## Methods
### `init(audioVisualizerColor:transcriptBackgroundColor:userBubbleBackgroundColor:agentBubbleBackgroundColor:userBubbleTextColor:agentBubbleTextColor:muteButtonBackgroundColor:muteButtonActiveBackgroundColor:muteButtonIconColor:widgetSurfaceColor:primaryTextColor:secondaryTextColor:inputBackgroundColor:)`

```swift
public init(
    audioVisualizerColor: String? = nil,
    transcriptBackgroundColor: Color? = nil,
    userBubbleBackgroundColor: Color? = nil,
    agentBubbleBackgroundColor: Color? = nil,
    userBubbleTextColor: Color? = nil,
    agentBubbleTextColor: Color? = nil,
    muteButtonBackgroundColor: Color? = nil,
    muteButtonActiveBackgroundColor: Color? = nil,
    muteButtonIconColor: Color? = nil,
    widgetSurfaceColor: Color? = nil,
    primaryTextColor: Color? = nil,
    secondaryTextColor: Color? = nil,
    inputBackgroundColor: Color? = nil
)
```
