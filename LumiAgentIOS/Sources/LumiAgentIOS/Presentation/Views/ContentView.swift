//
//  ContentView.swift
//  LumiAgentIOS
//
//  Root tab bar for the iOS app.
//  Three tabs:
//    1. Device Control  — local brightness, volume, media, weather, messages
//    2. Mac Remote      — discover and control nearby macOS LumiAgent hosts
//    3. About           — build info and setup tips
//

import SwiftUI

// MARK: - Content View

public struct ContentView: View {

    public init() {}

    public var body: some View {
        TabView {
            SystemControlView()
                .tabItem {
                    Label("Device", systemImage: "iphone.gen3")
                }

            MacRemoteView()
                .tabItem {
                    Label("Mac Remote", systemImage: "desktopcomputer")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
        }
    }
}

// MARK: - About View

private struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient)
                            .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 4) {
                            Text("LumiAgent")
                                .font(.title.bold())
                            Text("Advanced AI Control")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .listRowBackground(Color.clear)

                Section {
                    InfoRow(label: "Version", value: "1.0", icon: "number.circle.fill")
                    InfoRow(label: "iOS Minimum", value: "iOS 17", icon: "iphone.circle.fill")
                    InfoRow(label: "Last Build", value: buildDate, icon: "calendar.circle.fill")
                } header: {
                    Text("App Info")
                }

                Section("Capabilities") {
                    FeatureRow(icon: "sun.max.fill", color: .yellow,
                               title: "Brightness",
                               detail: "Precision control via UIScreen API")
                    FeatureRow(icon: "speaker.wave.2.fill", color: .blue,
                               title: "Volume",
                               detail: "System-safe hardware integration")
                    FeatureRow(icon: "music.note", color: .purple,
                               title: "Music",
                               detail: "Real-time playback & artwork sync")
                    FeatureRow(icon: "cloud.sun.fill", color: .cyan,
                               title: "Weather",
                               detail: "Live updates from Open-Meteo")
                    FeatureRow(icon: "message.fill", color: .green,
                               title: "Messages",
                               detail: "Quick-compose system integration")
                }

                Section("Remote Connection") {
                    FeatureRow(icon: "wifi.circle.fill", color: .indigo,
                               title: "Bonjour Discovery",
                               detail: "Automatic peer-to-peer Mac detection")
                    FeatureRow(icon: "desktopcomputer", color: .orange,
                               title: "Command Center",
                               detail: "Full remote control of your Mac")
                    FeatureRow(icon: "applescript", color: .teal,
                               title: "Automation",
                               detail: "Remote script & shell execution")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How to connect", systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.yellow)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            StepRow(num: 1, text: "Run LumiAgent on your Mac")
                            StepRow(num: 2, text: "Ensure both share the same Wi-Fi")
                            StepRow(num: 3, text: "Discovery starts automatically")
                            StepRow(num: 4, text: "Select your Mac from the Remote tab")
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Setup Guide")
                }

                Section {
                    PlistRow(key: "Local Network",
                             note: "Required for Mac discovery", icon: "network")
                    PlistRow(key: "Bonjour Services",
                             note: "Required for protocol handshake", icon: "antenna.radiowaves.left.and.right")
                    PlistRow(key: "Location Services",
                             note: "Required for local weather data", icon: "location.fill")
                } header: {
                    Text("System Permissions")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("About")
        }
    }

    private var buildDate: String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: Date())
    }
}

private struct StepRow: View {
    let num: Int
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Text("\(num)")
                .font(.caption.bold())
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(.blue))
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    let icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.subheadline)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct PlistRow: View {
    let key: String
    let note: String
    let icon: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(key)
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
