//
//  MacRemoteView.swift
//  LumiAgentIOS
//
//  Remote control panel for a connected macOS LumiAgent instance.
//  Covers: brightness, volume, media, screenshot, keyboard, apps, AppleScript.
//

import SwiftUI

// MARK: - Mac Remote View (Root)

public struct MacRemoteView: View {

    @State private var vm = MacRemoteViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if vm.connectedDevice == nil {
                    DeviceListView(vm: vm)
                } else {
                    RemoteControlPanel(vm: vm)
                }
            }
            .navigationTitle("Mac Remote")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if vm.connectedDevice != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Disconnect", role: .destructive) {
                            vm.disconnect()
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
        }
        .onAppear { vm.startBrowsing() }
        .onDisappear { vm.stopBrowsing() }
    }
}

// MARK: - Device List

private struct DeviceListView: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        VStack(spacing: 0) {
            if vm.discoveredDevices.isEmpty {
                EmptyDiscoveryView(isBrowsing: vm.isBrowsing, error: vm.browsingError)
            } else {
                List(vm.discoveredDevices) { device in
                    DeviceRow(device: device, isConnecting: vm.isConnecting) {
                        vm.connect(to: device)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let error = vm.connectionError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
            }
        }
    }
}

private struct EmptyDiscoveryView: View {
    let isBrowsing: Bool
    let error: String?

    var body: some View {
        VStack(spacing: 20) {
            if let error {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 56))
                    .foregroundStyle(.red)
                Text("Discovery Error")
                    .font(.headline)
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if isBrowsing {
                ProgressView()
                    .scaleEffect(1.4)
                Text("Scanning for Mac devices…")
                    .font(.headline)
                Text("Make sure LumiAgent is running on your Mac\nand both devices are on the same network.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "desktopcomputer.and.arrow.down")
                    .font(.system(size: 56))
                    .foregroundStyle(.secondary)
                Text("No Macs Found")
                    .font(.headline)
                Text("Start LumiAgent on your Mac and ensure\nboth devices share the same Wi-Fi.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DeviceRow: View {
    let device: MacDevice
    let isConnecting: Bool
    let onConnect: () -> Void

    var body: some View {
        Button(action: onConnect) {
            HStack(spacing: 14) {
                Image(systemName: "desktopcomputer")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(device.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(device.connectionState.displayText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isConnecting {
                    ProgressView().scaleEffect(0.9)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(isConnecting)
    }
}

// MARK: - Remote Control Panel

private struct RemoteControlPanel: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Connection banner
                ConnectedBanner(deviceName: vm.connectedDevice?.name ?? "Mac",
                                result: vm.lastCommandResult,
                                isBusy: vm.isBusy)

                RemoteBrightnessCard(vm: vm)
                RemoteVolumeCard(vm: vm)
                RemoteMediaCard(vm: vm)
                RemoteScreenCard(vm: vm)
                RemoteKeyboardCard(vm: vm)
                RemoteAppsCard(vm: vm)
                RemoteScriptCard(vm: vm)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
        // Sheets
        .sheet(isPresented: $vm.isShowingTypeTextSheet) {
            TypeTextSheet(vm: vm)
        }
        .sheet(isPresented: $vm.isShowingAppleScriptSheet) {
            AppleScriptSheet(vm: vm)
        }
        .sheet(isPresented: $vm.isShowingShellSheet) {
            ShellSheet(vm: vm)
        }
        .sheet(isPresented: $vm.isShowingOpenAppSheet) {
            OpenAppSheet(vm: vm)
        }
    }
}

// MARK: - Connected Banner

private struct ConnectedBanner: View {
    let deviceName: String
    let result: String?
    let isBusy: Bool

    var body: some View {
        LumiCard {
            HStack(spacing: 12) {
                Image(systemName: "wifi.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Connected to \(deviceName)")
                        .font(.headline)
                    if let result {
                        Text(result)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                if isBusy {
                    ProgressView().scaleEffect(0.8)
                }
            }
        }
    }
}

// MARK: - Remote Brightness Card

private struct RemoteBrightnessCard: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Mac Brightness", systemImage: "sun.max.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow)

                HStack(spacing: 12) {
                    Image(systemName: "sun.min").foregroundStyle(.secondary)
                    Slider(value: $vm.remoteBrightness, in: 0...1, step: 0.05) { editing in
                        if !editing { vm.setRemoteBrightness(vm.remoteBrightness) }
                    }
                    .tint(.yellow)
                    Image(systemName: "sun.max").foregroundStyle(.secondary)
                }

                Text(String(format: "%.0f%%", vm.remoteBrightness * 100))
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Remote Volume Card

private struct RemoteVolumeCard: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Mac Volume", systemImage: vm.remoteIsMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    Spacer()
                    Button {
                        vm.toggleRemoteMute()
                    } label: {
                        Image(systemName: vm.remoteIsMuted ? "speaker.slash" : "speaker.wave.2")
                    }
                }

                HStack(spacing: 12) {
                    Image(systemName: "speaker").foregroundStyle(.secondary)
                    Slider(value: $vm.remoteVolume, in: 0...1, step: 0.05) { editing in
                        if !editing { vm.setRemoteVolume(vm.remoteVolume) }
                    }
                    .tint(.blue)
                    .disabled(vm.remoteIsMuted)
                    Image(systemName: "speaker.wave.3").foregroundStyle(.secondary)
                }

                Text(vm.remoteIsMuted ? "Muted" : String(format: "%.0f%%", vm.remoteVolume * 100))
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Remote Media Card

private struct RemoteMediaCard: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Mac Media", systemImage: "music.note")
                    .font(.headline)
                    .foregroundStyle(.purple)

                if let title = vm.remoteNowPlayingTitle {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).font(.subheadline).fontWeight(.medium).lineLimit(1)
                        if let artist = vm.remoteNowPlayingArtist {
                            Text(artist).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                        }
                    }
                }

                HStack(spacing: 28) {
                    Button { vm.remotePrevious() } label: {
                        Image(systemName: "backward.fill").font(.title3)
                    }
                    Button { vm.remoteIsPlaying ? vm.remotePause() : vm.remotePlay() } label: {
                        Image(systemName: vm.remoteIsPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 42))
                    }
                    .foregroundStyle(.purple)
                    Button { vm.remoteNext() } label: {
                        Image(systemName: "forward.fill").font(.title3)
                    }
                    Spacer()
                    Button { vm.remoteGetNowPlaying() } label: {
                        Image(systemName: "info.circle").font(.title3)
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Remote Screen Card

private struct RemoteScreenCard: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Mac Screen", systemImage: "camera.viewfinder")
                    .font(.headline)
                    .foregroundStyle(.indigo)

                if let screenshot = vm.lastScreenshot {
                    Image(uiImage: screenshot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.3)))
                }

                Button {
                    vm.takeRemoteScreenshot()
                } label: {
                    Label("Take Screenshot", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(vm.isBusy)
            }
        }
    }
}

// MARK: - Remote Keyboard Card

private struct RemoteKeyboardCard: View {
    @Bindable var vm: MacRemoteViewModel

    private let shortcuts: [(label: String, key: String, mods: String)] = [
        ("⌘Space", "space", "command"),
        ("⌘C", "c", "command"),
        ("⌘V", "v", "command"),
        ("⌘Z", "z", "command"),
        ("⌘W", "w", "command"),
        ("⌘Q", "q", "command"),
        ("⌘Tab", "tab", "command"),
        ("Escape", "escape", ""),
        ("Return", "return", ""),
        ("⌘⇧3", "3", "command,shift"),
        ("⌘⇧4", "4", "command,shift"),
    ]

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Keyboard", systemImage: "keyboard")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Spacer()
                    Button {
                        vm.isShowingTypeTextSheet = true
                    } label: {
                        Label("Type Text", systemImage: "text.cursor")
                            .font(.subheadline)
                    }
                }

                // Quick-key grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 76))], spacing: 8) {
                    ForEach(shortcuts, id: \.label) { shortcut in
                        Button(shortcut.label) {
                            vm.pressKey(shortcut.key, modifiers: shortcut.mods)
                        }
                        .font(.caption.monospaced())
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

// MARK: - Remote Apps Card

private struct RemoteAppsCard: View {
    @Bindable var vm: MacRemoteViewModel

    private let commonApps = ["Safari", "Finder", "Terminal", "Mail", "Music",
                               "System Settings", "Messages", "Calendar", "Notes"]

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Apps", systemImage: "app.badge")
                        .font(.headline)
                        .foregroundStyle(.pink)
                    Spacer()
                    Button {
                        vm.isShowingOpenAppSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96))], spacing: 8) {
                    ForEach(commonApps, id: \.self) { app in
                        Button(app) {
                            vm.openAppName = app
                            vm.sendOpenApp()
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .lineLimit(1)
                    }
                }
            }
        }
    }
}

// MARK: - Remote Script Card

private struct RemoteScriptCard: View {
    @Bindable var vm: MacRemoteViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Automation", systemImage: "applescript")
                    .font(.headline)
                    .foregroundStyle(.teal)

                HStack(spacing: 12) {
                    Button {
                        vm.isShowingAppleScriptSheet = true
                    } label: {
                        Label("AppleScript", systemImage: "applescript")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        vm.isShowingShellSheet = true
                    } label: {
                        Label("Shell", systemImage: "terminal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}

// MARK: - Sheets

private struct TypeTextSheet: View {
    @Bindable var vm: MacRemoteViewModel
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextEditor(text: $vm.typeTextInput)
                    .focused($focused)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Text will be typed into the focused app on your Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Type Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.isShowingTypeTextSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") { vm.sendTypeText() }
                        .disabled(vm.typeTextInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct AppleScriptSheet: View {
    @Bindable var vm: MacRemoteViewModel
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextEditor(text: $vm.appleScriptText)
                    .focused($focused)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Script runs on your Mac. Output appears in the result banner.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("AppleScript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.isShowingAppleScriptSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Run") { vm.runAppleScript() }
                        .disabled(vm.appleScriptText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct ShellSheet: View {
    @Bindable var vm: MacRemoteViewModel
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Command (e.g. ls ~/Desktop)", text: $vm.shellCommandText)
                    .focused($focused)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Text("Runs on your Mac via /bin/bash. Output is returned as the result.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Shell Command")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.isShowingShellSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Run") { vm.runShellCommand() }
                        .disabled(vm.shellCommandText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium])
    }
}

private struct OpenAppSheet: View {
    @Bindable var vm: MacRemoteViewModel
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("App name (e.g. Xcode, TextEdit)", text: $vm.openAppName)
                    .focused($focused)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                Text("Opens the named application on your Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Open Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.isShowingOpenAppSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Open") { vm.sendOpenApp() }
                        .disabled(vm.openAppName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { focused = true }
        }
        .presentationDetents([.medium])
    }
}
