//
//  ScreenCapture.swift
//  LumiAgent
//
//  macOS screen capture utilities used by the agent vision loop.
//  On iOS, screen capture is restricted by the OS — stubs return nil.
//

import Foundation

#if os(macOS)
import AppKit
import CoreGraphics
import ImageIO

/// Captures a specific display and returns JPEG data for direct AI vision input.
/// `displayID` should be the CGDirectDisplayID of the target screen.
/// Runs synchronously — call from a background thread / Task.detached.
nonisolated func captureScreenAsJPEG(maxWidth: CGFloat = 1440, displayID: UInt32? = nil) -> Data? {
    let tmpURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("lumi_vision_\(UUID().uuidString).png")
    defer { try? FileManager.default.removeItem(at: tmpURL) }

    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    // Target the specific display so multi-monitor setups don't composite all screens.
    if let id = displayID {
        proc.arguments = ["-x", "-D", "\(id)", tmpURL.path]
    } else {
        proc.arguments = ["-x", "-m", tmpURL.path]
    }
    guard (try? proc.run()) != nil else { return nil }
    proc.waitUntilExit()
    guard proc.terminationStatus == 0 else { return nil }

    guard let src = CGImageSourceCreateWithURL(tmpURL as CFURL, nil),
          let cg  = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }

    let origW = CGFloat(cg.width), origH = CGFloat(cg.height)
    let scale = min(1.0, maxWidth / origW)
    let tw = Int(origW * scale), th = Int(origH * scale)

    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: tw, height: th, bitsPerComponent: 8,
                              bytesPerRow: 0, space: cs,
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    else { return nil }
    ctx.interpolationQuality = .high
    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: tw, height: th))
    guard let scaled = ctx.makeImage() else { return nil }

    return NSBitmapImageRep(cgImage: scaled).representation(using: .jpeg, properties: [.compressionFactor: 0.82])
}

/// Captures the frontmost non-Lumi window and returns JPEG data.
/// Falls back to full-screen capture if the window ID cannot be determined.
/// Runs synchronously — call from a background thread / Task.detached.
func captureWindowAsJPEG(maxWidth: CGFloat = 1440) -> Data? {
    let myPID = ProcessInfo.processInfo.processIdentifier
    let windowList = CGWindowListCopyWindowInfo(
        [.optionOnScreenOnly, .excludeDesktopElements],
        kCGNullWindowID
    ) as? [[CFString: Any]] ?? []

    var targetWindowID: CGWindowID?
    for info in windowList {
        guard let pid = info[kCGWindowOwnerPID] as? Int32,
              pid != myPID,
              let layer = info[kCGWindowLayer] as? Int,
              layer == 0,
              let wid = info[kCGWindowNumber] as? CGWindowID else { continue }
        targetWindowID = wid
        break
    }

    guard let windowID = targetWindowID else {
        return captureScreenAsJPEG(maxWidth: maxWidth)
    }

    let tmpURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("lumi_window_\(UUID().uuidString).png")
    defer { try? FileManager.default.removeItem(at: tmpURL) }

    let proc = Process()
    proc.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
    proc.arguments = ["-x", "-l", "\(windowID)", tmpURL.path]
    guard (try? proc.run()) != nil else { return captureScreenAsJPEG(maxWidth: maxWidth) }
    proc.waitUntilExit()
    guard proc.terminationStatus == 0 else { return captureScreenAsJPEG(maxWidth: maxWidth) }

    guard let src = CGImageSourceCreateWithURL(tmpURL as CFURL, nil),
          let cg  = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
        return captureScreenAsJPEG(maxWidth: maxWidth)
    }

    let origW = CGFloat(cg.width), origH = CGFloat(cg.height)
    let scale = min(1.0, maxWidth / origW)
    let tw = Int(origW * scale), th = Int(origH * scale)

    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: tw, height: th, bitsPerComponent: 8,
                              bytesPerRow: 0, space: cs,
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    else { return nil }
    ctx.interpolationQuality = .high
    ctx.draw(cg, in: CGRect(x: 0, y: 0, width: tw, height: th))
    guard let scaled = ctx.makeImage() else { return nil }

    return NSBitmapImageRep(cgImage: scaled).representation(using: .jpeg, properties: [.compressionFactor: 0.82])
}

#else

/// iOS stub — screen capture is restricted on iOS.
func captureScreenAsJPEG(maxWidth: CGFloat = 1440, displayID: UInt32? = nil) -> Data? { nil }

#endif
