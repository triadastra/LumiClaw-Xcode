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
                VStack(spacing: 24) {
                    DeviceStatusCard(vm: vm)
                    BrightnessCard(vm: vm)
                    VolumeCard()
                    MediaPlayerCard(vm: vm)
                    WeatherCard(vm: vm)
                    MessagesCard(vm: vm)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
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
                            .font(.system(size: 14, weight: .bold))
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
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
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(batteryColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: vm.batteryIcon)
                        .font(.title3)
                        .foregroundStyle(batteryColor.gradient)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Battery")
                        .font(.headline)
                    Text(vm.batteryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                // Brightness quick indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "sun.max.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow.gradient)
                    Text(String(format: "%.0f%%", vm.brightness * 100))
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    private var batteryColor: Color {
        guard vm.batteryLevel >= 0 else { return .secondary }
        switch vm.batteryState {
        case .charging, .full: return .green
        default:
            return vm.batteryLevel < 0.2 ? .red : (vm.batteryLevel < 0.4 ? .orange : .blue)
        }
    }
}

// MARK: - Brightness Card

private struct BrightnessCard: View {
    @Bindable var vm: SystemControlViewModel

    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Brightness", systemImage: "sun.max.fill")
                    .font(.headline)
                    .foregroundStyle(.yellow.gradient)

                HStack(spacing: 16) {
                    Image(systemName: "sun.min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Slider(value: $vm.brightness, in: 0...1, step: 0.01)
                        .tint(.yellow)
                    Image(systemName: "sun.max")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Spacer()
                    Text(String(format: "%.0f%%", vm.brightness * 100))
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.1))
                        .clipShape(Capsule())
                        .foregroundStyle(.yellow)
                }
            }
        }
    }
}

// MARK: - Volume Card

/// Uses the native MPVolumeView for volume control (the only App-Store-safe method).
private struct VolumeCard: View {
    var body: some View {
        LumiCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Volume", systemImage: "speaker.wave.2.fill")
                    .font(.headline)
                    .foregroundStyle(.blue.gradient)

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
            VStack(spacing: 20) {
                // Header
                Label("Now Playing", systemImage: "music.note")
                    .font(.headline)
                    .foregroundStyle(.purple.gradient)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Artwork + track info
                HStack(spacing: 18) {
                    ZStack {
                        if let artwork = vm.nowPlayingArtwork {
                            Image(uiImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color(.systemFill)
                            Image(systemName: "music.note.list")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

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
                    VStack(spacing: 6) {
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
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                    }
                }

                // Transport controls
                HStack(spacing: 44) {
                    Button { vm.previousTrack() } label: {
                        Image(systemName: "backward.fill").font(.title2)
                    }
                    Button { vm.togglePlayPause() } label: {
                        Image(systemName: vm.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 52))
                            .symbolRenderingMode(.hierarchical)
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
            VStack(alignment: .leading, spacing: 16) {
                // Header with location
                HStack {
                    Label("Weather", systemImage: vm.weatherSFSymbol)
                        .font(.headline)
                        .foregroundStyle(.cyan.gradient)
                    Spacer()
                    if vm.isLoadingWeather {
                        ProgressView().scaleEffect(0.8)
                    } else {
                        Button {
                            vm.refreshWeather()
                        } label: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary.opacity(0.5))
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
                        VStack(alignment: .leading, spacing: 6) {
                            Text(vm.weatherTemperature)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                            Text(vm.weatherCondition)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            if !vm.weatherLocation.isEmpty {
                                Label(vm.weatherLocation, systemImage: "mappin.circle.fill")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                        Image(systemName: vm.weatherSFSymbol)
                            .font(.system(size: 64))
                            .symbolRenderingMode(.multicolor)
                            .shadow(color: .cyan.opacity(0.2), radius: 10, x: 0, y: 5)
                    }

                    // Humidity + wind
                    HStack(spacing: 32) {
                        WeatherStat(icon: "humidity.fill", label: "Humidity", value: vm.weatherHumidity, color: .blue)
                        WeatherStat(icon: "wind", label: "Wind", value: vm.weatherWindSpeed, color: .teal)
                    }
                    .padding(.top, 4)

                    if let updated = vm.weatherLastUpdated {
                        Text("Updated \(updated.formatted(.relative(presentation: .named)))")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 4)
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
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(label).font(.caption2).foregroundStyle(.secondary)
                Text(value).font(.subheadline).fontWeight(.bold)
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
            VStack(alignment: .leading, spacing: 16) {
                Label("Messages & SMS", systemImage: "message.fill")
                    .font(.headline)
                    .foregroundStyle(.green.gradient)

                VStack(spacing: 12) {
                    TextField("Recipient (phone or email)", text: $recipient)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .keyboardType(.phonePad)

                    TextField("Message", text: $messageBody, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .lineLimit(3, reservesSpace: true)
                }

                HStack {
                    Text("Compose opens system sheet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        let targets = recipient
                            .components(separatedBy: CharacterSet(charactersIn: ",;"))
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        vm.composeMessage(to: targets, body: messageBody)
                    } label: {
                        HStack {
                            Text("Send")
                            Image(systemName: "paperplane.fill")
                        }
                        .font(.subheadline.bold())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(recipient.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.2) : Color.green)
                        .foregroundColor(recipient.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .white)
                        .clipShape(Capsule())
                    }
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
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
