//
//  IOSMessagesController.swift
//  LumiAgentIOS
//
//  Composes SMS / iMessage via MFMessageComposeViewController.
//
//  iOS sandbox note:
//    • SENDING:  Full compose + send via system sheet (user confirms). No entitlement needed.
//    • READING:  Not available — iOS does not expose the Messages database to 3rd-party apps.
//    • iMessage: Works transparently if the recipient is on Apple platforms.
//
//  The controller vends a UIViewControllerRepresentable wrapper for use in SwiftUI.
//

import MessageUI
import SwiftUI

// MARK: - Compose Request

/// Parameters for a new message compose session.
public struct MessageComposeRequest: Identifiable {
    public let id = UUID()
    public let recipients: [String]
    public let body: String
    public let subject: String?

    public init(recipients: [String], body: String = "", subject: String? = nil) {
        self.recipients = recipients
        self.body = body
        self.subject = subject
    }
}

// MARK: - Compose Result

public enum MessageComposeResult {
    case sent
    case cancelled
    case failed(Error?)
}

// MARK: - Controller

public final class IOSMessagesController {
    public static let shared = IOSMessagesController()
    private init() {}

    /// Returns true if the device can send SMS/iMessages.
    public var canSendMessages: Bool {
        MFMessageComposeViewController.canSendText()
    }

    /// Returns true if the device supports attaching subjects (carrier dependent).
    public var canSendSubject: Bool {
        MFMessageComposeViewController.canSendSubject()
    }
}

// MARK: - SwiftUI Representable

/// Presents the system message compose sheet from SwiftUI.
public struct MessageComposeView: UIViewControllerRepresentable {
    private let request: MessageComposeRequest
    private let completion: (MessageComposeResult) -> Void

    public init(request: MessageComposeRequest, completion: @escaping (MessageComposeResult) -> Void) {
        self.request = request
        self.completion = completion
    }

    public func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.recipients = request.recipients
        vc.body = request.body
        if let subject = request.subject, MFMessageComposeViewController.canSendSubject() {
            vc.subject = subject
        }
        vc.messageComposeDelegate = context.coordinator
        return vc
    }

    public func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    public final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        private let completion: (MessageComposeResult) -> Void
        init(completion: @escaping (MessageComposeResult) -> Void) {
            self.completion = completion
        }

        public func messageComposeViewController(
            _ controller: MFMessageComposeViewController,
            didFinishWith result: MFMessageComposeResult
        ) {
            controller.dismiss(animated: true)
            switch result {
            case .sent:      completion(.sent)
            case .cancelled: completion(.cancelled)
            case .failed:    completion(.failed(nil))
            @unknown default: completion(.failed(nil))
            }
        }
    }
}

// MARK: - Quick-send helper

/// Sheet-modifier helper for triggering message compose from any SwiftUI view.
public struct MessageComposeSheet: ViewModifier {
    @Binding var request: MessageComposeRequest?
    @State private var result: MessageComposeResult?

    public func body(content: Content) -> some View {
        content
            .sheet(item: $request) { req in
                if MFMessageComposeViewController.canSendText() {
                    MessageComposeView(request: req) { outcome in
                        result = outcome
                        request = nil
                    }
                    .ignoresSafeArea()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "message.badge.waveform")
                            .font(.system(size: 44))
                            .foregroundStyle(.secondary)
                        Text("Cannot Send Messages")
                            .font(.headline)
                        Text("This device is not configured for SMS or iMessage.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Close") { request = nil }
                            .buttonStyle(.borderedProminent)
                    }
                    .padding(32)
                    .presentationDetents([.medium])
                }
            }
    }
}

public extension View {
    /// Attach this modifier to present a message compose sheet when `request` becomes non-nil.
    func messageComposeSheet(_ request: Binding<MessageComposeRequest?>) -> some View {
        modifier(MessageComposeSheet(request: request))
    }
}
