//
//  AgentExecutionEngineTests.swift
//  LumiAgentTests
//
//  Created by Lumi Agent on 2026-02-18.
//

#if os(macOS)
import XCTest
@testable import LumiAgent

final class AgentExecutionEngineTests: XCTestCase {
    var engine: AgentExecutionEngine!
    var mockAIRepository: MockAIRepository!

    override func setUp() async throws {
        mockAIRepository = MockAIRepository()
        engine = AgentExecutionEngine(
            aiRepository: mockAIRepository,
            sessionRepository: MockSessionRepository(),
            authorizationManager: .shared,
            toolRegistry: .shared,
            auditLogger: .shared
        )
    }

    func testEngineInitialization() {
        XCTAssertFalse(engine.isExecuting)
        XCTAssertNil(engine.currentSession)
        XCTAssertEqual(engine.executionOutput, "")
    }

    func testExecutionWithSimplePrompt() async throws {
        // Given
        let agent = createTestAgent()
        let prompt = "Hello, agent!"

        // Mock AI response
        mockAIRepository.mockResponse = AIResponse(
            id: "test-1",
            content: "Hello! How can I help?",
            toolCalls: nil,
            finishReason: "stop",
            usage: nil
        )

        // When
        try await engine.execute(agent: agent, userPrompt: prompt)

        // Then
        XCTAssertFalse(engine.isExecuting)
        XCTAssertNotNil(engine.currentSession)
        XCTAssertTrue(engine.executionOutput.contains("Hello"))
    }

    // MARK: - Helpers

    private func createTestAgent() -> Agent {
        Agent(
            name: "Test Agent",
            configuration: AgentConfiguration(
                provider: .ollama,
                model: "llama3"
            )
        )
    }
}

// MARK: - Mock AI Repository

class MockAIRepository: AIProviderRepositoryProtocol {
    var mockResponse: AIResponse?
    var mockError: Error?

    func sendMessage(
        provider: AIProvider,
        model: String,
        messages: [AIMessage],
        systemPrompt: String?,
        tools: [AITool]?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AIResponse {
        if let error = mockError {
            throw error
        }
        return mockResponse ?? AIResponse(
            id: "mock",
            content: "Mock response",
            toolCalls: nil,
            finishReason: "stop",
            usage: nil
        )
    }

    func sendMessageStream(
        provider: AIProvider,
        model: String,
        messages: [AIMessage],
        systemPrompt: String?,
        tools: [AITool]?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AsyncThrowingStream<AIStreamChunk, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }

    func getAvailableModels(provider: AIProvider) async throws -> [String] {
        ["test-model"]
    }
}

// MARK: - Mock Session Repository

class MockSessionRepository: SessionRepositoryProtocol {
    var sessions: [ExecutionSession] = []

    func create(_ session: ExecutionSession) async throws {
        sessions.append(session)
    }

    func update(_ session: ExecutionSession) async throws {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        }
    }

    func get(id: UUID) async throws -> ExecutionSession? {
        sessions.first { $0.id == id }
    }

    func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] {
        Array(sessions.filter { $0.agentId == agentId }.prefix(limit))
    }

    func getRecent(limit: Int) async throws -> [ExecutionSession] {
        Array(sessions.prefix(limit))
    }
}
#endif
