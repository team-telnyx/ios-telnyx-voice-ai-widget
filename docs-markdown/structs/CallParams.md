**STRUCT**

# `CallParams`

```swift
public struct CallParams
```

Parameters for customizing call initialization
All parameters are optional and will override default values when provided

## Properties
### `callerName`

```swift
public var callerName: String?
```

The name to display as the caller

### `callerNumber`

```swift
public var callerNumber: String?
```

The phone number to use as the caller number

### `destinationNumber`

```swift
public var destinationNumber: String?
```

The destination number for the call

### `clientState`

```swift
public var clientState: String?
```

Custom client state data to include with the call

### `customHeaders`

```swift
public var customHeaders: [String: String]?
```

Custom headers to include with the call

These headers need to start with the X- prefix and will be mapped to dynamic variables in the AI assistant (e.g., X-Account-Number becomes {{account_number}}).
Hyphens in header names are converted to underscores in variable names.

## Methods
### `init(callerName:callerNumber:destinationNumber:clientState:customHeaders:)`

```swift
public init(
    callerName: String? = nil,
    callerNumber: String? = nil,
    destinationNumber: String? = nil,
    clientState: String? = nil,
    customHeaders: [String: String]? = nil
)
```
