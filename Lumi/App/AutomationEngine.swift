//
//  AutomationEngine.swift
//  LumiAgent
//
//  Monitors system events and triggers automation rules when their conditions are met.
//  Triggers: app launches/quits, screen unlock, Bluetooth device connect/disconnect,
//  Wi-Fi network joins, and time-based schedules.
//

#if os(macOS)
import AppKit
import Foundation
import Combine

// MARK: - Automation Engine

/// Monitors system events and fires automation rules when their trigger conditions are met.
@MainActor
final class AutomationEngine {

    /// Callback invoked on the main thread when a rule should fire.
    private let onFire: (AutomationRule) -> Void

    private var rules: [AutomationRule] = []
    private var cancellables = Set<AnyCancellable>()
    private var connectedDevices: Set<String> = []
    private var lastScheduleCheckMinute: Int = -1

    init(onFire: @escaping (AutomationRule) -> Void) {
        self.onFire = onFire
    }

    // MARK: - Public API

    func update(rules: [AutomationRule]) {
        self.rules = rules
        restart()
    }

    func runManually(_ rule: AutomationRule) {
        fire(rule)
    }

    // MARK: - Lifecycle

    private func start() {
        let nc = NSWorkspace.shared.notificationCenter

        nc.publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] note in
                guard let app = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication),
                      let name = app.localizedName else { return }
                self?.handleAppEvent(name: name, launched: true)
            }
            .store(in: &cancellables)

        nc.publisher(for: NSWorkspace.didTerminateApplicationNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] note in
                guard let app = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication),
                      let name = app.localizedName else { return }
                self?.handleAppEvent(name: name, launched: false)
            }
            .store(in: &cancellables)

        nc.publisher(for: NSWorkspace.screensDidWakeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleScreenUnlock()
            }
            .store(in: &cancellables)

        // Snapshot current Bluetooth state in background
        Task {
            let devices = await Task.detached(priority: .background) {
                return Self.currentBluetoothDevices()
            }.value
            self.connectedDevices = devices
        }

        // 15-second polling timer for Bluetooth diffs and schedule checks
        Timer.publish(every: 15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    let current = await Task.detached(priority: .background) {
                        return Self.currentBluetoothDevices()
                    }.value
                    self.handleBluetoothUpdate(current)
                    self.checkSchedules()
                }
            }
            .store(in: &cancellables)
    }

    func stop() {
        cancellables.removeAll()
    }

    private func restart() {
        stop()
        guard !rules.isEmpty else { return }
        start()
    }

    // MARK: - Event Handlers

    private func handleAppEvent(name: String, launched: Bool) {
        for rule in rules where rule.isEnabled {
            switch rule.trigger {
            case .appLaunched(let target) where launched:
                if name.localizedCaseInsensitiveContains(target) { fire(rule) }
            case .appQuit(let target) where !launched:
                if name.localizedCaseInsensitiveContains(target) { fire(rule) }
            default:
                break
            }
        }
    }

    private func handleScreenUnlock() {
        for rule in rules where rule.isEnabled {
            if case .screenUnlocked = rule.trigger { fire(rule) }
        }
    }

    private func handleBluetoothUpdate(_ current: Set<String>) {
        let connected    = current.subtracting(connectedDevices)
        let disconnected = connectedDevices.subtracting(current)
        connectedDevices = current

        for name in connected {
            for rule in rules where rule.isEnabled {
                if case .bluetoothConnected(let target) = rule.trigger,
                   name.localizedCaseInsensitiveContains(target) { fire(rule) }
            }
        }
        for name in disconnected {
            for rule in rules where rule.isEnabled {
                if case .bluetoothDisconnected(let target) = rule.trigger,
                   name.localizedCaseInsensitiveContains(target) { fire(rule) }
            }
        }
    }

    private func checkSchedules() {
        let now = Date()
        let cal = Calendar.current
        let h       = cal.component(.hour,    from: now)
        let m       = cal.component(.minute,  from: now)
        let weekday = cal.component(.weekday, from: now)

        // Fire at most once per clock-minute
        let minuteKey = h * 60 + m
        guard minuteKey != lastScheduleCheckMinute else { return }
        lastScheduleCheckMinute = minuteKey

        let isWeekday = (2...6).contains(weekday)

        for rule in rules where rule.isEnabled {
            guard case .scheduled(let rh, let rm, let rep) = rule.trigger,
                  rh == h, rm == m else { continue }

            let shouldFire: Bool
            switch rep {
            case .once:
                shouldFire = rule.lastRunAt == nil
            case .daily:
                shouldFire = true
            case .weekdays:
                shouldFire = isWeekday
            case .weekly:
                let creationDay = cal.component(.weekday, from: rule.createdAt)
                shouldFire = weekday == creationDay
            case .monthly:
                let creationDay = cal.component(.day, from: rule.createdAt)
                shouldFire = cal.component(.day, from: now) == creationDay
            }

            if shouldFire { fire(rule) }
        }
    }

    // MARK: - Fire

    private func fire(_ rule: AutomationRule) {
        DispatchQueue.main.async { [weak self] in
            self?.onFire(rule)
        }
    }

    // MARK: - System Queries

    nonisolated private static func currentBluetoothDevices() -> Set<String> {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        proc.arguments = ["SPBluetoothDataType", "-json"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        guard (try? proc.run()) != nil else { return [] }
        proc.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bt = json["SPBluetoothDataType"] as? [[String: Any]] else { return [] }

        var names = Set<String>()
        for section in bt {
            if let connected = section["device_connected"] as? [[String: Any]] {
                for device in connected {
                    if let name = device.keys.first { names.insert(name) }
                }
            }
        }
        return names
    }
}
#else
import Foundation

@MainActor
final class AutomationEngine {
    init(onFire: @escaping (AutomationRule) -> Void) {}
    func update(rules: [AutomationRule]) {}
    func runManually(_ rule: AutomationRule) {}
    func stop() {}
}
#endif
