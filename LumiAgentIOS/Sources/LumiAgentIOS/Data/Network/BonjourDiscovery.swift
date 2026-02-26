//
//  BonjourDiscovery.swift
//  LumiAgentIOS
//
//  Discovers devices on the local network via Bonjour.
//  Browses for multiple service types (Mac LumiAgents, ESP32s, etc).
//

import Network
import Foundation
import Combine

// MARK: - Bonjour Discovery

/// Discovers nearby devices on the local network via Bonjour.
@MainActor
public final class BonjourDiscovery: ObservableObject {

    // MARK: - Configuration

    private let serviceTypes: [(type: String, deviceType: LumiDeviceType)] = [
        ("_lumiagent._tcp", .mac),
        ("_http._tcp",      .esp32),    // Common for ESP32 web servers
        ("_arduino._tcp",   .arduino),  // ESP32/Arduino OTA
    ]

    // MARK: - Published

    @Published public private(set) var discoveredDevices: [LumiDevice] = []
    @Published public private(set) var isBrowsing: Bool = false
    @Published public private(set) var browsingError: String?

    // MARK: - Private

    private var browsers: [NWBrowser] = []
    private let queue = DispatchQueue(label: "com.lumiagent.bonjour", qos: .utility)
    
    // Internal dictionary to track results per service type
    private var resultsMap: [String: [NWBrowser.Result]] = [:]

    public init() {}

    // MARK: - Browse

    public func startBrowsing() {
        guard !isBrowsing else { return }
        browsingError = nil
        isBrowsing = true
        browsers.removeAll()
        resultsMap.removeAll()

        for (service, deviceType) in serviceTypes {
            let descriptor = NWBrowser.Descriptor.bonjour(type: service, domain: nil)
            let params = NWParameters()
            params.includePeerToPeer = true

            let b = NWBrowser(for: descriptor, using: params)

            b.browseResultsChangedHandler = { [weak self] results, changes in
                Task { @MainActor [weak self] in
                    self?.resultsMap[service] = Array(results)
                    self?.rebuildDeviceList()
                }
            }

            b.stateUpdateHandler = { [weak self] state in
                Task { @MainActor [weak self] in
                    if case .failed(let error) = state {
                        self?.browsingError = "Error browsing \(service): \(error.localizedDescription)"
                    }
                }
            }

            b.start(queue: queue)
            browsers.append(b)
        }
    }

    public func stopBrowsing() {
        browsers.forEach { $0.cancel() }
        browsers.removeAll()
        isBrowsing = false
    }

    // MARK: - Handle Results

    private func rebuildDeviceList() {
        var updated: [LumiDevice] = []
        
        for (service, deviceType) in serviceTypes {
            guard let results = resultsMap[service] else { continue }
            
            for result in results {
                guard case .service(let name, _, _, _) = result.endpoint else { continue }
                
                // Avoid duplicates across different service types for the same name
                if updated.contains(where: { $0.serviceName == name }) { continue }
                
                // Preserve existing connection state if device was already known.
                let existingState = discoveredDevices.first(where: { $0.serviceName == name })?.connectionState ?? .discovered
                
                let device = LumiDevice(
                    name: friendlyName(from: name),
                    serviceName: name,
                    endpoint: result.endpoint,
                    type: deviceType,
                    connectionState: existingState
                )
                updated.append(device)
            }
        }
        
        discoveredDevices = updated.sorted(by: { $0.name < $1.name })
    }

    private func friendlyName(from serviceName: String) -> String {
        serviceName
            .replacingOccurrences(of: ".local.", with: "")
            .replacingOccurrences(of: ".local",  with: "")
            .replacingOccurrences(of: "-", with: " ")
    }

    deinit {
        browsers.forEach { $0.cancel() }
    }
}
