//
//  IOSBrightnessController.swift
//  LumiAgentIOS
//
//  Reads and writes screen brightness using UIScreen.main.brightness.
//  Works on physical devices and simulators (simulator clamps to system value).
//
//  iOS permission: No special entitlement required.
//

import UIKit

// MARK: - Brightness Controller

/// Controls the device's screen brightness level.
public actor IOSBrightnessController {

    public static let shared = IOSBrightnessController()
    private init() {}

    // MARK: - Read

    /// Returns the current screen brightness (0.0 – 1.0).
    @MainActor
    public func getBrightness() -> Double {
        Double(UIScreen.main.brightness)
    }

    // MARK: - Write

    /// Sets screen brightness to `level` (0.0 – 1.0).
    /// - Parameter animated: Whether to smoothly animate the change.
    @MainActor
    public func setBrightness(_ level: Double, animated: Bool = true) {
        let clamped = max(0.0, min(1.0, level))
        if animated {
            UIView.animate(withDuration: 0.3) {
                UIScreen.main.brightness = CGFloat(clamped)
            }
        } else {
            UIScreen.main.brightness = CGFloat(clamped)
        }
    }

    /// Increase brightness by `step` (default 0.1).
    @MainActor
    public func increaseBrightness(step: Double = 0.1) {
        let current = getBrightness()
        setBrightness(current + step)
    }

    /// Decrease brightness by `step` (default 0.1).
    @MainActor
    public func decreaseBrightness(step: Double = 0.1) {
        let current = getBrightness()
        setBrightness(current - step)
    }
}
