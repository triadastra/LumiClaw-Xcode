//
//  SystemControlView.swift
//  LumiAgentIOS
//
//  Full-featured local system control panel:
//    • Screen brightness slider
//    • Volume display + MPVolumeView for hardware control
//    • Media player controls (Apple Music / Now Playing)
//    • Weather card (Open-Meteo, current location)
//    • Messages quick-compose
//    • Battery status
//

import SwiftUI
import MediaPlayer

// MARK: - System Control View

public struct SystemControlView: View {

    @State private var vm = SystemControlViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DeviceStatusCard(vm: vm)
                    BrightnessCard(vm: vm)
                    VolumeCard()
                    MediaPlayerCard(vm: vm)
                    WeatherCard(vm: vm)
                    MessagesCard(vm: vm)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Device Control")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.refreshWeather()
                        vm.refreshBrightness()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .messageComposeSheet($vm.pendingMessageRequest)
        .onAppear {
            vm.refreshBrightness()
            vm.refreshWeather()
        }
    }
}

// MARK: - Device Status Card

private struct DeviceStatusCard: View {
    @Bindable var vm: SystemControlViewModel

    var body: some View {
        LumiCard {
            HStack(spacing: 16) {
                Image(systemName: vm.batteryIcon)
                    .font(.title2)
                    .foregroundStyle(batteryColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Battery")
                        .font(.headline)
                    Text(vm.batteryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // Brightness quick indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.0f%%", vm.brightness * 100))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var batteryColor: Color {
        guard vm.batteryLevel >= 0 else { return .secondary }
        switch vm.batteryState {
        case .charging, .full: return .green
        default:
            return vm.batteryLevel < 0.2 ? .red : (vm.batteryLevel < 0.4 ? .orange : .primary)
        }
    }
}

// MARK: - Brightness Card

private struct BrightnessCard: View {
    @Bindable var vm: SystemControlViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Brightness", systemImage: "sun.max.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow)

                HStack(spacing: 12) {
                    Image(systemName: "sun.min")
                        .foregroundStyle(.secondary)
                    Slider(value: $vm.brightness, in: 0...1, step: 0.01)
                        .tint(.yellow)
                    Image(systemName: "sun.max")
                        .foregroundStyle(.secondary)
                }

                Text(String(format: "%.0f%%", vm.brightness * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Volume Card

/// Uses the native MPVolumeView for volume control (the only App-Store-safe method).
private struct VolumeCard: View {
    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Volume", systemImage: "speaker.wave.2.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)

                NativeVolumeSlider()
                    .frame(height: 32)

                Text("System volume — slide to adjust")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Wraps MPVolumeView in a SwiftUI-compatible view.
struct NativeVolumeSlider: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let v = MPVolumeView()
        v.showsRouteButton = false
        return v
    }
    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}

// MARK: - Media Player Card

private struct MediaPlayerCard: View {
    @Bindable var vm: SystemControlViewModel

    var body: some View {
        LumiCard {
            VStack(spacing: 14) {
                // Header
                Label("Now Playing", systemImage: "music.note")
                    .font(.headline)
                    .foregroundStyle(.purple)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Artwork + track info
                HStack(spacing: 16) {
                    Group {
                        if let artwork = vm.nowPlayingArtwork {
                            Image(uiImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .background(Color(.systemFill).clipShape(RoundedRectangle(cornerRadius: 8)))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.nowPlayingTitle ?? "Nothing Playing")
                            .font(.headline)
                            .lineLimit(1)
                        if let artist = vm.nowPlayingArtist {
                            Text(artist)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }

                // Progress bar
                if vm.playbackDuration > 0 {
                    VStack(spacing: 4) {
                        ProgressView(
                            value: vm.playbackPosition,
                            total: max(vm.playbackDuration, 1)
                        )
                        .tint(.purple)
                        HStack {
                            Text(formatTime(vm.playbackPosition))
                            Spacer()
                            Text(formatTime(vm.playbackDuration))
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }

                // Transport controls
                HStack(spacing: 36) {
                    Button { vm.previousTrack() } label: {
                        Image(systemName: "backward.fill").font(.title2)
                    }
                    Button { vm.togglePlayPause() } label: {
                        Image(systemName: vm.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                    }
                    .foregroundStyle(.purple)
                    Button { vm.nextTrack() } label: {
                        Image(systemName: "forward.fill").font(.title2)
                    }
                }
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Weather Card

private struct WeatherCard: View {
    @Bindable var vm: SystemControlViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header with location
                HStack {
                    Label("Weather", systemImage: vm.weatherSFSymbol)
                        .font(.headline)
                        .foregroundStyle(.cyan)
                    Spacer()
                    if vm.isLoadingWeather {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Button {
                            vm.refreshWeather()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = vm.weatherError {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                } else {
                    // Main weather display
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vm.weatherTemperature)
                                .font(.system(size: 40, weight: .semibold, design: .rounded))
                            Text(vm.weatherCondition)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if !vm.weatherLocation.isEmpty {
                                Label(vm.weatherLocation, systemImage: "mappin.circle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: vm.weatherSFSymbol)
                            .font(.system(size: 52))
                            .symbolRenderingMode(.multicolor)
                    }

                    // Humidity + wind
                    HStack(spacing: 24) {
                        WeatherStat(icon: "humidity.fill", label: "Humidity", value: vm.weatherHumidity, color: .blue)
                        WeatherStat(icon: "wind", label: "Wind", value: vm.weatherWindSpeed, color: .teal)
                    }

                    if let updated = vm.weatherLastUpdated {
                        Text("Updated \(updated.formatted(.relative(presentation: .named)))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}

private struct WeatherStat: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 0) {
                Text(label).font(.caption2).foregroundStyle(.secondary)
                Text(value).font(.caption).fontWeight(.medium)
            }
        }
    }
}

// MARK: - Messages Card

private struct MessagesCard: View {
    @Bindable var vm: SystemControlViewModel
    @State private var recipient = ""
    @State private var messageBody = ""

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Messages & SMS", systemImage: "message.fill")
                    .font(.headline)
                    .foregroundStyle(.green)

                VStack(spacing: 10) {
                    TextField("Recipient (phone or email)", text: $recipient)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)

                    TextField("Message", text: $messageBody, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                }

                HStack {
                    Text("Compose opens system sheet for confirmation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Compose") {
                        let targets = recipient
                            .components(separatedBy: CharacterSet(charactersIn: ",;"))
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        vm.composeMessage(to: targets, body: messageBody)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(recipient.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Lumi Card

/// Reusable card container.
struct LumiCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
