# Fixing the Bundle Identifier Crash

## The Problem

You're seeing this crash:
```
__BKSHIDEvent__BUNDLE_IDENTIFIER_FOR_CURRENT_PROCESS_IS_NIL__
```

This happens when macOS APIs (especially screen control, keyboard/mouse events, AppleScript) are used without a proper bundle identifier.

## Solutions

### Solution 1: Xcode Project Settings (Recommended)

1. Open your project in Xcode
2. Select your target (LumiAgent)
3. Go to the "General" tab
4. Find "Bundle Identifier" field
5. Set it to: `com.lumiagent.app`
6. Clean build folder (⌘⇧K)
7. Rebuild (⌘B)

### Solution 2: Info.plist Configuration

If you're building with Swift Package Manager or from command line:

1. Create or edit `Info.plist` in your project root (already created for you!)
2. Make sure your build system includes it
3. The file should contain:
   ```xml
   <key>CFBundleIdentifier</key>
   <string>com.lumiagent.app</string>
   ```

### Solution 3: Xcode Build Settings

Add to your `.xcconfig` file (already done!):
```
PRODUCT_BUNDLE_IDENTIFIER = com.lumiagent.app
```

### Solution 4: SPM Package.swift (if using Swift Package Manager)

If building as a Swift Package, you may need to add to your `Package.swift`:

```swift
.target(
    name: "LumiAgent",
    dependencies: [],
    resources: [
        .process("Info.plist")
    ]
)
```

## Verifying the Fix

Run this code at app startup to verify:
```swift
if let bundleID = Bundle.main.bundleIdentifier {
    print("✅ Bundle ID is set: \(bundleID)")
} else {
    print("❌ Bundle ID is missing!")
}
```

The app already does this check in `LumiAgentApp.init()`.

## Why This Happens

The crash occurs specifically when your app tries to:
- Control mouse/keyboard via CGEvent APIs
- Use AppleScript automation
- Capture screenshots
- Access Accessibility APIs
- Send keyboard/mouse events

All of these require a valid bundle identifier for security and system tracking purposes.

## Additional Steps

### 1. Enable Required Entitlements

Make sure your entitlements file includes:
```xml
<key>com.apple.security.automation.apple-events</key>
<true/>
<key>com.apple.security.device.audio-input</key>
<true/>
```

### 2. Grant System Permissions

Your app needs these permissions:
- **Accessibility**: System Settings → Privacy & Security → Accessibility
- **Screen Recording**: System Settings → Privacy & Security → Screen Recording
- **Automation**: System Settings → Privacy & Security → Automation

### 3. Code Signing

Make sure your app is properly code signed:
```bash
codesign -s - -f --deep /path/to/LumiAgent.app
```

## Testing

After fixing the bundle identifier:

1. Clean build (⌘⇧K)
2. Rebuild
3. Run the app
4. Check console output for: `✅ Bundle identifier: com.lumiagent.app`
5. Try using a screen control feature
6. If it crashes, check System Settings for permissions

## Still Having Issues?

If the crash persists:

1. Check the console output when launching the app
2. Look for the bundle identifier check messages
3. Verify the app binary has the correct Info.plist:
   ```bash
   plutil -p /path/to/LumiAgent.app/Contents/Info.plist | grep CFBundleIdentifier
   ```
4. Check if running from Xcode vs standalone makes a difference
5. Try rebuilding from scratch with a clean derived data folder

## Common Mistakes

❌ Setting bundle identifier in code (doesn't work)
❌ Only setting it in xcconfig without rebuild
❌ Having multiple Info.plist files with different IDs
❌ Not code signing the app properly

✅ Set in Xcode project settings
✅ Set in Info.plist
✅ Clean build after changing
✅ Verify with Bundle.main.bundleIdentifier
