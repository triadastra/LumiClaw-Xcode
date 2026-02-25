//
//  AgentRepository.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

import Foundation

// MARK: - Agent Repository

final class AgentRepository: AgentRepositoryProtocol {
    private let database: DatabaseManager
    private let fileName = "agents.json"

    init(database: DatabaseManager = .shared) {
        self.database = database
    }

    func create(_ agent: Agent) async throws {
        var agents = try database.load([Agent].self, from: fileName, default: [])
        agents.removeAll { $0.id == agent.id }
        agents.append(agent)
        try database.save(agents, to: fileName)
    }

    func update(_ agent: Agent) async throws {
        var agents = try database.load([Agent].self, from: fileName, default: [])
        guard let index = agents.firstIndex(where: { $0.id == agent.id }) else { return }
        var updated = agent
        updated.updatedAt = Date()
        agents[index] = updated
        try database.save(agents, to: fileName)
    }

    func delete(id: UUID) async throws {
        var agents = try database.load([Agent].self, from: fileName, default: [])
        agents.removeAll { $0.id == id }
        try database.save(agents, to: fileName)
    }

    func get(id: UUID) async throws -> Agent? {
        let agents = try database.load([Agent].self, from: fileName, default: [])
        return agents.first { $0.id == id }
    }

    func getAll() async throws -> [Agent] {
        let agents = try database.load([Agent].self, from: fileName, default: [])
        return agents.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func getByStatus(_ status: AgentStatus) async throws -> [Agent] {
        let agents = try database.load([Agent].self, from: fileName, default: [])
        return agents
            .filter { $0.status == status }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
