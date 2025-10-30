**EXTENSION**

# `WidgetViewModel`
```swift
extension WidgetViewModel: AIAssistantManagerDelegate
```

## Methods
### `onAIConversationMessage(_:)`

```swift
nonisolated public func onAIConversationMessage(_ message: [String: Any])
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| message | The AI conversation message content |

### `onRingingAckReceived(callId:)`

```swift
nonisolated public func onRingingAckReceived(callId: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| callId | The call ID that received the ringing acknowledgment |

### `onAIAssistantConnectionStateChanged(isConnected:targetId:)`

```swift
nonisolated public func onAIAssistantConnectionStateChanged(isConnected: Bool, targetId: String?)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| isConnected | Whether the AI assistant is connected |
| targetId | The target ID of the AI assistant |

### `onTranscriptionUpdated(_:)`

```swift
nonisolated public func onTranscriptionUpdated(_ transcriptions: [TelnyxRTC.TranscriptionItem])
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| transcriptions | The updated list of transcription items |

### `onWidgetSettingsUpdated(_:)`

```swift
nonisolated public func onWidgetSettingsUpdated(_ settings: TelnyxRTC.WidgetSettings)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| settings | The updated widget settings |

### `onCallStateUpdated(callState:callId:)`

```swift
nonisolated public func onCallStateUpdated(callState: CallState, callId: UUID)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| callState | The new state of the call (NEW, CONNECTING, RINGING, ACTIVE, HELD, DONE) |
| callId | The unique identifier of the affected call Use this to update your UI to reflect the current call state. |

### `onSessionUpdated(sessionId:)`

```swift
nonisolated public func onSessionUpdated(sessionId: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| sessionId | The new session identifier for the connection. Store this ID if you need to track or debug connection issues. |

### `onIncomingCall(call:)`

```swift
nonisolated public func onIncomingCall(call: Call)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| call | The Call object representing the incoming call. You can use this object to answer or reject the call. |

### `onPushCall(call:)`

```swift
nonisolated public func onPushCall(call: Call)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| call | The Call object created from the push notification data. This is specifically for handling calls that arrive via push notifications when the app is in the background. |

### `onRemoteCallEnded(callId:reason:)`

```swift
nonisolated public func onRemoteCallEnded(callId: UUID, reason: CallTerminationReason?)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| callId | The unique identifier of the ended call. |
| reason | Optional termination reason containing details about why the call ended. Use this to clean up any call-related UI elements or state and potentially display error messages. |

### `onSocketConnected()`

```swift
nonisolated public func onSocketConnected()
```

### `onSocketDisconnected()`

```swift
nonisolated public func onSocketDisconnected()
```

### `onClientError(error:)`

```swift
nonisolated public func onClientError(error: Error)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| error | The error that occurred. Check the error type and message for details. Common errors include authentication failures and network connectivity issues. |

### `onClientReady()`

```swift
nonisolated public func onClientReady()
```

### `onPushDisabled(success:message:)`

```swift
nonisolated public func onPushDisabled(success: Bool, message: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| success | Whether the push notification operation succeeded |
| message | Descriptive message about the operation result |