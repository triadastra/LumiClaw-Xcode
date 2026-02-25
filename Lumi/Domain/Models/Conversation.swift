//
//  Conversation.swift
//  LumiAgent
//

import Foundation

// MARK: - Conversation

struct Conversation: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String?
    var participantIds: [UUID]
    var messages: [SpaceMessage]
    var createdAt: Date
    var updatedAt: Date

    var isGroup: Bool { participantIds.count > 1 }

    func displayTitle(agents: [Agent]) -> String {
        if let title, !title.isEmpty { return title }
        let names = participantIds.compactMap { id in agents.first { $0.id == id }?.name }
        return names.isEmpty ? "New Conversation" : names.joined(separator: ", ")
    }

    var lastMessage: SpaceMessage? { messages.last }

    init(
        id: UUID = UUID(),
        title: String? = nil,
        participantIds: [UUID],
        messages: [SpaceMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.participantIds = participantIds
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Space Message

struct SpaceMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: SpaceMessageRole
    var content: String
    let agentId: UUID?
    let timestamp: Date
    var isStreaming: Bool
    /// Optional JPEG image data attached to this message (e.g. screenshot for vision).
    let imageData: Data?

    enum SpaceMessageRole: String, Codable {
        case user
        case agent
    }

    init(
        id: UUID = UUID(),
        role: SpaceMessageRole,
        content: String,
        agentId: UUID? = nil,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        imageData: Data? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.agentId = agentId
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.imageData = imageData
    }
}
