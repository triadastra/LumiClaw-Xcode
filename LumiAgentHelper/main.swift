//
//  main.swift
//  LumiAgentHelper
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Privileged helper tool for executing sudo commands via XPC
//

import Foundation
import Logging

// MARK: - Logger Setup

let logger = Logger(label: "com.lumiagent.helper")

// MARK: - Main Entry Point

logger.info("LumiAgentHelper starting...")

let helper = PrivilegedHelper()
helper.run()
