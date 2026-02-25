//
//  FocusedValues.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

#if os(macOS)
import SwiftUI

// MARK: - Focused Values

struct ExecutionEngineFocusedValueKey: FocusedValueKey {
    typealias Value = AgentExecutionEngine
}

extension FocusedValues {
    var executionEngine: AgentExecutionEngine? {
        get { self[ExecutionEngineFocusedValueKey.self] }
        set { self[ExecutionEngineFocusedValueKey.self] = newValue }
    }
}
#endif
