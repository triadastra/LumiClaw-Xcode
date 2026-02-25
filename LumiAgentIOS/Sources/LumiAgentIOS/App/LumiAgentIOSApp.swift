//
//  LumiAgentIOSApp.swift
//  LumiAgentIOS
//
//  iOS 17+ entry point.
//
//  HOW TO BUILD
//  ─────────────
//  1. Open LumiAgentIOS/Package.swift in Xcode 15 or later.
//  2. Select an iPhone simulator or device as the run destination.
//  3. Press ⌘R.  Xcode generates a .app bundle from this @main struct.
//
//  INFO.PLIST KEYS TO ADD (Xcode target → Info tab)
//  ──────────────────────────────────────────────────
//  NSLocalNetworkUsageDescription
//      → "LumiAgent needs local network access to discover your Mac."
//  NSBonjourServices  (Array)
//      → Item 0: _lumiagent._tcp
//  NSLocationWhenInUseUsageDescription
//      → "LumiAgent uses your location to show local weather."
//
//  SIGNING
//  ────────
//  Set a Team in Signing & Capabilities; automatic signing is sufficient for simulator.
//  A paid Apple Developer account is needed to run on a physical device.
//

import SwiftUI
import UIKit
import AVFoundation

@main
struct LumiAgentIOSApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - App Delegate

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Keep screen on while the app is active — important for remote control sessions.
        UIApplication.shared.isIdleTimerDisabled = true

        // Initialise audio session early so MPMusicPlayerController observers register correctly.
        configureAudioSession()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Re-enable idle timer when backgrounded.
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[LumiAgentIOS] AVAudioSession setup failed: \(error)")
        }
    }
}
