//
//  LumiAgentApp.swift
//  LumiAgent
//
//  App entry point.
//  - macOS-only AppState logic: AppState+macOS.swift
//  - iOS UI: iOSMainView.swift
//  - Screen capture: Infrastructure/ScreenCapture.swift
//  - ToolCallRecord model: Domain/Models/ToolCallRecord.swift
//  - Shared AppState class: AppState.swift
//

import SwiftUI
import Combine

#if os(macOS)
import AppKit
#endif

@main
struct LumiAgentApp: App {
    @StateObject private var appState = AppState()
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    init() {
        #if os(macOS)
        checkBundleIdentifier()
        #endif
    }

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            MainWindow()
                .environmentObject(appState)
                .frame(minWidth: 1000, minHeight: 600)
        }
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
        #else
        WindowGroup {
            iOSMainView()
                .environmentObject(appState)
        }
        #endif
    }
}

#if os(macOS)
private func checkBundleIdentifier() {
    let bundleID = Bundle.main.bundleIdentifier
    if bundleID == nil || bundleID?.isEmpty == true {
        print("⚠️ WARNING: Bundle identifier is not set!")
        print("⚠️ This will cause crashes when using screen control, keyboard/mouse events.")
        print("⚠️ Please set CFBundleIdentifier in your Info.plist or Xcode project settings.")
        print("⚠️ Recommended: com.lumiagent.app")
    } else {
        print("✅ Bundle identifier: \(bundleID!)")
    }
}
#endif
