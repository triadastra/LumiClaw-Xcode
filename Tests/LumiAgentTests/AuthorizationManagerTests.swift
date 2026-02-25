//
//  AuthorizationManagerTests.swift
//  LumiAgentTests
//
//  Created by Lumi Agent on 2026-02-18.
//

import XCTest
@testable import LumiAgent

final class AuthorizationManagerTests: XCTestCase {
    var authManager: AuthorizationManager!

    override func setUp() {
        authManager = .shared
    }

    func testRiskAssessmentForDangerousCommand() {
        let policy = AppConfig.defaultSecurityPolicy
        let risk = authManager.assessRisk(
            command: "rm -rf /",
            target: nil,
            policy: policy
        )

        XCTAssertEqual(risk, .critical)
    }

    func testRiskAssessmentForSudoCommand() {
        let policy = AppConfig.defaultSecurityPolicy
        let risk = authManager.assessRisk(
            command: "sudo apt-get install",
            target: nil,
            policy: policy
        )

        XCTAssertEqual(risk, .high)
    }

    func testRiskAssessmentForSafePath() {
        let policy = AppConfig.defaultSecurityPolicy
        let risk = authManager.assessRisk(
            command: "ls",
            target: "/Users/test",
            policy: policy
        )

        XCTAssertEqual(risk, .low)
    }

    func testRiskAssessmentForSensitivePath() {
        let policy = AppConfig.defaultSecurityPolicy
        let risk = authManager.assessRisk(
            command: "cat file.txt",
            target: "/System/Library/CoreServices",
            policy: policy
        )

        XCTAssertEqual(risk, .high)
    }

    func testCommandValidationWithBlacklist() {
        let policy = AppConfig.defaultSecurityPolicy

        XCTAssertThrowsError(
            try authManager.validateCommand("rm -rf /", policy: policy)
        ) { error in
            XCTAssertTrue(error is AuthorizationError)
        }
    }

    func testCommandValidationWithoutSudo() {
        var policy = AppConfig.defaultSecurityPolicy
        policy.allowSudo = false

        XCTAssertThrowsError(
            try authManager.validateCommand("sudo ls", policy: policy)
        ) { error in
            if case AuthorizationError.sudoNotAllowed = error {
                // Expected
            } else {
                XCTFail("Wrong error type")
            }
        }
    }

    func testAutoApproveThreshold() {
        let policy = SecurityPolicy(
            allowSudo: false,
            requireApproval: true,
            autoApproveThreshold: .medium
        )

        XCTAssertTrue(authManager.shouldAutoApprove(
            riskLevel: .low,
            policy: policy
        ))

        XCTAssertTrue(authManager.shouldAutoApprove(
            riskLevel: .medium,
            policy: policy
        ))

        XCTAssertFalse(authManager.shouldAutoApprove(
            riskLevel: .high,
            policy: policy
        ))
    }
}
