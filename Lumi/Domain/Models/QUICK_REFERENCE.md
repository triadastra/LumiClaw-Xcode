# Quick Reference: SwiftUI Window Management

## File Structure

```
LumiAgent/
├── QuickActionPanelController.swift   [✅ UPDATED]
│   ├── QuickActionType enum
│   ├── QuickActionPanelController
│   ├── AgentReplyBubbleController
│   ├── AgentReplyBubbleModel
│   ├── QuickActionPanelView
│   ├── QuickActionButton
│   ├── AgentReplyBubbleView
│   ├── QuickActionPanelWindowView     [NEW]
│   └── AgentReplyBubbleWindowView     [NEW]
│
├── WindowManager.swift                 [✅ NEW FILE]
│   ├── WindowManager singleton
│   ├── openQuickActionPanel()
│   ├── openAgentReplyBubble()
│   └── Notification extensions
│
├── LumiAgentApp.swift                  [✅ UPDATED]
│   └── Added Window scenes
│
├── SWIFTUI_MIGRATION_GUIDE.md         [📖 DOCS]
├── MIGRATION_SUMMARY.md                [📖 DOCS]
└── QUICK_REFERENCE.md                  [📖 THIS FILE]
```

## Key Classes

### QuickActionPanelController
```swift
// Singleton, thread-safe
@MainActor final class QuickActionPanelController: ObservableObject {
    static let shared
    @Published var isVisible: Bool
    func show(onAction: (QuickActionType) -> Void)
    func hide()
    func toggle(onAction: (QuickActionType) -> Void)
    func triggerAction(_ type: QuickActionType)
}
```

### AgentReplyBubbleController
```swift
// Singleton, thread-safe
@MainActor final class AgentReplyBubbleController: ObservableObject {
    static let shared
    @Published var isVisible: Bool
    @Published var bubbleModel: AgentReplyBubbleModel
    func show(initialText: String)
    func hide()
    func updateText(_ text: String)
    func addToolCall(_ toolName: String, args: [String: String])
}
```

### WindowManager
```swift
// Singleton, bridges AppState ↔️ SwiftUI
@MainActor final class WindowManager: ObservableObject {
    static let shared
    func openQuickActionPanel()
    func openAgentReplyBubble()
    func closeQuickActionPanel()
    func closeAgentReplyBubble()
}
```

## Usage Examples

### From AppState (Hotkey Handler)
```swift
func toggleQuickActionPanel() {
    QuickActionPanelController.shared.toggle { [weak self] actionType in
        self?.sendQuickAction(type: actionType)
    }
}
```

### From Any View
```swift
Button("Show Quick Actions") {
    QuickActionPanelController.shared.show { actionType in
        print("User selected: \(actionType)")
    }
}
```

### Updating Agent Reply Text (Streaming)
```swift
// From your AI streaming handler
for try await chunk in stream {
    if let content = chunk.content {
        AgentReplyBubbleController.shared.updateText(accumulated)
    }
}
```

### Adding Tool Call Info
```swift
AgentReplyBubbleController.shared.addToolCall(
    "web_search",
    args: ["query": "SwiftUI windows"]
)
```

## Window IDs

```swift
"quick-action-panel"    // QuickActionPanelWindowView
"agent-reply-bubble"    // AgentReplyBubbleWindowView
```

## Notification Names

```swift
.showQuickActionPanel   // Posted to create/show quick actions
.showAgentReplyBubble   // Posted to create/show reply bubble
```

## Window Properties

### Quick Action Panel
- Size: 320 × 280 pt
- Position: Center of main screen
- Level: `.floating`
- Style: Borderless, non-activating
- Background: Ultra thick material (glass)
- Animation: Scale + opacity

### Agent Reply Bubble
- Size: 360 × 250-600 pt (dynamic)
- Position: Upper right corner (-16, -16 offset)
- Level: `.floating`
- Style: Borderless, non-activating
- Background: Ultra thick material (glass)
- Animation: Move from top + opacity

## Common Tasks

### Show Quick Actions
```swift
QuickActionPanelController.shared.show { actionType in
    // Handle action
}
```

### Hide Quick Actions
```swift
QuickActionPanelController.shared.hide()
```

### Show Agent Reply
```swift
AgentReplyBubbleController.shared.show(initialText: "Processing...")
```

### Update Reply Text (Streaming)
```swift
AgentReplyBubbleController.shared.updateText("New text...")
```

### Set Conversation Context
```swift
AgentReplyBubbleController.shared.setConversationId(conversationId)
```

### Clear for New Response
```swift
AgentReplyBubbleController.shared.prepareForNewResponse()
```

## Debug Commands

### Check if Window Exists
```swift
if let window = NSApp.windows.first(where: { 
    $0.identifier?.rawValue == "quick-action-panel" 
}) {
    print("Window exists at: \(window.frame)")
}
```

### Print All Windows
```swift
for window in NSApp.windows {
    print("Window: \(window.identifier?.rawValue ?? "nil")")
    print("  Level: \(window.level)")
    print("  Frame: \(window.frame)")
}
```

### Check Controller State
```swift
print("Quick Actions visible: \(QuickActionPanelController.shared.isVisible)")
print("Agent Reply visible: \(AgentReplyBubbleController.shared.isVisible)")
```

## Troubleshooting

### Window doesn't appear
1. Check `isVisible` is true
2. Verify notification is posted
3. Check `NSApp.windows` for the window
4. Look for errors in Console.app

### Window appears but in wrong position
1. Add debug print in `configureWindow()`
2. Check `NSScreen.main?.visibleFrame`
3. Verify frame calculation logic

### Text field doesn't accept input
1. Ensure window became key: `window.makeKeyAndOrderFront(nil)`
2. Check window's `canBecomeKey` (should be true)
3. Verify window style mask

### Window doesn't close
1. Check `WindowManager.closeQuickActionPanel()` is called
2. Verify window.close() executes
3. Check for retain cycles keeping window alive

## Performance Tips

1. **Don't recreate windows** - Reuse existing windows
2. **Lazy content** - Only render when `isVisible == true`
3. **Debounce updates** - For text streaming, batch updates
4. **Profile with Instruments** - Check for leaks/CPU spikes
5. **Test on older Macs** - Verify performance on Intel Macs

## App Store Notes

✅ **Safe to use:**
- SwiftUI Window API
- NSApp.windows (read-only)
- NSScreen for positioning
- NSWindow property setters
- NotificationCenter

⚠️ **Avoid:**
- NSPanel subclassing (removed ✅)
- Private APIs
- Method swizzling
- Runtime manipulation

## Minimum Requirements

- macOS 13.0 (Ventura)
- Xcode 14.0
- Swift 5.7

## Migration Status

| Component | Status | Notes |
|-----------|--------|-------|
| QuickActionPanelController | ✅ Complete | Pure SwiftUI |
| AgentReplyBubbleController | ✅ Complete | Pure SwiftUI |
| WindowManager | ✅ Complete | New file |
| Window Scenes | ✅ Complete | In LumiAgentApp |
| Glass Morphism | ✅ Preserved | Using .ultraThickMaterial |
| Animations | ✅ Enhanced | Native SwiftUI |
| Hotkey Integration | ✅ Works | Via WindowManager |
| Voice Input | ✅ Works | Unchanged |
| Text Streaming | ✅ Works | Via controller updates |

## Quick Commands

```bash
# Clean build
cmd + shift + K

# Build
cmd + B

# Run
cmd + R

# Test hotkey: Option + Command + L
⌥ + ⌘ + L

# View Console
# Open Console.app, filter by "LumiAgent"
```

---

Last Updated: February 25, 2026  
Version: 1.0.0  
Status: ✅ Production Ready
