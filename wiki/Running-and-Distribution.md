# Running and Distribution

This guide covers how to build, run, and distribute Lumi on your own macOS and iOS devices using Xcode.

## Running on macOS via Xcode

Lumi is a Swift Package Manager (SPM) project with an associated `.xcodeproj`.

1. **Open the project**: Double-click `Lumi.xcodeproj` in the root directory.
2. **Select the Scheme**: In the top toolbar, select the **LumiAgent** scheme and your **Mac** as the target.
3. **Configure Signing**:
   - Select the **Lumi** project in the sidebar, then the **LumiAgent** target.
   - Go to **Signing & Capabilities**.
   - Select your **Development Team**. If you don't have a paid developer account, you can use your personal Apple ID (Personal Team).
4. **Build and Run**: Press `⌘R` or click the Play button.
   - On first run, Xcode may ask for your Mac password to sign the binary.
   - You will need to grant permissions (Accessibility, Screen Recording, etc.) in System Settings as prompted.

## Running on iPhone via Xcode

The iOS companion app is built from the same codebase using the `LumiAgent` target (multi-platform).

1. **Connect your iPhone**: Connect your device to your Mac via USB or Wi-Fi.
2. **Select the Target**: Select the **LumiAgent** scheme and choose your **iPhone** from the run destination list.
3. **Configure Signing**:
   - Ensure your **Development Team** is selected in **Signing & Capabilities**.
   - Note: Features like HealthKit and Push Notifications may require a paid Developer Program membership. For local development, basic chat and remote control will work with a Personal Team.
4. **Build and Run**: Press `⌘R`.
5. **Trust the Certificate (First time only)**:
   - After the app installs, it won't open until you trust the developer.
   - On your iPhone, go to **Settings > General > VPN & Device Management**.
   - Tap your Apple ID under "Developer App" and tap **Trust**.
6. **Pair with Mac**: Ensure both devices are on the same Wi-Fi network to use Bonjour discovery.

## Local Distribution

### Distributing to other Macs

If you want to install Lumi on another Mac without using Xcode:

1. **Use the Build Script**: Run `./build_unsigned_dmg.sh` in the terminal.
   - This creates a release build, assembles the `.app`, and packages it into a `.dmg`.
   - The app is "ad-hoc" signed by default, which works on other Macs if they allow apps from identified developers (or if you right-click and select "Open" to bypass Gatekeeper).
2. **Copy the .app**: You can also manually copy `LumiAgent.app` from your `runable/` or `/Applications/` folder to another Mac.

### Distributing to your own iOS Devices

Apple restricts iOS app distribution outside the App Store. For your own devices, you have three main options:

1. **Xcode Run (7-day limit)**: Running the app directly from Xcode using a free Personal Team signs it for 7 days. After 7 days, you must re-run it from Xcode.
2. **Xcode Run (1-year limit)**: If you have a paid Apple Developer Program account, the app will remain functional for 1 year after being installed via Xcode.
3. **TestFlight**: If you have a paid Developer Program account, you can upload the build to App Store Connect and distribute it to up to 10,000 internal/external testers (including yourself) via the TestFlight app. This is the most "permanent" way to keep the app on your phone.

## Troubleshooting

- **Signing Errors**: Ensure your Bundle Identifier (`com.lumiagent.app`) is unique if you are using a Personal Team. You may need to change it to something like `com.yourname.lumiagent`.
- **Entitlement Failures**: If the app crashes on launch, check the **Console.app** on Mac or the Xcode debug console for "Task-policy" or "Code Signature" errors. Some entitlements require specific provisioning profiles.
- **Bonjour Discovery**: If the iPhone cannot find the Mac, ensure the Mac's firewall is not blocking port `47285` and that both devices are on the same local network subnet.
