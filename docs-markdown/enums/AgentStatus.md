**ENUM**

# `AgentStatus`

```swift
public enum AgentStatus: Equatable
```

Represents the agent's current status

## Cases
### `idle`

```swift
case idle
```

Agent is idle (no active conversation)

### `thinking`

```swift
case thinking
```

Agent is thinking/processing user input

### `waiting`

```swift
case waiting
```

Agent is waiting and can be interrupted
