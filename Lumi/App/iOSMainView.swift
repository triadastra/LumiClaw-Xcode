//
//  iOSMainView.swift
//  LumiAgent
//
//  A polished, feature-complete iOS interface for LumiAgent.
//  Acts as a mobile command center for your AI agents and remote Mac control.
//

#if os(iOS)
import SwiftUI

// MARK: - Main Interface

struct iOSMainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. Agents List
            NavigationStack {
                iOSAgentListView()
            }
            .tabItem {
                Label("Agents", systemImage: "cpu")
            }
            .tag(0)
            
            // 2. Chat Space
            NavigationStack {
                iOSConversationsView()
            }
            .tabItem {
                Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(1)
            
            // 3. Remote Control
            NavigationStack {
                iOSRemoteControlView()
            }
            .tabItem {
                Label("Remote", systemImage: "desktopcomputer")
            }
            .tag(2)
            
            // 4. Settings
            NavigationStack {
                iOSSettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(.blue)
    }
}

// MARK: - Agent List

struct iOSAgentListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingNewAgent = false
    @State private var searchText = ""
    
    var filteredAgents: [Agent] {
        if searchText.isEmpty { return appState.agents }
        return appState.agents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            if appState.agents.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "cpu")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("No Agents Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Create an AI agent to start automating tasks or chatting.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Create First Agent") {
                        showingNewAgent = true
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(filteredAgents) { agent in
                        NavigationLink(destination: iOSAgentDetailView(agent: agent)) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(agent.avatarColor)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(agent.name.prefix(1))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(agent.name)
                                        .font(.headline)
                                    Text("\(agent.configuration.provider.rawValue) · \(agent.configuration.model)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if appState.isDefaultAgent(agent.id) {
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteAgents)
                } header: {
                    Text("My Agents")
                } footer: {
                    Text("The starred agent is your primary assistant for shortcuts.")
                }
            }
        }
        .navigationTitle("Lumi Agents")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search agents")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewAgent = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingNewAgent) {
            iOSNewAgentView()
        }
    }
    
    private func deleteAgents(at offsets: IndexSet) {
        for index in offsets {
            let id = filteredAgents[index].id
            appState.deleteAgent(id: id)
        }
    }
}

// MARK: - Agent Detail

struct iOSAgentDetailView: View {
    let agent: Agent
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(agent.avatarColor)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(agent.name.prefix(1))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(agent.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Powered by \(agent.configuration.provider.rawValue)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Settings") {
                LabeledContent("Model", value: agent.configuration.model)
                LabeledContent("Temperature", value: String(format: "%.2f", agent.configuration.temperature ?? 0.7))
                LabeledContent("Primary Agent", value: appState.isDefaultAgent(agent.id) ? "Yes" : "No")
            }
            
            if let prompt = agent.configuration.systemPrompt, !prompt.isEmpty {
                Section("System Prompt") {
                    Text(prompt)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Button {
                    appState.createDM(agentId: agent.id)
                } label: {
                    Label("Message \(agent.name)", systemImage: "message.fill")
                }
                
                Button {
                    if appState.isDefaultAgent(agent.id) {
                        appState.setDefaultAgent(nil)
                    } else {
                        appState.setDefaultAgent(agent.id)
                    }
                } label: {
                    Label(appState.isDefaultAgent(agent.id) ? "Remove as Primary" : "Set as Primary", 
                          systemImage: appState.isDefaultAgent(agent.id) ? "star.slash.fill" : "star.fill")
                }
                .foregroundStyle(appState.isDefaultAgent(agent.id) ? .orange : .blue)
            }
            
            Section {
                Button(role: .destructive) {
                    appState.deleteAgent(id: agent.id)
                    dismiss()
                } label: {
                    Label("Delete Agent", systemImage: "trash")
                }
            }
            
            Section {
                Text("⚠️ Limited Capabilities on iOS")
                    .font(.headline)
                    .foregroundStyle(.orange)
                Text("Advanced tools like terminal commands, local file system mastery, and real-time screen control are only available on macOS. This mobile agent can chat and use web-based research tools.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Platform Constraints")
            }
        }
        .navigationTitle("Agent Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if appState.isDefaultAgent(agent.id) {
                        appState.setDefaultAgent(nil)
                    } else {
                        appState.setDefaultAgent(agent.id)
                    }
                } label: {
                    Image(systemName: appState.isDefaultAgent(agent.id) ? "star.fill" : "star")
                        .foregroundStyle(appState.isDefaultAgent(agent.id) ? .yellow : .blue)
                }
            }
        }
    }
}

// MARK: - Conversations List

struct iOSConversationsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingNewChat = false
    
    var body: some View {
        List {
            if appState.conversations.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    Text("No Conversations")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Start a new chat with one of your agents.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button("Start First Chat") {
                        showingNewChat = true
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(appState.conversations) { conversation in
                    NavigationLink(destination: iOSChatView(conversationId: conversation.id)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(conversation.title ?? "Conversation")
                                    .font(.headline)
                                    .lineLimit(1)
                                Spacer()
                                Text(conversation.updatedAt, style: .time)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            if let lastMsg = conversation.messages.last {
                                Text(lastMsg.content)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteConversations)
            }
        }
        .navigationTitle("Chat Space")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewChat = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showingNewChat) {
            iOSNewConversationView()
        }
    }
    
    private func deleteConversations(at offsets: IndexSet) {
        for index in offsets {
            let id = appState.conversations[index].id
            appState.deleteConversation(id: id)
        }
    }
}

// MARK: - Chat Interface

struct iOSChatView: View {
    let conversationId: UUID
    @EnvironmentObject var appState: AppState
    @State private var inputText = ""
    @Namespace private var bottomID
    
    var conversation: Conversation? {
        appState.conversations.first { $0.id == conversationId }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if let conv = conversation {
                            ForEach(conv.messages) { message in
                                iOSMessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        Color.clear.frame(height: 1).id(bottomID)
                    }
                    .padding()
                }
                .onChange(of: conversation?.messages.count) {
                    withAnimation {
                        proxy.scrollTo(bottomID, anchor: .bottom)
                    }
                }
                .onChange(of: (conversation?.messages.last?.content.count ?? 0)) {
                    // Follow streaming content
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
            
            Divider()
            
            // Input Area
            HStack(alignment: .bottom, spacing: 12) {
                Button {
                    // Future: Add Image attachment for vision
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                
                TextField("Message", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...6)
                
                if !inputText.isEmpty {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.blue)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.background)
        }
        .navigationTitle(conversation?.title ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if appState.isAgentControllingScreen {
                ToolbarItem(placement: .topBarTrailing) {
                    Label("Active on Mac", systemImage: "desktopcomputer")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        appState.sendMessage(text, in: conversationId, agentMode: false)
        inputText = ""
    }
}

struct iOSMessageBubble: View {
    let message: SpaceMessage
    @EnvironmentObject var appState: AppState
    
    var agent: Agent? {
        guard let id = message.agentId else { return nil }
        return appState.agents.first { $0.id == id }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .agent {
                Circle()
                    .fill(agent?.avatarColor ?? .purple)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text(agent?.name.prefix(1) ?? "L")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
            } else {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if message.role == .agent {
                    Text(agent?.name ?? "Lumi Agent")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
                
                Text(message.content)
                    .font(.body)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.role == .user ? Color.blue : Color(uiColor: .secondarySystemBackground))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                if message.isStreaming {
                    HStack(spacing: 4) {
                        Circle().fill(.secondary).frame(width: 4, height: 4)
                        Circle().fill(.secondary).frame(width: 4, height: 4)
                        Circle().fill(.secondary).frame(width: 4, height: 4)
                    }
                    .padding(.leading, 8)
                    .opacity(0.6)
                }
            }
            
            if message.role == .user {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    )
            } else {
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Remote Control

struct iOSRemoteControlView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "desktopcomputer")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    Text("Remote Control")
                        .font(.headline)
                    Text("LumiAgent can discover and control your Mac running the desktop app. Ensure both devices are on the same Wi-Fi.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section("Nearby Devices") {
                HStack {
                    ProgressView().scaleEffect(0.8)
                    Text("Scanning for Macs...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("What can I do?") {
                Label("View Mac Screen", systemImage: "camera.viewfinder")
                Label("Type & Press Keys", systemImage: "keyboard")
                Label("Run Terminal Commands", systemImage: "terminal")
                Label("Execute AppleScript", systemImage: "applescript")
            }
        }
        .navigationTitle("Mac Remote")
    }
}

// MARK: - Settings

struct iOSSettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
            Section("AI Providers") {
                NavigationLink("Configure API Keys") {
                    iOSAPIKeysView()
                }
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(AppConfig.version)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(AppConfig.buildNumber)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Link(destination: URL(string: "https://lumiagent.com")!) {
                    Label("Official Website", systemImage: "safari")
                }
                Link(destination: URL(string: "https://github.com/Lumicake/Agent-Lumi")!) {
                    Label("View on GitHub", systemImage: "link")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct iOSAPIKeysView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("settings.ollamaURL") private var ollamaURL = AppConfig.defaultOllamaURL
    
    @State private var openAIKey = ""
    @State private var anthropicKey = ""
    @State private var geminiKey = ""
    
    var body: some View {
        Form {
            Section("OpenAI") {
                SecureField("sk-...", text: $openAIKey)
                Button("Save OpenAI Key") { saveKey(openAIKey, for: .openai) }
            }
            
            Section("Anthropic") {
                SecureField("sk-ant-...", text: $anthropicKey)
                Button("Save Anthropic Key") { saveKey(anthropicKey, for: .anthropic) }
            }
            
            Section("Google Gemini") {
                SecureField("Key...", text: $geminiKey)
                Button("Save Gemini Key") { saveKey(geminiKey, for: .gemini) }
            }
            
            Section("Ollama (Local AI)") {
                TextField("http://localhost:11434", text: $ollamaURL)
                Text("Ensure your local server is reachable from this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("API Keys")
    }
    
    private func saveKey(_ key: String, for provider: AIProvider) {
        let repo = AIProviderRepository()
        try? repo.setAPIKey(key, for: provider)
    }
}

// MARK: - New Agent / Conversation (Sheets)

struct iOSNewAgentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var provider: AIProvider = .openai
    @State private var model = "gpt-4o"
    @State private var prompt = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Agent Name", text: $name)
                }
                
                Section("AI Provider") {
                    Picker("Provider", selection: $provider) {
                        ForEach(AIProvider.allCases, id: \.self) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .onChange(of: provider) {
                        model = provider.defaultModels.first ?? ""
                    }
                    
                    TextField("Model", text: $model)
                }
                
                Section("Personality") {
                    TextEditor(text: $prompt)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createAgent()
                        dismiss()
                    }
                    .disabled(name.isEmpty || model.isEmpty)
                }
            }
        }
    }
    
    private func createAgent() {
        let agent = Agent(
            name: name,
            configuration: AgentConfiguration(
                provider: provider,
                model: model,
                systemPrompt: prompt.isEmpty ? nil : prompt
            )
        )
        appState.agents.append(agent)
        Task {
            let repo = AgentRepository()
            try? await repo.update(agent)
        }
    }
}

struct iOSNewConversationView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedAgentIds: Set<UUID> = []
    @State private var title = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Group Title (Optional)", text: $title)
                }
                
                Section("Select Agents") {
                    if appState.agents.isEmpty {
                        Text("No agents available. Create one first.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.agents) { agent in
                            Toggle(agent.name, isOn: Binding(
                                get: { selectedAgentIds.contains(agent.id) },
                                set: { isOn in
                                    if isOn { selectedAgentIds.insert(agent.id) }
                                    else { selectedAgentIds.remove(agent.id) }
                                }
                            ))
                        }
                    }
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        createConversation()
                        dismiss()
                    }
                    .disabled(selectedAgentIds.isEmpty)
                }
            }
        }
    }
    
    private func createConversation() {
        let agentIds = Array(selectedAgentIds)
        if agentIds.count == 1 {
            appState.createDM(agentId: agentIds[0])
        } else {
            appState.createGroup(agentIds: agentIds, title: title.isEmpty ? nil : title)
        }
    }
}

#endif
