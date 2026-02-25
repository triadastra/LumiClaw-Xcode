//
//  WindowManager.swift
//  LumiAgent
//
//  Manages SwiftUI window opening/closing for floating panels
//

import SwiftUI
import Combine
#if os(macOS)
import AppKit
#endif

/// Singleton that bridges AppState hotkey triggers with SwiftUI window management
@MainActor
final class WindowManager: ObservableObject {
    nonisolated let objectWillChange = ObservableObjectPublisher()
    static let shared = WindowManager()

    private init() {}

#if os(macOS)
    // MARK: - Window Opening

    /// Opens the Quick Action panel window programmatically
    func openQuickActionPanel() {
        if let window = findWindow(withIdentifier: "quick-action-panel") {
            window.makeKeyAndOrderFront(nil)
        } else {
            NotificationCenter.default.post(name: .showQuickActionPanel, object: nil)
        }
    }

    /// Opens the Agent Reply bubble window programmatically
    func openAgentReplyBubble() {
        if let window = findWindow(withIdentifier: "agent-reply-bubble") {
            window.makeKeyAndOrderFront(nil)
        } else {
            NotificationCenter.default.post(name: .showAgentReplyBubble, object: nil)
        }
    }

    /// Closes the Quick Action panel window
    func closeQuickActionPanel() {
        if let window = findWindow(withIdentifier: "quick-action-panel") {
            window.close()
        }
    }

    /// Closes the Agent Reply bubble window
    func closeAgentReplyBubble() {
        if let window = findWindow(withIdentifier: "agent-reply-bubble") {
            window.close()
        }
    }

    // MARK: - Window Finding

    private func findWindow(withIdentifier identifier: String) -> NSWindow? {
        NSApp.windows.first { window in
            window.identifier?.rawValue == identifier
        }
    }
#else
    func openQuickActionPanel() {}
    func openAgentReplyBubble() {}
    func closeQuickActionPanel() {}
    func closeAgentReplyBubble() {}
#endif
}

// MARK: - Notification Names

extension Notification.Name {
    static let showQuickActionPanel = Notification.Name("showQuickActionPanel")
    static let showAgentReplyBubble = Notification.Name("showAgentReplyBubble")
}
