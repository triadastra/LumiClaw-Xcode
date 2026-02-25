//
//  ExecutionSession.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

import Foundation

// MARK: - Execution Session

/// Represents a single execution session of an agent
struct ExecutionSession: Identifiable, Codable {
    let id: UUID
    let agentId: UUID
    var userPrompt: String
    var steps: [ExecutionStep]
    var result: ExecutionResult?
    var status: ExecutionStatus
    var startedAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        agentId: UUID,
        userPrompt: String,
        steps: [ExecutionStep] = [],
        result: ExecutionResult? = nil,
        status: ExecutionStatus = .running,
        startedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.agentId = agentId
        self.userPrompt = userPrompt
        self.steps = steps
        self.result = result
        self.status = status
        self.startedAt = startedAt
        self.completedAt = completedAt
    }

    var duration: TimeInterval? {
        guard let completedAt = completedAt else { return nil }
        return completedAt.timeIntervalSince(startedAt)
    }
}

// MARK: - Execution Step

/// A single step in an execution session
struct ExecutionStep: Identifiable, Codable {
    let id: UUID
    var type: ExecutionStepType
    var content: String
    var timestamp: Date
    var metadata: [String: String]?

    init(
        id: UUID = UUID(),
        type: ExecutionStepType,
        content: String,
        timestamp: Date = Date(),
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

// MARK: - Execution Step Type

/// Types of execution steps
enum ExecutionStepType: String, Codable {
    case thinking = "thinking"
    case toolCall = "tool_call"
    case toolResult = "tool_result"
    case response = "response"
    case error = "error"
    case approval = "approval"

    var displayName: String {
        switch self {
        case .thinking: return "Thinking"
        case .toolCall: return "Tool Call"
        case .toolResult: return "Tool Result"
        case .response: return "Response"
        case .error: return "Error"
        case .approval: return "Approval Required"
        }
    }

    var icon: String {
        switch self {
        case .thinking: return "brain"
        case .toolCall: return "wrench"
        case .toolResult: return "checkmark.circle"
        case .response: return "bubble.left"
        case .error: return "exclamationmark.triangle"
        case .approval: return "hand.raised"
        }
    }
}

// MARK: - Execution Status

/// Status of an execution session
enum ExecutionStatus: String, Codable {
    case running
    case completed
    case failed
    case cancelled
    case waitingForApproval = "waiting_for_approval"

    var displayName: String {
        switch self {
        case .running: return "Running"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        case .waitingForApproval: return "Waiting for Approval"
        }
    }
}

// MARK: - Execution Result

/// Final result of an execution session
struct ExecutionResult: Codable {
    var success: Bool
    var output: String?
    var error: String?
    var tokensUsed: Int?
    var costEstimate: Double? // in USD

    init(
        success: Bool,
        output: String? = nil,
        error: String? = nil,
        tokensUsed: Int? = nil,
        costEstimate: Double? = nil
    ) {
        self.success = success
        self.output = output
        self.error = error
        self.tokensUsed = tokensUsed
        self.costEstimate = costEstimate
    }
}

// MARK: - Tool Call

/// Represents a tool/function call from the AI
struct ToolCall: Identifiable, Codable {
    let id: String
    var name: String
    var arguments: [String: String]
    var result: ToolResult?

    init(
        id: String = UUID().uuidString,
        name: String,
        arguments: [String: String],
        result: ToolResult? = nil
    ) {
        self.id = id
        self.name = name
        self.arguments = arguments
        self.result = result
    }
}

// MARK: - Tool Result

/// Result of a tool execution
struct ToolResult: Codable {
    var success: Bool
    var output: String?
    var error: String?
    var executionTime: TimeInterval?

    init(
        success: Bool,
        output: String? = nil,
        error: String? = nil,
        executionTime: TimeInterval? = nil
    ) {
        self.success = success
        self.output = output
        self.error = error
        self.executionTime = executionTime
    }
}
