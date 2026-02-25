//
//  MacDevice.swift
//  LumiAgentIOS
//
//  Represents a discovered macOS LumiAgent host on the local network.
//

import Foundation
import Network

// MARK: - Mac Device

/// A macOS machine running LumiAgent remote server, discovered via Bonjour.
public struct MacDevice: Identifiable, Equatable, Sendable {
    public let id: UUID
    /// Human-readable hostname (e.g. "Johns-MacBook-Pro.local")
    public let name: String
    /// Bonjour service name
    public let serviceName: String
    /// Resolved endpoint for NWConnection
    public let endpoint: NWEndpoint
    /// Connection state
    public var connectionState: ConnectionState

    public init(
        name: String,
        serviceName: String,
        endpoint: NWEndpoint,
        connectionState: ConnectionState = .discovered
    ) {
        self.id = UUID()
        self.name = name
        self.serviceName = serviceName
        self.endpoint = endpoint
        self.connectionState = connectionState
    }

    // MARK: - Connection State

    public enum ConnectionState: Equatable, Sendable {
        case discovered
        case connecting
        case connected
        case disconnected
        case failed(String)

        public var displayText: String {
            switch self {
            case .discovered:       return "Tap to Connect"
            case .connecting:       return "Connecting…"
            case .connected:        return "Connected"
            case .disconnected:     return "Disconnected"
            case .failed(let msg):  return "Failed: \(msg)"
            }
        }

        public var isConnected: Bool {
            if case .connected = self { return true }
            return false
        }

        public var systemImage: String {
            switch self {
            case .discovered:   return "wifi.circle"
            case .connecting:   return "wifi.circle"
            case .connected:    return "wifi.circle.fill"
            case .disconnected: return "wifi.slash"
            case .failed:       return "exclamationmark.triangle"
            }
        }
    }

    // MARK: - Equatable

    public static func == (lhs: MacDevice, rhs: MacDevice) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mac System Info

/// Snapshot of the connected Mac's system state.
public struct MacSystemInfo: Codable, Sendable {
    public var brightness: Double?      // 0–1
    public var volume: Double?          // 0–1
    public var isMuted: Bool?
    public var nowPlaying: NowPlayingInfo?
    public var batteryLevel: Double?    // 0–1, nil if plugged in with no battery
    public var isCharging: Bool?
    public var screenWidth: Int?
    public var screenHeight: Int?
    public var macOSVersion: String?
    public var hostname: String?

    public struct NowPlayingInfo: Codable, Sendable {
        public var title: String?
        public var artist: String?
        public var album: String?
        public var isPlaying: Bool?
        public var duration: Double?
        public var position: Double?
    }
}
