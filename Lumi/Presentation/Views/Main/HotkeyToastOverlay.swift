#if os(macOS)
import AppKit
import SwiftUI

@MainActor
final class HotkeyToastOverlayController: NSObject {
    static let shared = HotkeyToastOverlayController()

    private var panel: NSPanel?
    private var dismissWorkItem: DispatchWorkItem?
    private let minWidth: CGFloat = 260
    private let maxWidth: CGFloat = 620
    private let minHeight: CGFloat = 46
    private let maxHeight: CGFloat = 280

    func show(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dismissWorkItem?.cancel()

            if self.panel == nil {
                self.createPanel(message: message)
            } else {
                self.update(message: message)
            }

            let work = DispatchWorkItem { [weak self] in
                self?.hide()
            }
            self.dismissWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
        }
    }

    private func createPanel(message: String) {
        let view = HotkeyToastView(message: message, minWidth: minWidth, maxWidth: maxWidth)
        let hosting = NSHostingView(rootView: view)
        let size = measuredSize(for: view)
        hosting.setFrameSize(size)

        let p = NSPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.contentView = hosting
        p.level = .statusBar
        p.isFloatingPanel = true
        p.hidesOnDeactivate = false
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        p.isReleasedWhenClosed = false

        position(panel: p, size: size)

        p.alphaValue = 0
        p.orderFrontRegardless()
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            p.animator().alphaValue = 1
        }
        panel = p
    }

    private func update(message: String) {
        guard let panel else { return }
        let view = HotkeyToastView(message: message, minWidth: minWidth, maxWidth: maxWidth)
        let size = measuredSize(for: view)
        let hosting = NSHostingView(rootView: view)
        hosting.setFrameSize(size)
        panel.contentView = hosting
        position(panel: panel, size: size)
        panel.orderFrontRegardless()
    }

    private func hide() {
        guard let panel else { return }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.10
            panel.animator().alphaValue = 0
        } completionHandler: {
            Task { @MainActor [weak self] in
                self?.panel?.orderOut(nil)
                self?.panel = nil
            }
        }
    }

    private func measuredSize(for view: HotkeyToastView) -> NSSize {
        // First pass: get natural width.
        let naturalHosting = NSHostingView(rootView: view.fixedSize(horizontal: true, vertical: false))
        naturalHosting.setFrameSize(NSSize(width: maxWidth, height: maxHeight))
        let natural = naturalHosting.fittingSize
        let resolvedWidth = max(minWidth, min(maxWidth, natural.width))

        // Second pass: measure height at the resolved width so wrapped text is fully visible.
        let wrappedHosting = NSHostingView(rootView: view.frame(width: resolvedWidth))
        wrappedHosting.setFrameSize(NSSize(width: resolvedWidth, height: maxHeight))
        let wrapped = wrappedHosting.fittingSize
        let width = resolvedWidth
        let height = min(maxHeight, max(minHeight, wrapped.height))
        return NSSize(width: width, height: height)
    }

    private func position(panel: NSPanel, size: NSSize) {
        if let screen = NSScreen.main?.visibleFrame {
            panel.setFrameOrigin(NSPoint(
                x: screen.maxX - size.width - 16,
                y: screen.maxY - size.height - 16
            ))
        }
    }
}

private struct HotkeyToastView: View {
    let message: String
    let minWidth: CGFloat
    let maxWidth: CGFloat

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "keyboard")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 1)
            Text(message)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: minWidth, maxWidth: maxWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThickMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
#endif
