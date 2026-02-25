//
//  NetworkMonitor.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Monitor network connectivity for AI provider calls
//

import Foundation
import Network
import Combine

// MARK: - Network Monitor

@MainActor
final class NetworkMonitor: ObservableObject {
    nonisolated let objectWillChange = ObservableObjectPublisher()

    // MARK: - Singleton

    static let shared = NetworkMonitor()

    // MARK: - Properties

    @Published var isConnected: Bool = true
    @Published var connectionType: NWInterface.InterfaceType?

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.lumiagent.network-monitor")

    // MARK: - Initialization

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    // MARK: - Monitoring

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
