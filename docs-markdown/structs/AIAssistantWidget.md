**STRUCT**

# `AIAssistantWidget`

```swift
public struct AIAssistantWidget: View
```

Main AI Assistant Widget component

This is the entry point for integrating the AI Assistant Widget into your application.
The widget handles the complete lifecycle of AI Assistant interactions, including socket
connection, call management, and UI state transitions.

- Parameters:
  - assistantId: The Assistant ID from your Telnyx AI configuration used to establish
                 the connection to the AI service. This ID determines which AI assistant
                 configuration and capabilities are loaded.
  - shouldInitialize: Controls when the widget establishes its socket connection to Telnyx.
                      When false, the widget remains in Idle state with no network activity.
                      When true, triggers socket connection initialization and loads widget settings.
  - iconOnly: When true, displays the widget as a floating action button with only the icon.
              In this mode, tapping starts the call and opens directly into the full screen
              text view. When false, displays the regular widget button with text.
  - callParams: Optional parameters for customizing call initialization. When provided,
                these values override the default caller name, caller number, destination number,
                and client state used when creating a call.
  - widgetButtonModifier: ViewModifier applied to the widget button in collapsed state
  - expandedWidgetModifier: ViewModifier applied to the expanded widget
  - buttonTextModifier: ViewModifier applied to the text visible on the widget button
  - buttonImageModifier: ViewModifier applied to the image/icon visible on the widget button
  - customization: Optional custom colors that take priority over socket-received theme colors

## Properties
### `body`

```swift
public var body: some View
```

## Methods
### `init(assistantId:shouldInitialize:iconOnly:callParams:customization:widgetButtonModifier:expandedWidgetModifier:buttonTextModifier:buttonImageModifier:)`

```swift
public init(
    assistantId: String,
    shouldInitialize: Bool = true,
    iconOnly: Bool = false,
    callParams: CallParams? = nil,
    customization: WidgetCustomization? = nil,
    widgetButtonModifier: AnyView? = nil,
    expandedWidgetModifier: AnyView? = nil,
    buttonTextModifier: AnyView? = nil,
    buttonImageModifier: AnyView? = nil
)
```
