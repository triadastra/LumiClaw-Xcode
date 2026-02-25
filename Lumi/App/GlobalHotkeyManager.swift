//
//  GlobalHotkeyManager.swift
//  LumiAgent
//
//  Registers system-wide hotkeys using Carbon's RegisterEventHotKey.
//  This properly *intercepts* the key — it never reaches the frontmost app —
//  unlike NSEvent.addGlobalMonitorForEvents which only observes.
//
//  Primary:   ⌥⌘L  (Option + Command + L)
//  Secondary: ^L   (Control + L)
//

#if os(macOS)
import Carbon.HIToolbox
import Foundation

// MARK: - Carbon key constants (bridged for Swift clarity)

extension GlobalHotkeyManager {
    /// Carbon virtual key codes for common keys.
    enum KeyCode {
        static let L: UInt32     = UInt32(kVK_ANSI_L)
        static let E: UInt32     = UInt32(kVK_ANSI_E)
        static let G: UInt32     = UInt32(kVK_ANSI_G)
        static let R: UInt32     = UInt32(kVK_ANSI_R)
        static let Space: UInt32 = UInt32(kVK_Space)
    }
    /// Carbon modifier flags.
    enum Modifiers {
        static let command: UInt32 = UInt32(cmdKey)      // 256
        static let option: UInt32  = UInt32(optionKey)   // 2048
        static let shift: UInt32   = UInt32(shiftKey)    // 512
        static let control: UInt32 = UInt32(controlKey)  // 4096
    }
}

// MARK: - Manager

final class GlobalHotkeyManager {
    static let shared = GlobalHotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyRef2: EventHotKeyRef?
    private var hotKeyRef3: EventHotKeyRef?
    private var hotKeyRef4: EventHotKeyRef?
    private var hotKeyRef5: EventHotKeyRef?
    private var hotKeyRef6: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    /// Called on the main thread when the primary hotkey is pressed.
    var onActivate: (() -> Void)?
    /// Called on the main thread when the secondary hotkey is pressed.
    var onActivate2: (() -> Void)?
    /// Called on the main thread when the tertiary hotkey is pressed.
    var onActivate3: (() -> Void)?
    /// Called on the main thread when the quaternary hotkey is pressed.
    var onActivate4: (() -> Void)?
    /// Called on the main thread when the 5th hotkey is pressed.
    var onActivate5: (() -> Void)?
    /// Called on the main thread when the 6th hotkey is pressed.
    var onActivate6: (() -> Void)?

    private init() {}

    // MARK: - Internal Handler Setup

    private func ensureEventHandlerInstalled() {
        guard eventHandlerRef == nil else { return }

        var spec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userInfo) -> OSStatus in
                guard let ptr = userInfo, let event = event else { return OSStatus(eventNotHandledErr) }
                let mgr = Unmanaged<GlobalHotkeyManager>
                    .fromOpaque(ptr)
                    .takeUnretainedValue()

                var hkID = EventHotKeyID()
                let err = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hkID
                )
                guard err == noErr else { return OSStatus(eventNotHandledErr) }

                switch hkID.id {
                case 1:  DispatchQueue.main.async { mgr.onActivate?() }
                case 2:  DispatchQueue.main.async { mgr.onActivate2?() }
                case 3:  DispatchQueue.main.async { mgr.onActivate3?() }
                case 4:  DispatchQueue.main.async { mgr.onActivate4?() }
                case 5:  DispatchQueue.main.async { mgr.onActivate5?() }
                case 6:  DispatchQueue.main.async { mgr.onActivate6?() }
                default: return OSStatus(eventNotHandledErr)
                }
                return noErr
            },
            1,
            &spec,
            selfPtr,
            &eventHandlerRef
        )
    }

    // MARK: Register / Unregister

    /// Register the primary global hotkey (ID: 1).
    func register(keyCode: UInt32 = KeyCode.L,
                  modifiers: UInt32 = Modifiers.command) {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
        ensureEventHandlerInstalled()
        let hkID = EventHotKeyID(signature: 0x4C554D49, id: 1) // 'LUMI'
        RegisterEventHotKey(keyCode, modifiers, hkID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }

    /// Register a secondary global hotkey (ID: 2).
    func registerSecondary(keyCode: UInt32 = KeyCode.L,
                           modifiers: UInt32 = Modifiers.control) {
        if let ref = hotKeyRef2 { UnregisterEventHotKey(ref); hotKeyRef2 = nil }
        ensureEventHandlerInstalled()
        let hkID = EventHotKeyID(signature: 0x4C554D32, id: 2) // 'LUM2'
        RegisterEventHotKey(keyCode, modifiers, hkID, GetApplicationEventTarget(), 0, &hotKeyRef2)
    }

    /// Register a tertiary global hotkey (ID: 3).
    func registerTertiary(keyCode: UInt32 = KeyCode.L,
                          modifiers: UInt32 = Modifiers.option | Modifiers.command) {
        if let ref = hotKeyRef3 { UnregisterEventHotKey(ref); hotKeyRef3 = nil }
        ensureEventHandlerInstalled()
        let hkID = EventHotKeyID(signature: 0x4C554D33, id: 3) // 'LUM3'
        RegisterEventHotKey(keyCode, modifiers, hkID, GetApplicationEventTarget(), 0, &hotKeyRef3)
    }

    /// Register a quaternary global hotkey (ID: 4).
    func registerQuaternary(keyCode: UInt32, modifiers: UInt32) {
        if let ref = hotKeyRef4 { UnregisterEventHotKey(ref); hotKeyRef4 = nil }
        ensureEventHandlerInstalled()
        let hkID = EventHotKeyID(signature: 0x4C554D34, id: 4) // 'LUM4'
        RegisterEventHotKey(keyCode, modifiers, hkID, GetApplicationEventTarget(), 0, &hotKeyRef4)
    }

    /// Register a 5th global hotkey (ID: 5).
    func registerFifth(keyCode: UInt32, modifiers: UInt32) {
        if let ref = hotKeyRef5 { UnregisterEventHotKey(ref); hotKeyRef5 = nil }
        ensureEventHandlerInstalled()
        let hkID = EventHotKeyID(signature: 0x4C554D35, id: 5) // 'LUM5'
        RegisterEventHotKey(keyCode, modifiers, hkID, GetApplicationEventTarget(), 0, &hotKeyRef5)
    }

    /// Register a 6th global hotkey (ID: 6).
    func registerSixth(keyCode: UInt32, modifiers: UInt32) {
        if let ref = hotKeyRef6 { UnregisterEventHotKey(ref); hotKeyRef6 = nil }
        ensureEventHandlerInstalled()
        let hkID = EventHotKeyID(signature: 0x4C554D36, id: 6) // 'LUM6'
        RegisterEventHotKey(keyCode, modifiers, hkID, GetApplicationEventTarget(), 0, &hotKeyRef6)
    }

    func unregister() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
    }

    func unregisterAll() {
        if let ref = hotKeyRef   { UnregisterEventHotKey(ref); hotKeyRef = nil }
        if let ref = hotKeyRef2  { UnregisterEventHotKey(ref); hotKeyRef2 = nil }
        if let ref = hotKeyRef3  { UnregisterEventHotKey(ref); hotKeyRef3 = nil }
        if let ref = hotKeyRef4  { UnregisterEventHotKey(ref); hotKeyRef4 = nil }
        if let ref = hotKeyRef5  { UnregisterEventHotKey(ref); hotKeyRef5 = nil }
        if let ref = hotKeyRef6  { UnregisterEventHotKey(ref); hotKeyRef6 = nil }
        if let ref = eventHandlerRef { RemoveEventHandler(ref); eventHandlerRef = nil }
    }

    func unregisterSecondary() {
        if let ref = hotKeyRef2  { UnregisterEventHotKey(ref); hotKeyRef2 = nil }
    }
}
#endif
