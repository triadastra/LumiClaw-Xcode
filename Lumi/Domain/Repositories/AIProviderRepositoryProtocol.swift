//
//  AIProviderRepositoryProtocol.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

import Foundation

// MARK: - AI Provider Repository Protocol

protocol AIProviderRepositoryProtocol {
    /// Send a message and get a response (non-streaming)
    func sendMessage(
        provider: AIProvider,
        model: String,
        messages: [AIMessage],
        systemPrompt: String?,
        tools: [AITool]?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AIResponse

    /// Send a message with streaming response
    func sendMessageStream(
        provider: AIProvider,
        model: String,
        messages: [AIMessage],
        systemPrompt: String?,
        tools: [AITool]?,
        temperature: Double?,
        maxTokens: Int?
    ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>

    /// Get available models for a provider
    func getAvailableModels(provider: AIProvider) async throws -> [String]
}
