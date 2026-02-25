//
//  SystemStatus.swift
//  LumiAgentIOS
//
//  Observable snapshot of the local iOS device's system state.
//

import Foundation
import MediaPlayer

// MARK: - System Status

/// Live snapshot of the iOS device's controllable system state.
@Observable
public final class SystemStatus {
    // MARK: Display
    /// Screen brightness (0.0 – 1.0)
    public var brightness: Double = 0.5

    // MARK: Audio
    /// System output volume (0.0 – 1.0).  Read via AVAudioSession; write via MPVolumeView.
    public var volume: Double = 0.5
    public var isMuted: Bool = false

    // MARK: Media
    public var nowPlayingTitle: String?
    public var nowPlayingArtist: String?
    public var nowPlayingAlbum: String?
    public var nowPlayingArtwork: UIImage?
    public var isPlaying: Bool = false
    public var playbackDuration: TimeInterval = 0
    public var playbackPosition: TimeInterval = 0

    // MARK: Weather
    public var weatherCondition: String?
    public var weatherTemperature: String?
    public var weatherIcon: String = "cloud.sun.fill"
    public var weatherLocation: String?
    public var weatherHumidity: String?
    public var weatherWindSpeed: String?
    public var weatherLastUpdated: Date?
    public var isLoadingWeather: Bool = false
    public var weatherError: String?

    // MARK: Device
    public var batteryLevel: Float = 0
    public var batteryState: UIDevice.BatteryState = .unknown

    public init() {}
}

// MARK: - Weather Response DTOs (Open-Meteo)

/// Lightweight Codable DTOs for the Open-Meteo REST API (no API key needed).
struct OpenMeteoResponse: Codable {
    let current: CurrentWeather
    let currentUnits: CurrentWeatherUnits

    enum CodingKeys: String, CodingKey {
        case current
        case currentUnits = "current_units"
    }
}

struct CurrentWeather: Codable {
    let temperature2m: Double
    let relativeHumidity2m: Int
    let windSpeed10m: Double
    let weatherCode: Int
    let isDay: Int

    enum CodingKeys: String, CodingKey {
        case temperature2m        = "temperature_2m"
        case relativeHumidity2m   = "relative_humidity_2m"
        case windSpeed10m         = "wind_speed_10m"
        case weatherCode          = "weather_code"
        case isDay                = "is_day"
    }
}

struct CurrentWeatherUnits: Codable {
    let temperature2m: String
    let windSpeed10m: String

    enum CodingKeys: String, CodingKey {
        case temperature2m  = "temperature_2m"
        case windSpeed10m   = "wind_speed_10m"
    }
}

// MARK: - WMO Weather Code helpers

/// Maps WMO weather interpretation codes to SF Symbol names and descriptions.
func weatherInfo(for code: Int, isDay: Bool) -> (description: String, sfSymbol: String) {
    switch code {
    case 0:
        return ("Clear Sky", isDay ? "sun.max.fill" : "moon.stars.fill")
    case 1:
        return ("Mainly Clear", isDay ? "sun.max.fill" : "moon.stars.fill")
    case 2:
        return ("Partly Cloudy", isDay ? "cloud.sun.fill" : "cloud.moon.fill")
    case 3:
        return ("Overcast", "cloud.fill")
    case 45, 48:
        return ("Fog", "cloud.fog.fill")
    case 51, 53, 55:
        return ("Drizzle", "cloud.drizzle.fill")
    case 61, 63, 65:
        return ("Rain", "cloud.rain.fill")
    case 66, 67:
        return ("Freezing Rain", "cloud.sleet.fill")
    case 71, 73, 75:
        return ("Snowfall", "cloud.snow.fill")
    case 77:
        return ("Snow Grains", "snowflake")
    case 80, 81, 82:
        return ("Rain Showers", "cloud.heavyrain.fill")
    case 85, 86:
        return ("Snow Showers", "cloud.snow.fill")
    case 95:
        return ("Thunderstorm", "cloud.bolt.fill")
    case 96, 99:
        return ("Thunderstorm + Hail", "cloud.bolt.rain.fill")
    default:
        return ("Unknown", "questionmark.circle")
    }
}
