//
//  AIProviderTypes.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Unified types for all AI providers
//

import Foundation

// MARK: - Unified AI Message

struct AIMessage {
    enum Role: String {
        case system
        case user
        case assistant
        case tool
    }

    let role: Role
    let content: String
    let toolCallId: String?
    let toolCalls: [ToolCall]?
    /// JPEG image data to attach as a vision input alongside `content`.
    /// Only valid on `.user` role messages. Supported by OpenAI, Anthropic, Gemini.
    let imageData: Data?

    init(
        role: Role,
        content: String,
        toolCallId: String? = nil,
        toolCalls: [ToolCall]? = nil,
        imageData: Data? = nil
    ) {
        self.role = role
        self.content = content
        self.toolCallId = toolCallId
        self.toolCalls = toolCalls
        self.imageData = imageData
    }
}

// MARK: - Unified AI Tool Definition

struct AITool {
    let name: String
    let description: String
    let parameters: AIToolParameters

    init(name: String, description: String, parameters: AIToolParameters) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

// MARK: - AI Tool Parameters

struct AIToolParameters {
    let type: String // "object"
    let properties: [String: AIToolProperty]
    let required: [String]

    init(type: String = "object", properties: [String: AIToolProperty], required: [String] = []) {
        self.type = type
        self.properties = properties
        self.required = required
    }

    var asDictionary: [String: Any] {
        [
            "type": type,
            "properties": properties.mapValues { $0.asDictionary },
            "required": required
        ]
    }
}

// MARK: - AI Tool Property

struct AIToolProperty {
    let type: String // "string", "number", "boolean", "array", "object"
    let description: String
    let enumValues: [String]?

    init(type: String, description: String, enumValues: [String]? = nil) {
        self.type = type
        self.description = description
        self.enumValues = enumValues
    }

    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "type": type,
            "description": description
        ]
        if let enumValues = enumValues {
            dict["enum"] = enumValues
        }
        return dict
    }
}

// MARK: - Unified AI Response

struct AIResponse {
    let id: String
    let content: String?
    let toolCalls: [ToolCall]?
    let finishReason: String?
    let usage: AIUsage?

    init(id: String, content: String?, toolCalls: [ToolCall]?, finishReason: String?, usage: AIUsage?) {
        self.id = id
        self.content = content
        self.toolCalls = toolCalls
        self.finishReason = finishReason
        self.usage = usage
    }
}

// MARK: - AI Usage

struct AIUsage {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    init(promptTokens: Int, completionTokens: Int, totalTokens: Int) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

// MARK: - Unified AI Stream Chunk

struct AIStreamChunk {
    let id: String
    let content: String?
    let toolCallChunk: ToolCallChunk?
    let finishReason: String?
    let done: Bool

    struct ToolCallChunk {
        let id: String
        let name: String?
        let argumentsChunk: String
    }

    init(id: String, content: String?, toolCallChunk: ToolCallChunk?, finishReason: String?, done: Bool = false) {
        self.id = id
        self.content = content
        self.toolCallChunk = toolCallChunk
        self.finishReason = finishReason
        self.done = done
    }
}
