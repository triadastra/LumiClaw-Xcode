//
//  BonjourDiscovery.swift
//  LumiAgentIOS
//
//  Discovers macOS LumiAgent instances on the local network
//  via Bonjour (NWBrowser) browsing the "_lumiagent._tcp" service type.
//
//  The macOS side advertises using NWListener with the same service type.
//  Both sides must be on the same Wi-Fi / LAN segment.
//
//  Local Network permission:
//    Add NSLocalNetworkUsageDescription to Info.plist.
//    Add NSBonjourServices array with "_lumiagent._tcp" to Info.plist.
//

import Network
import Foundation
import Combine

// MARK: - Bonjour Discovery

/// Discovers nearby macOS LumiAgent hosts on the local network via Bonjour.
@MainActor
public final class BonjourDiscovery: ObservableObject {

    // MARK: - Constants

    public static let serviceType = "_lumiagent._tcp"
    public static let port: UInt16 = 47285

    // MARK: - Published

    @Published public private(set) var discoveredDevices: [MacDevice] = []
    @Published public private(set) var isBrowsing: Bool = false
    @Published public private(set) var browsingError: String?

    // MARK: - Private

    private var browser: NWBrowser?
    private let queue = DispatchQueue(label: "com.lumiagent.bonjour", qos: .utility)

    public init() {}

    // MARK: - Browse

    /// Start browsing for LumiAgent hosts. Call once; call stopBrowsing() to clean up.
    public func startBrowsing() {
        guard !isBrowsing else { return }
        browsingError = nil
        isBrowsing = true

        let descriptor = NWBrowser.Descriptor.bonjour(type: Self.serviceType, domain: nil)
        let params = NWParameters()
        params.includePeerToPeer = true

        let b = NWBrowser(for: descriptor, using: params)

        b.browseResultsChangedHandler = { [weak self] results, changes in
            Task { @MainActor [weak self] in
                self?.handleBrowseResults(Array(results))
            }
        }

        b.stateUpdateHandler = { [weak self] state in
            Task { @MainActor [weak self] in
                switch state {
                case .ready:
                    self?.browsingError = nil
                case .failed(let error):
                    self?.browsingError = error.localizedDescription
                    self?.isBrowsing = false
                case .cancelled:
                    self?.isBrowsing = false
                default:
                    break
                }
            }
        }

        b.start(queue: queue)
        self.browser = b
    }

    public func stopBrowsing() {
        browser?.cancel()
        browser = nil
        isBrowsing = false
    }

    // MARK: - Handle Results

    private func handleBrowseResults(_ results: [NWBrowser.Result]) {
        var updated: [MacDevice] = []
        for result in results {
            guard case .service(let name, _, _, _) = result.endpoint else { continue }
            // Preserve existing connection state if device was already known.
            let existingState = discoveredDevices.first(where: { $0.serviceName == name })?.connectionState ?? .discovered
            let device = MacDevice(
                name: friendlyName(from: name),
                serviceName: name,
                endpoint: result.endpoint,
                connectionState: existingState
            )
            updated.append(device)
        }
        discoveredDevices = updated
    }

    /// Strips ".local" suffix and other Bonjour decorations.
    private func friendlyName(from serviceName: String) -> String {
        serviceName
            .replacingOccurrences(of: ".local.", with: "")
            .replacingOccurrences(of: ".local",  with: "")
            .replacingOccurrences(of: "-", with: " ")
    }

    deinit {
        browser?.cancel()
    }
}
