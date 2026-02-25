//
//  AuthorizationManager.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Central security gatekeeper for all operations
//

import Foundation

// MARK: - Authorization Manager

/// Risk assessment helper for agent tool calls.
final class AuthorizationManager {
    // MARK: - Singleton

    static let shared = AuthorizationManager()

    // Dangerous commands and patterns
    private let dangerousCommands = [
        "rm -rf /",
        "dd if=/dev/zero",
        ":(){ :|:& };:",  // Fork bomb
        "chmod -R 777",
        "chown -R",
        "mkfs",
        "format",
        "> /dev/sda",
        "mv /* /dev/null"
    ]

    private let sensitivePaths = [
        "/System",
        "/Library",
        "/usr/bin",
        "/usr/sbin",
        "/bin",
        "/sbin",
        "/etc",
        "/var/root"
    ]

    // MARK: - Initialization

    private init() {}

    // MARK: - Risk Assessment

    /// Assess the risk level of a command or operation
    func assessRisk(
        command: String,
        target: String?,
        policy: SecurityPolicy
    ) -> RiskLevel {
        // Check for dangerous commands
        for dangerous in dangerousCommands {
            if command.contains(dangerous) {
                print("[Authorization] Dangerous command detected: \(command)")
                return .critical
            }
        }

        // Check for sudo
        if command.hasPrefix("sudo ") {
            print("[Authorization] Sudo command detected: \(command)")
            return .high
        }

        // Check for sensitive paths
        if let target = target {
            for sensitivePath in sensitivePaths {
                if target.hasPrefix(sensitivePath) {
                    print("[Authorization] Sensitive path access: \(target)")
                    return .high
                }
            }
        }

        // Check for deletion operations
        if command.contains("rm ") || command.contains("delete") {
            return .medium
        }

        // Check for file modifications
        if command.contains("mv ") || command.contains("cp ") || command.contains("chmod ") {
            return .medium
        }

        // Check for network operations
        if command.contains("curl ") || command.contains("wget ") || command.contains("nc ") {
            return .low
        }

        // Default to low risk
        return .low
    }

    /// Check if an operation should be auto-approved based on policy
    func shouldAutoApprove(
        riskLevel: RiskLevel,
        policy: SecurityPolicy
    ) -> Bool {
        return riskLevel <= policy.autoApproveThreshold && policy.requireApproval == false
    }

    /// Validate a command against security policy
    func validateCommand(
        _ command: String,
        policy: SecurityPolicy
    ) throws {
        // Check blacklist
        for blacklisted in policy.blacklistedCommands {
            if command.contains(blacklisted) {
                throw AuthorizationError.commandBlacklisted(command)
            }
        }

        // Check if sudo is allowed
        if command.hasPrefix("sudo ") && !policy.allowSudo {
            throw AuthorizationError.sudoNotAllowed
        }

        // If whitelist exists, command must be in it
        if !policy.whitelistedCommands.isEmpty {
            let commandBase = command.components(separatedBy: " ").first ?? ""
            if !policy.whitelistedCommands.contains(where: { command.starts(with: $0) }) {
                throw AuthorizationError.commandNotWhitelisted(commandBase)
            }
        }

        print("[Authorization] Command validated: \(command)")
    }
}

// MARK: - Authorization Error

enum AuthorizationError: Error, LocalizedError {
    case commandBlacklisted(String)
    case commandNotWhitelisted(String)
    case sudoNotAllowed
    case requestNotFound
    case requestExpired
    case insufficientPrivileges

    var errorDescription: String? {
        switch self {
        case .commandBlacklisted(let cmd):
            return "Command '\(cmd)' is blacklisted for security reasons"
        case .commandNotWhitelisted(let cmd):
            return "Command '\(cmd)' is not in the whitelist"
        case .sudoNotAllowed:
            return "Sudo commands are not allowed by the current security policy"
        case .requestNotFound:
            return "Approval request not found"
        case .requestExpired:
            return "Approval request has expired"
        case .insufficientPrivileges:
            return "Insufficient privileges to perform this operation"
        }
    }
}
