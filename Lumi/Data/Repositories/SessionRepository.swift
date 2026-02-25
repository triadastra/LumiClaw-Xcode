//
//  SessionRepository.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

import Foundation

// MARK: - Session Repository

final class SessionRepository: SessionRepositoryProtocol {
    private let database: DatabaseManager
    private let fileName = "sessions.json"

    init(database: DatabaseManager = .shared) {
        self.database = database
    }

    func create(_ session: ExecutionSession) async throws {
        var sessions = try database.load([ExecutionSession].self, from: fileName, default: [])
        sessions.removeAll { $0.id == session.id }
        sessions.append(session)
        try database.save(sessions, to: fileName)
    }

    func update(_ session: ExecutionSession) async throws {
        var sessions = try database.load([ExecutionSession].self, from: fileName, default: [])
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        try database.save(sessions, to: fileName)
    }

    func get(id: UUID) async throws -> ExecutionSession? {
        let sessions = try database.load([ExecutionSession].self, from: fileName, default: [])
        return sessions.first { $0.id == id }
    }

    func getForAgent(agentId: UUID, limit: Int = 50) async throws -> [ExecutionSession] {
        let sessions = try database.load([ExecutionSession].self, from: fileName, default: [])
        return sessions
            .filter { $0.agentId == agentId }
            .sorted { $0.startedAt > $1.startedAt }
            .prefix(limit)
            .map { $0 }
    }

    func getRecent(limit: Int = 50) async throws -> [ExecutionSession] {
        let sessions = try database.load([ExecutionSession].self, from: fileName, default: [])
        return sessions
            .sorted { $0.startedAt > $1.startedAt }
            .prefix(limit)
            .map { $0 }
    }
}
