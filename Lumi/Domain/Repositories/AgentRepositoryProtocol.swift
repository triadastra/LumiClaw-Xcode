//
//  AgentRepositoryProtocol.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

import Foundation

// MARK: - Agent Repository Protocol

protocol AgentRepositoryProtocol {
    func create(_ agent: Agent) async throws
    func update(_ agent: Agent) async throws
    func delete(id: UUID) async throws
    func get(id: UUID) async throws -> Agent?
    func getAll() async throws -> [Agent]
    func getByStatus(_ status: AgentStatus) async throws -> [Agent]
}

// MARK: - Session Repository Protocol

protocol SessionRepositoryProtocol {
    func create(_ session: ExecutionSession) async throws
    func update(_ session: ExecutionSession) async throws
    func get(id: UUID) async throws -> ExecutionSession?
    func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession]
    func getRecent(limit: Int) async throws -> [ExecutionSession]
}

