//
//  SystemControlViewModel.swift
//  LumiAgentIOS
//
//  ViewModel bridging IOSBrightnessController, IOSMediaController,
//  IOSWeatherController, and battery info into one Observable model
//  for SystemControlView.
//

import SwiftUI
import AVFoundation
import UIKit
import Combine

// MARK: - System Control ViewModel

@MainActor
@Observable
public final class SystemControlViewModel {

    // MARK: - Brightness

    public var brightness: Double = UIScreen.main.brightness {
        didSet {
            guard abs(brightness - Double(UIScreen.main.brightness)) > 0.01 else { return }
            Task { await IOSBrightnessController.shared.setBrightness(brightness) }
        }
    }

    // MARK: - Media

    public private(set) var isPlaying: Bool = false
    public private(set) var nowPlayingTitle: String?
    public private(set) var nowPlayingArtist: String?
    public private(set) var nowPlayingArtwork: UIImage?
    public private(set) var playbackDuration: TimeInterval = 0
    public private(set) var playbackPosition: TimeInterval = 0
    public private(set) var volume: Double = 0.5

    // MARK: - Weather

    public private(set) var weatherCondition: String = "Tap to load"
    public private(set) var weatherTemperature: String = "--"
    public private(set) var weatherSFSymbol: String = "cloud.sun.fill"
    public private(set) var weatherHumidity: String = "--"
    public private(set) var weatherWindSpeed: String = "--"
    public private(set) var weatherLocation: String = ""
    public private(set) var isLoadingWeather: Bool = false
    public private(set) var weatherError: String?
    public private(set) var weatherLastUpdated: Date?

    // MARK: - Battery

    public private(set) var batteryLevel: Float = 0
    public private(set) var batteryState: UIDevice.BatteryState = .unknown

    // MARK: - Messages

    public var pendingMessageRequest: MessageComposeRequest?

    // MARK: - Private

    private let media = IOSMediaController.shared
    private let weather = IOSWeatherController.shared
    private var cancellables = Set<AnyCancellable>()

    public init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        bindMedia()
        bindWeather()
        refreshBattery()
        setupBatteryNotifications()
    }

    // MARK: - Bindings

    private func bindMedia() {
        media.$isPlaying.receive(on: RunLoop.main).sink { [weak self] val in
            self?.isPlaying = val
        }.store(in: &cancellables)

        media.$nowPlayingTitle.receive(on: RunLoop.main).sink { [weak self] val in
            self?.nowPlayingTitle = val
        }.store(in: &cancellables)

        media.$nowPlayingArtist.receive(on: RunLoop.main).sink { [weak self] val in
            self?.nowPlayingArtist = val
        }.store(in: &cancellables)

        media.$nowPlayingArtwork.receive(on: RunLoop.main).sink { [weak self] val in
            self?.nowPlayingArtwork = val
        }.store(in: &cancellables)

        media.$playbackDuration.receive(on: RunLoop.main).sink { [weak self] val in
            self?.playbackDuration = val
        }.store(in: &cancellables)

        media.$playbackPosition.receive(on: RunLoop.main).sink { [weak self] val in
            self?.playbackPosition = val
        }.store(in: &cancellables)

        media.$volume.receive(on: RunLoop.main).sink { [weak self] val in
            self?.volume = val
        }.store(in: &cancellables)
    }

    private func bindWeather() {
        weather.$condition.receive(on: RunLoop.main).sink { [weak self] in self?.weatherCondition = $0 }.store(in: &cancellables)
        weather.$temperature.receive(on: RunLoop.main).sink { [weak self] in self?.weatherTemperature = $0 }.store(in: &cancellables)
        weather.$sfSymbol.receive(on: RunLoop.main).sink { [weak self] in self?.weatherSFSymbol = $0 }.store(in: &cancellables)
        weather.$humidity.receive(on: RunLoop.main).sink { [weak self] in self?.weatherHumidity = $0 }.store(in: &cancellables)
        weather.$windSpeed.receive(on: RunLoop.main).sink { [weak self] in self?.weatherWindSpeed = $0 }.store(in: &cancellables)
        weather.$locationName.receive(on: RunLoop.main).sink { [weak self] in self?.weatherLocation = $0 }.store(in: &cancellables)
        weather.$isLoading.receive(on: RunLoop.main).sink { [weak self] in self?.isLoadingWeather = $0 }.store(in: &cancellables)
        weather.$errorMessage.receive(on: RunLoop.main).sink { [weak self] in self?.weatherError = $0 }.store(in: &cancellables)
        weather.$lastUpdated.receive(on: RunLoop.main).sink { [weak self] in self?.weatherLastUpdated = $0 }.store(in: &cancellables)
    }

    // MARK: - Battery

    private func refreshBattery() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
    }

    private func setupBatteryNotifications() {
        NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshBattery() }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshBattery() }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    public func refreshBrightness() {
        brightness = Double(UIScreen.main.brightness)
    }

    // Media

    public func togglePlayPause() { media.togglePlayPause() }
    public func nextTrack()       { media.nextTrack() }
    public func previousTrack()   { media.previousTrack() }

    public func setVolume(_ level: Double) {
        media.setVolume(level)
    }

    // Weather

    public func refreshWeather() {
        weather.refresh()
    }

    // Messages

    public func composeMessage(to recipients: [String], body: String = "") {
        pendingMessageRequest = MessageComposeRequest(recipients: recipients, body: body)
    }

    // MARK: - Battery formatting

    public var batteryIcon: String {
        if batteryLevel < 0 { return "battery.0" } // unknown
        let level = Int(batteryLevel * 100)
        switch batteryState {
        case .charging, .full:
            return "battery.100.bolt"
        default:
            switch level {
            case 75...:  return "battery.100"
            case 50...:  return "battery.75"
            case 25...:  return "battery.50"
            case 10...:  return "battery.25"
            default:     return "battery.0"
            }
        }
    }

    public var batteryText: String {
        guard batteryLevel >= 0 else { return "Unknown" }
        let pct = Int(batteryLevel * 100)
        switch batteryState {
        case .charging: return "\(pct)% Charging"
        case .full:     return "Full"
        default:        return "\(pct)%"
        }
    }
}
