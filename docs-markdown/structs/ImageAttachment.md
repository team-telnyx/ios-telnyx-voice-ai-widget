**STRUCT**

# `ImageAttachment`

```swift
public struct ImageAttachment: Identifiable, Equatable
```

Represents an image attachment in a transcript item

## Properties
### `id`

```swift
public let id: String
```

### `base64Data`

```swift
public let base64Data: String
```

### `previewImage`

```swift
public let previewImage: Data?
```

## Methods
### `init(id:base64Data:previewImage:)`

```swift
public init(
    id: String = UUID().uuidString,
    base64Data: String,
    previewImage: Data? = nil
)
```
