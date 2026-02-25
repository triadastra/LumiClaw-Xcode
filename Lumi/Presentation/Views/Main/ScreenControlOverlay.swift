//
//  ScreenControlOverlay.swift
//  LumiAgent
//
//  A floating system-level HUD shown whenever the agent is controlling
//  the screen. Uses NSPanel at .floating window level so it appears above
//  all application windows on every Space.
//

#if os(macOS)
import AppKit
import SwiftUI

// MARK: - Overlay Controller

/// Manages the lifecycle of the floating screen-control HUD panel.
final class ScreenControlOverlayController: NSObject {
    static let shared = ScreenControlOverlayController()

    private var panel: NSPanel?

    // MARK: Public API

    func show(onStop: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard self?.panel == nil else { return }
            self?.createPanel(onStop: onStop)
        }
    }

    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.panel?.close()
            self?.panel = nil
        }
    }

    // MARK: Private

    private func createPanel(onStop: @escaping () -> Void) {
        let panelSize = NSSize(width: 320, height: 72)

        let hudView = ScreenControlHUDView(onStop: onStop)
        let hosting = NSHostingView(rootView: hudView)
        hosting.setFrameSize(panelSize)

        let p = NSPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.contentView = hosting
        // .floating keeps the panel above normal windows on all apps
        p.level = .floating
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false           // shadow drawn inside SwiftUI view
        p.isMovableByWindowBackground = true
        p.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        p.isReleasedWhenClosed = false

        // Bottom-center of the main display, 24 pt above the Dock / screen edge
        if let screen = NSScreen.main {
            let sf = screen.visibleFrame   // excludes Dock and menu bar
            let origin = NSPoint(
                x: sf.midX - panelSize.width / 2,
                y: sf.minY + 24
            )
            p.setFrameOrigin(origin)
        }

        p.orderFrontRegardless()
        panel = p
    }
}

// MARK: - HUD View

struct ScreenControlHUDView: View {
    let onStop: () -> Void
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 12) {
            // Pulsing red recording dot
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.35))
                    .frame(width: 22, height: 22)
                    .scaleEffect(pulse ? 1.9 : 1.0)
                    .opacity(pulse ? 0.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.9).repeatForever(autoreverses: false),
                        value: pulse
                    )
                Circle()
                    .fill(Color.red)
                    .frame(width: 9, height: 9)
            }

            Text("Agent controlling your screen")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()

            Button("Stop") { onStop() }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.97))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.32), radius: 22, x: 0, y: 8)
        )
        .onAppear { pulse = true }
    }
}
#endif
