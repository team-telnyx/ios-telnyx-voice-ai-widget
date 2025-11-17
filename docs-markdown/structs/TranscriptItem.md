**STRUCT**

# `TranscriptItem`

```swift
public struct TranscriptItem: Identifiable, Equatable
```

Represents a transcript item in the conversation

## Properties
### `id`

```swift
public let id: String
```

### `text`

```swift
public let text: String
```

### `isUser`

```swift
public let isUser: Bool
```

### `timestamp`

```swift
public let timestamp: Date
```

### `attachments`

```swift
public let attachments: [ImageAttachment]
```

## Methods
### `init(id:text:isUser:timestamp:attachments:)`

```swift
public init(
    id: String,
    text: String,
    isUser: Bool,
    timestamp: Date = Date(),
    attachments: [ImageAttachment] = []
)
```
