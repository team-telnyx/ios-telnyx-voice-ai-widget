**STRUCT**

# `WidgetSettings`

```swift
public struct WidgetSettings: Codable, Equatable
```

Widget settings received from Telnyx AI configuration
Note: Full definition is in Models/WidgetSettings.swift
This struct is kept here for backward compatibility but should import from Models

## Properties
### `agentThinkingText`

```swift
public let agentThinkingText: String?
```

### `audioVisualizerConfig`

```swift
public let audioVisualizerConfig: AudioVisualizerConfig?
```

### `defaultState`

```swift
public let defaultState: String?
```

### `giveFeedbackUrl`

```swift
public let giveFeedbackUrl: String?
```

### `logoIconUrl`

```swift
public let logoIconUrl: String?
```

### `position`

```swift
public let position: String?
```

### `reportIssueUrl`

```swift
public let reportIssueUrl: String?
```

### `speakToInterruptText`

```swift
public let speakToInterruptText: String?
```

### `startCallText`

```swift
public let startCallText: String?
```

### `theme`

```swift
public let theme: String?
```

### `viewHistoryUrl`

```swift
public let viewHistoryUrl: String?
```

## Methods
### `init(agentThinkingText:audioVisualizerConfig:defaultState:giveFeedbackUrl:logoIconUrl:position:reportIssueUrl:speakToInterruptText:startCallText:theme:viewHistoryUrl:)`

```swift
public init(
    agentThinkingText: String? = nil,
    audioVisualizerConfig: AudioVisualizerConfig? = nil,
    defaultState: String? = nil,
    giveFeedbackUrl: String? = nil,
    logoIconUrl: String? = nil,
    position: String? = nil,
    reportIssueUrl: String? = nil,
    speakToInterruptText: String? = nil,
    startCallText: String? = nil,
    theme: String? = nil,
    viewHistoryUrl: String? = nil
)
```
