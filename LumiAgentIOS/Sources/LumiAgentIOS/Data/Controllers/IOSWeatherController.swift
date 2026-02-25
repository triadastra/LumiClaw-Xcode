//
//  IOSWeatherController.swift
//  LumiAgentIOS
//
//  Fetches current weather conditions using the Open-Meteo REST API
//  (https://open-meteo.com) — free, no API key required.
//  Location is obtained from CoreLocation.
//
//  Required Info.plist keys:
//    NSLocationWhenInUseUsageDescription  "Used to show local weather conditions."
//
//  To swap in WeatherKit (requires Apple Developer entitlement), replace the
//  fetchWeather() implementation with WeatherService.shared.weather(for:) calls.
//

import Foundation
import CoreLocation

// MARK: - Weather Controller

/// Fetches and delivers current weather using Open-Meteo + CoreLocation.
@MainActor
public final class IOSWeatherController: NSObject, ObservableObject {

    public static let shared = IOSWeatherController()

    // MARK: - Published

    @Published public private(set) var condition: String = "Loading…"
    @Published public private(set) var temperature: String = "--"
    @Published public private(set) var sfSymbol: String = "cloud.sun.fill"
    @Published public private(set) var humidity: String = "--"
    @Published public private(set) var windSpeed: String = "--"
    @Published public private(set) var locationName: String = ""
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var lastUpdated: Date?

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var isFetchInProgress = false

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public API

    /// Request location permission and start a weather fetch.
    public func refresh() {
        errorMessage = nil
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if let loc = lastLocation {
                Task { await fetchWeather(for: loc) }
            } else {
                locationManager.requestLocation()
            }
        case .denied, .restricted:
            errorMessage = "Location access denied. Enable in Settings → Privacy → Location."
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Fetch

    private func fetchWeather(for location: CLLocation) async {
        guard !isFetchInProgress else { return }
        isFetchInProgress = true
        isLoading = true
        defer { isLoading = false; isFetchInProgress = false }

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // Reverse-geocode to get a readable location name.
        let geocoder = CLGeocoder()
        if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
           let place = placemarks.first {
            locationName = [place.locality, place.administrativeArea]
                .compactMap { $0 }
                .joined(separator: ", ")
        }

        // Build Open-Meteo URL.
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude",  value: String(format: "%.4f", lat)),
            URLQueryItem(name: "longitude", value: String(format: "%.4f", lon)),
            URLQueryItem(name: "current",   value: "temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,is_day"),
            URLQueryItem(name: "temperature_unit", value: "celsius"),
            URLQueryItem(name: "wind_speed_unit",  value: "kmh"),
            URLQueryItem(name: "timezone",         value: "auto")
        ]

        guard let url = components.url else {
            errorMessage = "Failed to build weather URL."
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Weather service returned an error."
                return
            }
            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            applyResponse(decoded)
        } catch {
            errorMessage = "Weather fetch failed: \(error.localizedDescription)"
        }
    }

    private func applyResponse(_ response: OpenMeteoResponse) {
        let current = response.current
        let isDay = current.isDay == 1
        let info = weatherInfo(for: current.weatherCode, isDay: isDay)

        condition    = info.description
        sfSymbol     = info.sfSymbol
        temperature  = String(format: "%.0f°C", current.temperature2m)
        humidity     = "\(current.relativeHumidity2m)%"
        windSpeed    = String(format: "%.0f km/h", current.windSpeed10m)
        lastUpdated  = Date()
        errorMessage = nil
    }
}

// MARK: - CLLocationManagerDelegate

extension IOSWeatherController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        lastLocation = loc
        Task { await fetchWeather(for: loc) }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            errorMessage = "Location access denied."
        default:
            break
        }
    }
}
