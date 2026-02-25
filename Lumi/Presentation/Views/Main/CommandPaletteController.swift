//
//  CommandPaletteController.swift
//  LumiAgent
//
//  A global Spotlight-style command palette triggered by ⌘L or ^L.
//  Appears at the center of the screen, above all windows,
//  with Agent Mode active by default.
//

#if os(macOS)
import AppKit
import SwiftUI

// MARK: - Panel subclass

/// Borderless panel that can become key so the text field receives keyboard input.
private final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - Controller

@MainActor
final class CommandPaletteController: NSObject {
    static let shared = CommandPaletteController()

    private var panel: KeyablePanel?
    private var localMonitor: Any?
    var isShowing: Bool { panel != nil }

    // MARK: Show / Hide / Toggle

    func show(agents: [Agent], appState: AppState, onSubmit: @escaping (_ text: String, _ agentId: UUID?) -> Void) {
        guard !isShowing else { return }

        let view = CommandPaletteView(
            agents: agents,
            onSubmit: { [weak self] text, agentId in
                self?.hide()
                onSubmit(text, agentId)
            },
            onDismiss: { [weak self] in self?.hide() }
        )
        .environmentObject(appState)

        // Measure the view then size the panel to fit (shadow padding included)
        let shadowPad: CGFloat = 18
        let contentWidth: CGFloat = 660
        let hosting = NSHostingView(rootView: view.frame(width: contentWidth))
        hosting.setFrameSize(NSSize(width: contentWidth + shadowPad * 2, height: 4000))
        let contentHeight = hosting.fittingSize.height
        let panelSize = NSSize(
            width: contentWidth + shadowPad * 2,
            height: contentHeight + shadowPad * 2
        )
        hosting.setFrameSize(panelSize)

        let p = KeyablePanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        p.contentView = hosting
        p.level = .statusBar // Very high level, above normal windows
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false          // shadow drawn by SwiftUI
        p.isMovableByWindowBackground = true
        // fullScreenAuxiliary allows it to appear over full-screen apps
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        p.isReleasedWhenClosed = false

        // Position: center of main screen
        if let screen = NSScreen.main {
            let sf = screen.visibleFrame
            let origin = NSPoint(
                x: sf.midX - panelSize.width / 2,
                y: sf.midY - panelSize.height / 2 + 100 // Slightly above true center
            )
            p.setFrameOrigin(origin)
        }

        p.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        panel = p

        // Local monitor: ⌘L or ^L dismisses while palette is visible
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // Command+L (keyCode 37)
            if flags == .command, event.keyCode == 37 {
                self?.hide()
                return nil
            }
            // Control+L (keyCode 37)
            if flags == .control, event.keyCode == 37 {
                self?.hide()
                return nil
            }
            return event
        }
    }

    func hide() {
        if let m = localMonitor { NSEvent.removeMonitor(m); localMonitor = nil }
        panel?.close()
        panel = nil
    }

    func toggle(agents: [Agent], appState: AppState, onSubmit: @escaping (_ text: String, _ agentId: UUID?) -> Void) {
        if isShowing { hide() } else { show(agents: agents, appState: appState, onSubmit: onSubmit) }
    }
}

// MARK: - Palette View

struct CommandPaletteView: View {
    @EnvironmentObject var appState: AppState
    let agents: [Agent]
    let onSubmit: (_ text: String, _ agentId: UUID?) -> Void
    let onDismiss: () -> Void

    @State private var text = ""
    @State private var selectedAgentId: UUID?
    @State private var pulse = false
    @FocusState private var fieldFocused: Bool

    // The agent to receive the command.
    // Priority: explicit @mention in text > chip selection > default agent > first agent.
    private var resolvedAgentId: UUID? {
        if let mentioned = agents.first(where: { text.contains("@\($0.name)") }) {
            return mentioned.id
        }
        return selectedAgentId ?? appState.defaultExteriorAgentId ?? agents.first?.id
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !agents.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Top bar ──────────────────────────────────────────────
            HStack(spacing: 8) {
                // Pulsing red recording dot
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.35))
                        .frame(width: 18, height: 18)
                        .scaleEffect(pulse ? 1.9 : 1.0)
                        .opacity(pulse ? 0.0 : 0.5)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: false), value: pulse)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
                Text("Agent Mode")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.red)
                if let agent = agents.first(where: { $0.id == resolvedAgentId }) {
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(agent.configuration.model)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("⌥⌘L  ·  esc")
                    .font(.system(size: 11))
                    .foregroundStyle(.quaternary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
                .opacity(0.5)

            // ── Input field ──────────────────────────────────────────
            HStack(alignment: .center, spacing: 10) {
                // Leading avatar of resolved agent
                if let agent = agents.first(where: { $0.id == resolvedAgentId }) {
                    Circle()
                        .fill(agent.avatarColor)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Text(agent.name.prefix(1))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                } else {
                    Circle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 22, height: 22)
                }

                TextField("@AgentName  do something…", text: $text)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
                    .focused($fieldFocused)
                    .onSubmit { submit() }
                    .onKeyPress(.escape) { onDismiss(); return .handled }

                if canSend {
                    Button(action: submit) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()
                .opacity(0.5)

            // ── Agent chips ──────────────────────────────────────────
            if agents.isEmpty {
                Text("No agents yet — create one in the Lumi window")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(agents) { agent in
                            PaletteAgentChip(
                                agent: agent,
                                isSelected: agent.id == resolvedAgentId
                            ) {
                                selectedAgentId = agent.id
                                // Auto-insert @mention if field is empty
                                if text.trimmingCharacters(in: .whitespaces).isEmpty {
                                    text = "@\(agent.name) "
                                }
                                fieldFocused = true
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.vertical, 9)
            }
        }
        .background(paletteBackground)
        .onAppear {
            pulse = true
            fieldFocused = true
            if selectedAgentId == nil { selectedAgentId = agents.first?.id }
        }
    }

    // MARK: Helpers

    private func submit() {
        guard canSend else { return }
        onSubmit(text.trimmingCharacters(in: .whitespacesAndNewlines), resolvedAgentId)
    }

    private var paletteBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(NSColor.windowBackgroundColor).opacity(0.97))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.red.opacity(0.2), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.38), radius: 36, x: 0, y: 12)
    }
}

// MARK: - Agent Chip

private struct PaletteAgentChip: View {
    let agent: Agent
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(agent.avatarColor)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Text(agent.name.prefix(1))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    )
                Text("@\(agent.name)")
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.red : Color.primary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(isSelected ? Color.red.opacity(0.1) : Color.secondary.opacity(0.08))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.red.opacity(0.35) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
#endif
