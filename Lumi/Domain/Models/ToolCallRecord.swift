//
//  ToolCallRecord.swift
//  LumiAgent
//
//  A record of a single tool call made by an agent during execution.
//

import Foundation

struct ToolCallRecord: Identifiable {
    let id: UUID
    let agentId: UUID
    let agentName: String
    let toolName: String
    let arguments: [String: String]
    let result: String
    let timestamp: Date
    let success: Bool

    init(agentId: UUID, agentName: String, toolName: String,
         arguments: [String: String], result: String, success: Bool) {
        self.id = UUID()
        self.agentId = agentId
        self.agentName = agentName
        self.toolName = toolName
        self.arguments = arguments
        self.result = result
        self.timestamp = Date()
        self.success = success
    }
}
