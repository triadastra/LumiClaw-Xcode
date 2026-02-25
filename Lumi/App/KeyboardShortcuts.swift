//
//  KeyboardShortcuts.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Keyboard shortcuts and commands
//

#if os(macOS)
import SwiftUI

// MARK: - App Commands

struct LumiAgentCommands: Commands {
    @Binding var selectedSidebarItem: SidebarItem
    var appState: AppState

    var body: some Commands {
        // Agent Palette (in-app ⌘L, complements the global monitor)
        CommandGroup(after: .appInfo) {
            Button("Open Agent Palette") {
                appState.toggleCommandPalette()
            }
            .keyboardShortcut("l", modifiers: .command)

            Button("Quick Actions") {
                appState.toggleQuickActionPanel()
            }
            .keyboardShortcut("l", modifiers: [.option, .command])
        }

        // View Menu
        CommandMenu("View") {
            Button("Agents") {
                selectedSidebarItem = .agents
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("History") {
                selectedSidebarItem = .history
            }
            .keyboardShortcut("2", modifiers: .command)

            Button("Automations") {
                selectedSidebarItem = .automation
            }
            .keyboardShortcut("3", modifiers: .command)

            Divider()

            Button("Refresh") {
                // Trigger refresh
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
        }

        // Agent Menu
        CommandMenu("Agent") {
            Button("Create New Agent") {
                // Trigger new agent
            }
            .keyboardShortcut("n", modifiers: .command)

            Button("Duplicate Agent") {
                // Duplicate selected agent
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(true)

            Button("Delete Agent") {
                // Delete selected agent
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .disabled(true)

            Divider()

            Button("Execute") {
                // Execute agent
            }
            .keyboardShortcut("r", modifiers: .command)
            .disabled(true)

            Button("Stop") {
                // Stop execution
            }
            .keyboardShortcut(".", modifiers: .command)
            .disabled(true)
        }

        // Help Menu
        CommandGroup(replacing: .help) {
            Button("Lumi Agent Help") {
                if let url = URL(string: "https://github.com/yourusername/lumi-agent") {
                    NSWorkspace.shared.open(url)
                }
            }

            Button("Report Issue") {
                if let url = URL(string: "https://github.com/yourusername/lumi-agent/issues") {
                    NSWorkspace.shared.open(url)
                }
            }

            Divider()

            Button("View Logs") {
                openLogsDirectory()
            }
        }
    }

    private func openLogsDirectory() {
        let fileManager = FileManager.default
        if let appSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ) {
            let logsURL = appSupport.appendingPathComponent("LumiAgent")
            NSWorkspace.shared.open(logsURL)
        }
    }
}
#endif
