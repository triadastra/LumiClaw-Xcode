//
//  ProcessExecutor.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Executes non-privileged commands within sandbox
//

#if os(macOS)
import Foundation

// MARK: - Process Executor

/// Executes commands without elevated privileges
final class ProcessExecutor {
    // MARK: - Properties

    private let timeout: TimeInterval

    // MARK: - Initialization

    init(timeout: TimeInterval = 300) {
        self.timeout = timeout
    }

    // MARK: - Execution

    /// Execute a command and return output
    func execute(
        command: String,
        arguments: [String] = [],
        environment: [String: String]? = nil,
        workingDirectory: URL? = nil
    ) async throws -> CommandExecutionResult {
        let process = Process()

        // Set command
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments

        // Set environment
        if let environment = environment {
            process.environment = environment
        }

        // Set working directory
        if let workingDirectory = workingDirectory {
            process.currentDirectoryURL = workingDirectory
        }

        // Capture output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // Start process
        let startTime = Date()
        try process.run()

        // Wait with timeout
        let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if process.isRunning {
                process.terminate()
            }
        }

        process.waitUntilExit()
        timeoutTask.cancel()

        let executionTime = Date().timeIntervalSince(startTime)

        // Read output
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""

        let success = process.terminationStatus == 0

        return CommandExecutionResult(
            success: success,
            output: success ? output : nil,
            error: success ? nil : (error.isEmpty ? "Command failed" : error),
            executionTime: executionTime
        )
    }

    /// Execute command with streaming output
    func executeStreaming(
        command: String,
        arguments: [String] = []
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                    process.arguments = [command] + arguments

                    let outputPipe = Pipe()
                    process.standardOutput = outputPipe

                    try process.run()

                    // Read output line by line
                    for try await line in outputPipe.fileHandleForReading.bytes.lines {
                        continuation.yield(line)
                    }

                    process.waitUntilExit()
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Command Execution Result

struct CommandExecutionResult {
    let success: Bool
    let output: String?
    let error: String?
    let executionTime: TimeInterval?
}
#endif
