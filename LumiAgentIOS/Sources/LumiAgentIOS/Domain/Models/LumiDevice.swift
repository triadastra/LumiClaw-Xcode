//
//  LumiDevice.swift
//  LumiAgentIOS
//
//  Represents a discovered device on the local network (Macs, ESP32s, etc).
//

import Foundation
import Network
import SwiftUI

// MARK: - Device Type

public enum LumiDeviceType: String, Codable, Sendable {
    case mac            = "mac"
    case esp32          = "esp32"
    case arduino        = "arduino"
    case generic        = "generic"

    public var systemImage: String {
        switch self {
        case .mac:     return "desktopcomputer"
        case .esp32:   return "cpu"
        case .arduino: return "memorychip"
        case .generic: return "network"
        }
    }
    
    public var color: Color {
        switch self {
        case .mac:     return .blue
        case .esp32:   return .purple
        case .arduino: return .teal
        case .generic: return .gray
        }
    }
}

// MARK: - Lumi Device

/// A device discovered via Bonjour.
public struct LumiDevice: Identifiable, Equatable, Sendable {
    public let id: UUID
    /// Human-readable hostname
    public let name: String
    /// Bonjour service name
    public let serviceName: String
    /// Resolved endpoint for NWConnection
    public let endpoint: NWEndpoint
    /// Connection state
    public var connectionState: ConnectionState
    /// Type of device
    public var type: LumiDeviceType

    public init(
        name: String,
        serviceName: String,
        endpoint: NWEndpoint,
        type: LumiDeviceType = .generic,
        connectionState: ConnectionState = .discovered
    ) {
        self.id = UUID()
        self.name = name
        self.serviceName = serviceName
        self.endpoint = endpoint
        self.type = type
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
    }

    // MARK: - Equatable

    public static func == (lhs: LumiDevice, rhs: LumiDevice) -> Bool {
        lhs.id == rhs.id
    }
}
