//
//  AgentExecutionView.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

#if os(macOS)
import SwiftUI

struct AgentExecutionView: View {
    @EnvironmentObject var executionEngine: AgentExecutionEngine

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Execution Output")
                    .font(.headline)
                Spacer()
                if executionEngine.isExecuting {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // Terminal output
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(alignment: .leading, spacing: 8) {
                        if let session = executionEngine.currentSession {
                            ForEach(session.steps) { step in
                                ExecutionStepRow(step: step)
                                    .id(step.id)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: executionEngine.currentSession?.steps.count) {
                        if let lastStep = executionEngine.currentSession?.steps.last {
                            withAnimation {
                                proxy.scrollTo(lastStep.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(.ultraThinMaterial.opacity(0.5))
            .font(.system(.body, design: .monospaced))
        }
    }
}

struct ExecutionStepRow: View {
    let step: ExecutionStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: step.type.icon)
                .foregroundColor(iconColor)
                .frame(width: 20)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(step.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(step.content)
                    .textSelection(.enabled)
            }

            Spacer()

            // Timestamp
            Text(step.timestamp, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var iconColor: Color {
        switch step.type {
        case .thinking: return .blue
        case .toolCall: return .purple
        case .toolResult: return .green
        case .response: return .primary
        case .error: return .red
        case .approval: return .orange
        }
    }
}
#endif
