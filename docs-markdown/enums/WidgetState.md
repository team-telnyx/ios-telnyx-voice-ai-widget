**ENUM**

# `WidgetState`

```swift
public enum WidgetState: Equatable
```

Represents the different states of the AI Assistant Widget

## Cases
### `idle`

```swift
case idle
```

Initial state before initialization

### `loading`

```swift
case loading
```

Loading state while initiating the call

### `collapsed(settings:)`

```swift
case collapsed(settings: WidgetSettings)
```

Collapsed state showing the widget button

### `connecting(settings:)`

```swift
case connecting(settings: WidgetSettings)
```

Loading state when initiating a call

### `expanded(settings:isConnected:isMuted:agentStatus:)`

```swift
case expanded(settings: WidgetSettings, isConnected: Bool, isMuted: Bool, agentStatus: AgentStatus)
```

Expanded state during an active call

### `transcriptView(settings:isConnected:isMuted:agentStatus:)`

```swift
case transcriptView(settings: WidgetSettings, isConnected: Bool, isMuted: Bool, agentStatus: AgentStatus)
```

Full transcript view state

### `error(message:type:)`

```swift
case error(message: String, type: ErrorType)
```

Error state

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: WidgetState, rhs: WidgetState) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |