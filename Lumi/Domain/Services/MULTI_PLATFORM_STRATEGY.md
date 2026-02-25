# Multi-Platform Strategy for LumiAgent

## Current Situation

Right now, LumiAgent is macOS-only because:
- Tools use macOS system APIs (Terminal, AppleScript, file system)
- All views are wrapped in `#if os(macOS)`
- UIKit crash happens because app tries to run iOS code with macOS APIs

## iOS vs macOS Feature Matrix

| Feature | macOS | iOS |
|---------|-------|-----|
| AI Chat | ✅ Yes | ✅ Yes |
| Conversations | ✅ Yes | ✅ Yes |
| Agent Management | ✅ Yes | ✅ Yes |
| Tool Execution | ✅ Local | ❌ Server/Disabled |
| File Operations | ✅ Full Access | ⚠️ Sandboxed Only |
| Terminal Commands | ✅ Yes | ❌ No |
| Screen Control | ✅ Yes | ❌ No |
| AppleScript | ✅ Yes | ❌ No |
| System Automation | ✅ Yes | ❌ No |

## Architecture Options

### Option 1: iOS as Client, macOS as Server (Recommended)

**iOS App:**
- Chat interface only
- Sends tool requests to macOS companion app
- Receives results via network

**macOS App:**
- Full functionality
- Runs local HTTP server
- Executes tools on behalf of iOS

**Pros:**
- ✅ True tool functionality on iOS (via Mac)
- ✅ Secure (tools run on user's own Mac)
- ✅ No App Store restrictions

**Cons:**
- ❌ Requires Mac to be running
- ❌ Network setup needed

### Option 2: Cloud Backend

**Both Apps:**
- Connect to cloud API for tool execution

**Pros:**
- ✅ Works without Mac
- ✅ Simpler for users

**Cons:**
- ❌ Security concerns (cloud has user's system access)
- ❌ Expensive to run
- ❌ Not suitable for this type of app

### Option 3: iOS Limited Mode (Easiest)

**iOS App:**
- Full UI but tools are disabled/limited
- Only AI chat works
- Shows "Tool execution requires macOS" messages

**macOS App:**
- Full functionality

**Pros:**
- ✅ Easiest to implement
- ✅ No backend needed
- ✅ Clear platform differences

**Cons:**
- ❌ iOS version is limited
- ❌ Less useful on iOS

## Implementation Plan (Option 3 - Limited iOS)

### 1. Separate Platform-Specific Code

```
LumiAgent/
├── Shared/
│   ├── Models/          (Agent, Conversation, etc.)
│   ├── ViewModels/      (AppState, etc.)
│   ├── Views/
│   │   ├── ChatView.swift
│   │   ├── AgentListView.swift
│   │   └── Shared UI components
│   └── AI/              (AI provider code)
├── macOS/
│   ├── ToolRegistry.swift
│   ├── ScreenControl/
│   └── SystemAccess/
└── iOS/
    ├── ToolStubs.swift  (Disabled tools)
    └── iOS-specific views
```

### 2. Create Tool Abstraction

Instead of direct `ToolRegistry`, create protocol:

```swift
protocol ToolExecutor {
    func execute(tool: String, arguments: [String: String]) async throws -> String
}

#if os(macOS)
class LocalToolExecutor: ToolExecutor {
    func execute(tool: String, arguments: [String: String]) async throws -> String {
        // Use ToolRegistry
    }
}
#else
class DisabledToolExecutor: ToolExecutor {
    func execute(tool: String, arguments: [String: String]) async throws -> String {
        throw ToolError.notAvailableOnPlatform
    }
}
#endif
```

### 3. Conditional View Components

Remove `#if os(macOS)` from view files, add it to specific features:

```swift
struct ChatView: View {
    var body: some View {
        // Common UI
        
        #if os(macOS)
        // Mac-specific tool buttons
        #else
        // iOS note: "Tool execution requires macOS"
        #endif
    }
}
```

## Quick Fix for Current Crash

The immediate issue is that iOS is trying to load macOS-only code. Here's the fix:

### Step 1: Update LumiAgentApp.swift

```swift
@main
struct LumiAgentApp: App {
    @StateObject private var appState = AppState()
    
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            MainWindow()
                .environmentObject(appState)
                .frame(minWidth: 1000, minHeight: 600)
            #else
            iOSMainView()
                .environmentObject(appState)
            #endif
        }
        #if os(macOS)
        .commands {
            LumiAgentCommands(
                selectedSidebarItem: $appState.selectedSidebarItem,
                appState: appState
            )
        }
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
        #endif
    }
}
```

### Step 2: Create iOS Main View

Create a new file: `iOSMainView.swift`

```swift
import SwiftUI

struct iOSMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            NavigationStack {
                AgentListViewiOS()
            }
            .tabItem {
                Label("Agents", systemImage: "cpu")
            }
            
            NavigationStack {
                ConversationsViewiOS()
            }
            .tabItem {
                Label("Chat", systemImage: "message")
            }
            
            NavigationStack {
                SettingsViewiOS()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}
```

### Step 3: Create Tool Stub for iOS

Create: `ToolExecutorProtocol.swift`

```swift
import Foundation

protocol ToolExecutor {
    func execute(toolName: String, arguments: [String: String]) async throws -> String
}

#if os(macOS)
class LocalToolExecutor: ToolExecutor {
    func execute(toolName: String, arguments: [String: String]) async throws -> String {
        guard let tool = ToolRegistry.shared.getTool(named: toolName) else {
            throw ToolError.notFound(toolName)
        }
        return try await tool.handler(arguments)
    }
}
#else
class IOSToolExecutor: ToolExecutor {
    func execute(toolName: String, arguments: [String: String]) async throws -> String {
        // Option 1: Throw error
        throw ToolError.notAvailableOnPlatform(
            "Tool '\(toolName)' requires macOS. Please use LumiAgent on your Mac."
        )
        
        // Option 2: Return placeholder
        // return "⚠️ Tool execution requires macOS"
    }
}
#endif

enum ToolError: LocalizedError {
    case notFound(String)
    case notAvailableOnPlatform(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound(let name):
            return "Tool not found: \(name)"
        case .notAvailableOnPlatform(let message):
            return message
        }
    }
}
```

## Next Steps

1. **Decide on strategy**: Limited iOS vs Client-Server vs Cloud
2. **Restructure project**: Separate shared code from platform-specific
3. **Create iOS views**: Simplified versions without tool UI
4. **Update AppState**: Use ToolExecutor protocol instead of direct ToolRegistry
5. **Test both platforms**: Ensure iOS doesn't crash, macOS still works

## Recommended Immediate Action

For the quickest fix to get it running on iOS:

1. Create the `iOSMainView.swift` file
2. Create the `ToolExecutorProtocol.swift` file  
3. Update `LumiAgentApp.swift` to use conditional views
4. The iOS app will work for chat, but tools will show "Not available on iOS"

Would you like me to help implement one of these strategies?
