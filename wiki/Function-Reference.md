# Function Reference

This page is auto-generated from the current repository source and includes the latest code updates.

Generated: `2026-02-28 23:32:15`

Regenerate with: `scripts/generate_function_wiki.py`

## Coverage

- Total functions found: **1267**
- Python: **17**
- Swift: **1250**
- Files with functions: **113**

## By File

### `Lumi/App/AppDelegate.swift`

- `L15` `func applicationDidFinishLaunching(_ notification: Notification)`
- `L40` `private func setupGlassWindow(_ window: NSWindow)`
- `L50` `private func setupMenuBar()`
- `L62` `@objc func toggleApp()`
- `L72` `func applicationWillTerminate(_ notification: Notification)`
- `L77` `func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool`

### `Lumi/App/AppState+macOS.swift`

- `L59` `func setupGlobalHotkey()`
- `L125` `func refreshGlobalHotkeys()`
- `L131` `private func runGlobalTextAssist(_ action: TextAssistAction)`
- `L170` `func rewriteText(_ text: String, action: TextAssistAction) async throws -> String`
- `L203` `private func buildFrontmostDocumentContext() async -> String`
- `L234` `private func detectFrontmostDocumentPath() async -> String?`
- `L264` `private func waitForModifiersRelease(timeout: TimeInterval = 0.8) async`
- `L277` `private func captureSelectedText() async -> String?`
- `L314` `private func triggerCopyFromFrontmostApp() async`
- `L336` `private func readStringFromPasteboard(_ pboard: NSPasteboard) -> String?`
- `L353` `private func captureSelectedTextViaAccessibility() -> String?`
- `L370` `private func replaceSelectedText(with text: String) async`
- `L392` `private func sendCommandShortcut(_ keyCode: CGKeyCode)`
- `L404` `private func replaceSelectedTextViaAccessibility(_ replacement: String) -> Bool`
- `L423` `private func resolvedHotkeyTargetAgent() -> Agent?`
- `L428` `private func ensureHotkeyConversation(agentId: UUID) -> UUID`
- `L445` `private func rewriteTextStreaming( _ text: String, action: TextAssistAction, agent: Agent, conversationId: UUID ) async throws -> String`
- `L508` `func toggleCommandPalette()`
- `L514` `func toggleQuickActionPanel()`
- `L520` `func sendQuickAction(type: QuickActionType)`
- `L566` `private func buildQuickActionPrompt(type: QuickActionType) async -> (String, String?)`
- `L579` `private func buildDesktopCleanupPrompt(basePrompt: String) -> String`
- `L613` `private func desktopInventory(at directory: URL, maxItems: Int) -> String`
- `L644` `private func getActiveApplication() -> String`
- `L650` `private func isIWorkApp(bundleId: String) -> Bool`
- `L660` `private func getIWorkDocumentInfo() async -> (info: String, content: String)`
- `L747` `private func buildIWorkContext(app: String, docInfo: String, docContent: String, actionType: QuickActionType) -> String`
- `L840` `func startAutomationEngine()`

### `Lumi/App/AppState.swift`

- `L53` `func isDefaultAgent(_ id: UUID) -> Bool`
- `L57` `func setDefaultAgent(_ id: UUID?)`
- `L111` `init()`
- `L166` `func setRemoteMacBridge( isConnected: Bool, executor: IOSRemoteMacCommandExecutor? )`
- `L177` `func sendCommandPaletteMessage(text: String, agentId: UUID?)`
- `L191` `func createAutomation()`
- `L197` `func runAutomation(id: UUID)`
- `L204` `func fireAutomation(_ rule: AutomationRule)`
- `L215` `private func loadAutomations()`
- `L242` `private func saveAutomations()`
- `L256` `func recordToolCall(agentId: UUID, agentName: String, toolName: String, arguments: [String: String], result: String)`
- `L268` `func stopAgentControl()`
- `L275` `func isConversationResponding(_ conversationId: UUID) -> Bool`
- `L284` `func stopResponse(in conversationId: UUID)`
- `L307` `private func loadAgents()`
- `L318` `func updateAgent(_ agent: Agent)`
- `L334` `func deleteAgent(id: UUID)`
- `L349` `func applySelfUpdate(_ args: [String: String], agentId: UUID) -> String`
- `L381` `private func loadConversations()`
- `L407` `private func saveConversations()`
- `L420` `func createDM(agentId: UUID) -> Conversation`
- `L435` `func createGroup(agentIds: [UUID], title: String?) -> Conversation`
- `L444` `func deleteConversation(id: UUID)`
- `L453` `func sendMessage(_ text: String, in conversationId: UUID, agentMode: Bool = false, desktopControlEnabled: Bool = false)`
- `L497` `func streamResponse( from agent: Agent, in conversationId: UUID, history: [SpaceMessage], agentMode: Bool = false, desktopControlEnabled: Bool = false, delegationDepth: Int = 0, toolNameAllowlist: Set<String>? = nil`
- `L837` `func updatePlaceholder(_ text: String)`
- `L1051` `private func iOSRemoteMacTools(enabledNames: [String]) -> [AITool]`
- `L1190` `private func executeIOSRemoteMacTool( named toolName: String, arguments: [String: String] ) async throws -> String`
- `L1294` `private func shellQuote(_ input: String) -> String`

### `Lumi/App/AutomationEngine.swift`

- `L29` `init(onFire: @escaping (AutomationRule) -> Void)`
- `L35` `func update(rules: [AutomationRule])`
- `L40` `func runManually(_ rule: AutomationRule)`
- `L46` `private func start()`
- `L98` `func stop()`
- `L102` `private func restart()`
- `L110` `private func handleAppEvent(name: String, launched: Bool)`
- `L123` `private func handleScreenUnlock()`
- `L129` `private func handleBluetoothUpdate(_ current: Set<String>)`
- `L148` `private func checkSchedules()`
- `L188` `private func fire(_ rule: AutomationRule)`
- `L196` `nonisolated private static func currentBluetoothDevices() -> Set<String>`
- `L226` `init(onFire: @escaping (AutomationRule) -> Void)`
- `L227` `func update(rules: [AutomationRule])`
- `L228` `func runManually(_ rule: AutomationRule)`
- `L229` `func stop()`

### `Lumi/App/GlobalHotkeyManager.swift`

- `L63` `private init()`
- `L67` `private func ensureEventHandlerInstalled()`
- `L118` `func register(keyCode: UInt32 = KeyCode.L, modifiers: UInt32 = Modifiers.command)`
- `L127` `func registerSecondary(keyCode: UInt32 = KeyCode.L, modifiers: UInt32 = Modifiers.control)`
- `L136` `func registerTertiary(keyCode: UInt32 = KeyCode.L, modifiers: UInt32 = Modifiers.option | Modifiers.command)`
- `L145` `func registerQuaternary(keyCode: UInt32, modifiers: UInt32)`
- `L153` `func registerFifth(keyCode: UInt32, modifiers: UInt32)`
- `L161` `func registerSixth(keyCode: UInt32, modifiers: UInt32)`
- `L168` `func unregister()`
- `L172` `func unregisterAll()`
- `L182` `func unregisterSecondary()`
- `L191` `private init()`
- `L198` `func register(keyCode: UInt32 = 0, modifiers: UInt32 = 0)`
- `L199` `func registerSecondary(keyCode: UInt32 = 0, modifiers: UInt32 = 0)`
- `L200` `func registerTertiary(keyCode: UInt32 = 0, modifiers: UInt32 = 0)`
- `L201` `func registerQuaternary(keyCode: UInt32, modifiers: UInt32)`
- `L202` `func registerFifth(keyCode: UInt32, modifiers: UInt32)`
- `L203` `func registerSixth(keyCode: UInt32, modifiers: UInt32)`
- `L204` `func unregister()`
- `L205` `func unregisterAll()`
- `L206` `func unregisterSecondary()`

### `Lumi/App/KeyboardShortcuts.swift`

- `L114` `private func openLogsDirectory()`

### `Lumi/App/LumiAgentApp.swift`

- `L27` `init()`
- `L61` `private func checkBundleIdentifier()`

### `Lumi/App/LumiServicesProvider.swift`

- `L12` `@objc func extendSelectedText(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L20` `@objc func correctGrammar(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L28` `@objc func autoResolveText(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L36` `@objc func cleanDesktopService(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L48` `private func transformTextFromPasteboard( _ pboard: NSPasteboard, action: AppState.TextAssistAction, error: AutoreleasingUnsafeMutablePointer<NSString> )`

### `Lumi/App/iOSMainView.swift`

- `L166` `private func deleteAgents(at offsets: IndexSet)`
- `L373` `private func deleteConversations(at offsets: IndexSet)`
- `L468` `private func messageRow(for message: SpaceMessage) -> some View`
- `L554` `private func sendMessage()`
- `L561` `private func scrollToBottom(using proxy: ScrollViewProxy, animated: Bool)`
- `L571` `private func throttledStreamingScroll(using proxy: ScrollViewProxy)`
- `L584` `static func == (lhs: iOSMessageBubble, rhs: iOSMessageBubble) -> Bool`
- `L807` `private func saveKey(_ key: String, for provider: AIProvider)`
- `L872` `private func createAgent()`
- `L954` `private func createConversation()`

### `Lumi/Data/DataSources/Remote/AIProviderTypes.swift`

- `L30` `init( role: Role, content: String, toolCallId: String? = nil, toolCalls: [ToolCall]? = nil, imageData: Data? = nil )`
- `L52` `init(name: String, description: String, parameters: AIToolParameters)`
- `L66` `init(type: String = "object", properties: [String: AIToolProperty], required: [String] = [])`
- `L88` `init(type: String, description: String, enumValues: [String]? = nil)`
- `L115` `init(id: String, content: String?, toolCalls: [ToolCall]?, finishReason: String?, usage: AIUsage?)`
- `L131` `init(promptTokens: Int, completionTokens: Int, totalTokens: Int)`
- `L153` `init(id: String, content: String?, toolCallChunk: ToolCallChunk?, finishReason: String?, done: Bool = false)`

### `Lumi/Data/DataSources/System/PrivilegedExecutor.swift`

- `L23` `init()`
- `L27` `deinit`
- `L33` `private func setupXPCConnection()`
- `L43` `func executePrivileged( command: String, arguments: [String] = [] ) async throws -> CommandExecutionResult`
- `L54` `func isHelperInstalled() -> Bool`
- `L61` `func installHelper() async throws`

### `Lumi/Data/DataSources/System/ProcessExecutor.swift`

- `L23` `init(timeout: TimeInterval = 300)`
- `L30` `func execute( command: String, arguments: [String] = [], environment: [String: String]? = nil, workingDirectory: URL? = nil ) async throws -> CommandExecutionResult`
- `L93` `func executeStreaming( command: String, arguments: [String] = [] ) -> AsyncThrowingStream<String, Error>`

### `Lumi/Data/IOSHealthSync.swift`

- `L18` `public init(id: UUID = UUID(), name: String, value: String, unit: String, icon: String, colorName: String, date: Date = Date(), weeklyData: [WeeklyDataPointDTO] = [])`
- `L34` `public init(label: String, value: Double)`
- `L49` `public init()`
- `L68` `private init()`
- `L95` `public func requestAuthorization() async throws`
- `L114` `public func fetchSyncData() async -> HealthSyncData`
- `L144` `public func prefetchAndCacheSync() async`
- `L152` `public func cachedOrPersistedSyncData() -> Data?`
- `L160` `public func updateCachedSyncData(_ data: Data)`
- `L166` `public func exportSyncSnapshotToDocuments() async throws -> URL`
- `L189` `private func refreshAuthorizationState() async`
- `L202` `private func persistSyncData(_ data: Data)`
- `L206` `private func loadPersistedSyncData() -> Data?`
- `L210` `private func syncFileURL() -> URL`
- `L219` `private func loadActivityMetrics() async -> [HealthMetricDTO]`
- `L242` `private func loadHeartMetrics() async -> [HealthMetricDTO]`
- `L265` `private func loadBodyMetrics() async -> [HealthMetricDTO]`
- `L283` `private func loadSleepMetrics() async -> [HealthMetricDTO]`
- `L286` `func fmt(_ minutes: Double) -> String`
- `L300` `private func loadWorkoutMetrics() async -> [HealthMetricDTO]`
- `L311` `private func loadVitalsMetrics() async -> [HealthMetricDTO]`
- `L325` `private func fetchDailySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double?`
- `L337` `private func fetchLatest(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double?`
- `L348` `private func fetchWeeklySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [WeeklyDataPointDTO]`
- `L369` `private func fetchWeeklyAvg(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [WeeklyDataPointDTO]`
- `L390` `private func fetchSleepMinutes() async -> (inBed: Double, asleep: Double, deep: Double, rem: Double)`
- `L415` `private func fetchMindfulMinutes() async -> Double`
- `L428` `private func fetchRecentWorkouts(limit: Int) async -> [HKWorkout]`

### `Lumi/Data/Repositories/AIProviderRepository.swift`

- `L15` `private func udKey(_ provider: AIProvider) -> String`
- `L19` `func setAPIKey(_ key: String, for provider: AIProvider) throws`
- `L23` `func getAPIKey(for provider: AIProvider) throws -> String?`
- `L30` `func sendMessage( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String? = nil, tools: [AITool]? = nil, temperature: Double? = nil, maxTokens: Int? = nil`
- `L68` `func sendMessageStream( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String? = nil, tools: [AITool]? = nil, temperature: Double? = nil, maxTokens: Int? = nil`
- `L104` `func getAvailableModels(provider: AIProvider) async throws -> [String]`
- `L115` `func launchOllama()`
- `L129` `private func openAIMessages(from messages: [AIMessage], systemPrompt: String?) -> [[String: Any]]`
- `L178` `private func ollamaMessages(from messages: [AIMessage], systemPrompt: String?) -> [[String: Any]]`
- `L234` `private func anthropicMessages(from messages: [AIMessage]) -> [[String: Any]]`
- `L290` `private func geminiContents(from messages: [AIMessage]) -> [[String: Any]]`
- `L336` `private func openAIToolDefs(_ tools: [AITool]) -> [[String: Any]]`
- `L344` `private func anthropicToolDefs(_ tools: [AITool]) -> [[String: Any]]`
- `L351` `private func geminiToolDefs(_ tools: [AITool]) -> [[String: Any]]`
- `L363` `private func encodeArgs(_ args: [String: String]) -> String`
- `L369` `private func decodeArgs(_ jsonStr: String) -> [String: String]`
- `L376` `private func toArgStrings(_ dict: [String: Any]) -> [String: String]`
- `L384` `private func sendOpenAIMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, provider: AIProvider = .openai ) async throws -> AIResponse`
- `L426` `private func sendOpenAIStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double?, maxTokens: Int?, provider: AIProvider = .openai ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L474` `private func openAIRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, stream: Bool, provider: AIProvider ) throws -> URLRequest`
- `L519` `private func openAIProviderName(_ provider: AIProvider) -> String`
- `L530` `private func openAIUsage(_ json: [String: Any]) -> AIUsage?`
- `L541` `private func sendAnthropicMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int? ) async throws -> AIResponse`
- `L582` `private func sendAnthropicStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double?, maxTokens: Int? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L636` `private func anthropicRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, stream: Bool ) throws -> URLRequest`
- `L667` `private func anthropicUsage(_ json: [String: Any]) -> AIUsage?`
- `L678` `private func sendGeminiMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int? ) async throws -> AIResponse`
- `L718` `private func sendGeminiStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double?, maxTokens: Int? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L766` `private func geminiRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, stream: Bool ) throws -> URLRequest`
- `L798` `private func geminiUsage(_ json: [String: Any]) -> AIUsage?`
- `L809` `private func sendOllamaMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double? ) async throws -> AIResponse`
- `L858` `private func sendOllamaStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L905` `private func ollamaRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, stream: Bool ) throws -> URLRequest`
- `L924` `private func fetchOllamaModels() async throws -> [String]`
- `L933` `private func ollamaUsage(_ json: [String: Any]) -> AIUsage?`
- `L943` `private func checkHTTP(_ response: URLResponse, data: Data?, provider: String) throws`

### `Lumi/Data/Repositories/AgentRepository.swift`

- `L16` `init(database: DatabaseManager = .shared)`
- `L20` `private func loadCollection() throws -> SyncCollection<Agent>`
- `L32` `func create(_ agent: Agent) async throws`
- `L40` `func update(_ agent: Agent) async throws`
- `L50` `func delete(id: UUID) async throws`
- `L57` `func get(id: UUID) async throws -> Agent?`
- `L62` `func getAll() async throws -> [Agent]`
- `L67` `func getByStatus(_ status: AgentStatus) async throws -> [Agent]`

### `Lumi/Data/Repositories/SessionRepository.swift`

- `L16` `init(database: DatabaseManager = .shared)`
- `L20` `func create(_ session: ExecutionSession) async throws`
- `L27` `func update(_ session: ExecutionSession) async throws`
- `L37` `func get(id: UUID) async throws -> ExecutionSession?`
- `L42` `func getForAgent(agentId: UUID, limit: Int = 50) async throws -> [ExecutionSession]`
- `L51` `func getRecent(limit: Int = 50) async throws -> [ExecutionSession]`

### `Lumi/Domain/Models/Agent.swift`

- `L23` `init( id: UUID = UUID(), name: String, configuration: AgentConfiguration, capabilities: [AgentCapability] = [], status: AgentStatus = .idle, createdAt: Date = Date(), updatedAt: Date = Date()`
- `L76` `init( provider: AIProvider, model: String, systemPrompt: String? = nil, temperature: Double? = 0.7, maxTokens: Int? = 4096, enabledTools: [String] = [], securityPolicy: SecurityPolicy = SecurityPolicy()`
- `L267` `init( allowSudo: Bool = false, requireApproval: Bool = true, whitelistedCommands: [String] = [], blacklistedCommands: [String] = ["rm -rf /", "dd if=/dev/zero", ":()`
- `L295` `static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool`

### `Lumi/Domain/Models/AutomationRule.swift`

- `L82` `func encode(to encoder: Encoder) throws`
- `L116` `init(from decoder: Decoder) throws`
- `L163` `init( id: UUID = UUID(), title: String = "New Automation", notes: String = "", trigger: AutomationTrigger = .manual, agentId: UUID? = nil, isEnabled: Bool = true, createdAt: Date = Date(),`
- `L184` `init(from decoder: Decoder) throws`

### `Lumi/Domain/Models/Conversation.swift`

- `L20` `func displayTitle(agents: [Agent]) -> String`
- `L28` `init( id: UUID = UUID(), title: String? = nil, participantIds: [UUID], messages: [SpaceMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date()`
- `L62` `init( id: UUID = UUID(), role: SpaceMessageRole, content: String, agentId: UUID? = nil, timestamp: Date = Date(), isStreaming: Bool = false, imageData: Data? = nil`

### `Lumi/Domain/Models/ExecutionSession.swift`

- `L23` `init( id: UUID = UUID(), agentId: UUID, userPrompt: String, steps: [ExecutionStep] = [], result: ExecutionResult? = nil, status: ExecutionStatus = .running, startedAt: Date = Date(),`
- `L59` `init( id: UUID = UUID(), type: ExecutionStepType, content: String, timestamp: Date = Date(), metadata: [String: String]? = nil )`
- `L139` `init( success: Bool, output: String? = nil, error: String? = nil, tokensUsed: Int? = nil, costEstimate: Double? = nil )`
- `L163` `init( id: String = UUID().uuidString, name: String, arguments: [String: String], result: ToolResult? = nil )`
- `L185` `init( success: Bool, output: String? = nil, error: String? = nil, executionTime: TimeInterval? = nil )`

### `Lumi/Domain/Models/SyncCollection.swift`

- `L14` `init(items: [T], updatedAt: Date = Date())`

### `Lumi/Domain/Models/ToolCallRecord.swift`

- `L20` `init(agentId: UUID, agentName: String, toolName: String, arguments: [String: String], result: String, success: Bool)`

### `Lumi/Domain/Models/WindowManager.swift`

- `L20` `private init()`
- `L26` `func openQuickActionPanel()`
- `L35` `func openAgentReplyBubble()`
- `L44` `func closeQuickActionPanel()`
- `L51` `func closeAgentReplyBubble()`
- `L59` `private func findWindow(withIdentifier identifier: String) -> NSWindow?`
- `L65` `func openQuickActionPanel()`
- `L66` `func openAgentReplyBubble()`
- `L67` `func closeQuickActionPanel()`
- `L68` `func closeAgentReplyBubble()`

### `Lumi/Domain/Repositories/AIProviderRepositoryProtocol.swift`

- `L14` `func sendMessage( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L25` `func sendMessageStream( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L36` `func getAvailableModels(provider: AIProvider) async throws -> [String] }`

### `Lumi/Domain/Repositories/AgentRepositoryProtocol.swift`

- `L13` `func create(_ agent: Agent) async throws func update(_ agent: Agent) async throws`
- `L14` `func update(_ agent: Agent) async throws func delete(id: UUID) async throws`
- `L15` `func delete(id: UUID) async throws func get(id: UUID) async throws -> Agent? func getAll() async throws -> [Agent] func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L16` `func get(id: UUID) async throws -> Agent? func getAll() async throws -> [Agent] func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L17` `func getAll() async throws -> [Agent] func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L18` `func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L24` `func create(_ session: ExecutionSession) async throws func update(_ session: ExecutionSession) async throws`
- `L25` `func update(_ session: ExecutionSession) async throws func get(id: UUID) async throws -> ExecutionSession? func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] func getRecent(limit: Int) async throws -> [ExecutionSession] }`
- `L26` `func get(id: UUID) async throws -> ExecutionSession? func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] func getRecent(limit: Int) async throws -> [ExecutionSession] }`
- `L27` `func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] func getRecent(limit: Int) async throws -> [ExecutionSession] }`
- `L28` `func getRecent(limit: Int) async throws -> [ExecutionSession] }`

### `Lumi/Domain/Services/AgentExecutionEngine.swift`

- `L36` `init( aiRepository: AIProviderRepositoryProtocol? = nil, sessionRepository: SessionRepositoryProtocol? = nil, authorizationManager: AuthorizationManager? = nil, toolRegistry: ToolRegistry? = nil )`
- `L51` `func execute( agent: Agent, userPrompt: String ) async throws`
- `L101` `func stop() async`
- `L115` `private func executionLoop( agent: Agent, session: ExecutionSession, messages: inout [AIMessage], tools: [AITool] ) async throws`
- `L174` `private func processToolCall( _ toolCall: ToolCall, agent: Agent, session: ExecutionSession, messages: inout [AIMessage] ) async throws`
- `L208` `private func addStep( _ type: ExecutionStepType, content: String ) async`
- `L229` `private func completeSession( success: Bool, error: Error? = nil ) async`
- `L284` `func execute(agent: Agent, userPrompt: String) async throws`
- `L285` `func stop() async`

### `Lumi/Domain/Services/MCPToolHandlers.swift`

- `L17` `private func expandPath(_ path: String) -> String`
- `L24` `static func createDirectory(path: String) async throws -> String`
- `L34` `static func deleteFile(path: String) async throws -> String`
- `L43` `static func moveFile(source: String, destination: String) async throws -> String`
- `L52` `static func copyFile(source: String, destination: String) async throws -> String`
- `L61` `static func searchFiles(directory: String, pattern: String) async throws -> String`
- `L76` `static func getFileInfo(path: String) async throws -> String`
- `L114` `static func appendToFile(path: String, content: String) async throws -> String`
- `L134` `static func getCurrentDatetime() async throws -> String`
- `L141` `static func getSystemInfo() async throws -> String`
- `L170` `static func listRunningProcesses() async throws -> String`
- `L187` `static func openApplication(name: String) async throws -> String`
- `L239` `static func openURL(url: String) async throws -> String`
- `L259` `static func fetchURL(url urlString: String) async throws -> String`
- `L270` `static func httpRequest( url urlString: String, method: String, headers: String?, body: String? ) async throws -> String`
- `L308` `static func webSearch(query: String) async throws -> String`
- `L316` `private static func braveSearch(query: String, apiKey: String) async throws -> String`
- `L341` `private static func duckDuckGoSearch(query: String) async throws -> String`
- `L368` `static func status(directory: String) async throws -> String`
- `L383` `static func log(directory: String, limit: Int) async throws -> String`
- `L398` `static func diff(directory: String, staged: Bool) async throws -> String`
- `L416` `static func commit(directory: String, message: String) async throws -> String`
- `L443` `static func branch(directory: String, create: String?) async throws -> String`
- `L471` `static func clone(url: String, destination: String) async throws -> String`
- `L488` `static func searchInFile(path: String, pattern: String) async throws -> String`
- `L506` `static func replaceInFile(path: String, search: String, replacement: String) async throws -> String`
- `L521` `static func calculate(expression: String) async throws -> String`
- `L535` `static func parseJSON(input: String) async throws -> String`
- `L544` `static func encodeBase64(input: String) async throws -> String`
- `L551` `static func decodeBase64(input: String) async throws -> String`
- `L559` `static func countLines(path: String) async throws -> String`
- `L573` `static func read() async throws -> String`
- `L579` `static func write(content: String) async throws -> String`
- `L590` `static func takeScreenshot(path: String) async throws -> String`
- `L613` `static func runPython(code: String) async throws -> String`
- `L631` `static func runNode(code: String) async throws -> String`
- `L655` `static func save(key: String, value: String) async throws -> String`
- `L660` `static func read(key: String) async throws -> String`
- `L667` `static func list() async throws -> String`
- `L678` `static func delete(key: String) async throws -> String`
- `L693` `static func listDevices() async throws -> String`
- `L707` `static func connectDevice(device: String, action: String) async throws -> String`
- `L729` `static func scanDevices() async throws -> String`
- `L739` `private static func shell(_ cmd: String) async throws -> String`
- `L756` `static func getVolume() async throws -> String`
- `L769` `static func setVolume(level: Int) async throws -> String`
- `L779` `static func setMute(muted: Bool) async throws -> String`
- `L791` `static func listAudioDevices() async throws -> String`
- `L804` `static func setOutputDevice(device: String) async throws -> String`
- `L819` `private static func shell(_ cmd: String) async throws -> String`
- `L837` `static func control(action: String, app: String?) async throws -> String`
- `L879` `private static func shell(_ cmd: String) async throws -> String`
- `L899` `static func getScreenInfo() async throws -> String`
- `L928` `private static func toQuartzPoint(x: Double, y: Double, frame: CGRect) -> CGPoint`
- `L941` `static func moveMouse(x: Double, y: Double) async throws -> String`
- `L950` `static func clickMouse(x: Double, y: Double, button: String, clicks: Int) async throws -> String`
- `L974` `static func scrollMouse(x: Double, y: Double, deltaX: Int, deltaY: Int) async throws -> String`
- `L987` `static func typeText(text: String) async throws -> String`
- `L1002` `static func pressKey(key: String, modifiers: String) async throws -> String`
- `L1031` `static func runAppleScript(script: String) async throws -> String`
- `L1050` `static func iworkWriteText(text: String) async throws -> String`
- `L1066` `static func iworkGetDocumentInfo() async throws -> String`
- `L1110` `static func iworkReplaceText(findText: String, replaceText: String, allOccurrences: Bool = true) async throws -> String`
- `L1148` `static func iworkInsertAfterAnchor(anchorText: String, newText: String) async throws -> String`
- `L1181` `private static func keyNameToCode(_ name: String) -> Int`
- `L1210` `static func readPDF(path: String) async throws -> String`
- `L1235` `static func readWord(path: String) async throws -> String`
- `L1265` `static func readPPT(path: String) async throws -> String`
- `L1344` `static func readDocument(path: String) async throws -> String`
- `L1420` `static func readExcel(path: String) async throws -> String`
- `L1553` `static func readIWork(path: String, ext: String) async throws -> String`
- `L1627` `static func readImageMetadata(path: String) async throws -> String`
- `L1665` `static func analyzeDiskSpace(path: String?) async throws -> String`
- `L1699` `static func listWindows() async throws -> String`
- `L1724` `static func focusWindow(app: String, title: String?) async throws -> String`
- `L1746` `static func resizeWindow(app: String, x: Int?, y: Int?, width: Int?, height: Int?) async throws -> String`
- `L1771` `static func closeWindow(app: String) async throws -> String`
- `L1786` `static func quitApplication(name: String) async throws -> String`
- `L1793` `static func listRunningApps() async throws -> String`
- `L1810` `static func getFrontmostApp() async throws -> String`
- `L1825` `static func sendNotification(title: String, subtitle: String?, message: String) async throws -> String`
- `L1833` `static func setTimer(seconds: Int, message: String) async throws -> String`
- `L1852` `static func getImageInfo(path: String) async throws -> String`
- `L1870` `static func resizeImage(path: String, width: Int?, height: Int?, outputPath: String?) async throws -> String`
- `L1901` `static func convertImage(path: String, format: String, outputPath: String?) async throws -> String`
- `L1936` `static func createArchive(sources: [String], outputPath: String) async throws -> String`
- `L1959` `static func extractArchive(path: String, destination: String?) async throws -> String`
- `L2002` `static func getWifiInfo() async throws -> String`
- `L2019` `static func getNetworkInterfaces() async throws -> String`
- `L2041` `static func pingHost(host: String, count: Int) async throws -> String`
- `L2063` `static func getBrightness() async throws -> String`
- `L2085` `static func setBrightness(level: Double) async throws -> String`
- `L2107` `static func getAppearance() async throws -> String`
- `L2114` `static func setDarkMode(enabled: Bool) async throws -> String`
- `L2121` `static func setWallpaper(path: String) async throws -> String`
- `L2143` `static func moveToTrash(path: String) async throws -> String`
- `L2158` `static func emptyTrash() async throws -> String`
- `L2174` `static func speakText(text: String, voice: String?) async throws -> String`
- `L2193` `static func listVoices() async throws -> String`
- `L2211` `static func getEvents(days: Int) async throws -> String`
- `L2236` `static func createEvent(title: String, startDate: String, endDate: String, calendar: String?, notes: String?) async throws -> String`
- `L2259` `static func getReminders(list: String?) async throws -> String`
- `L2282` `static func createReminder(title: String, dueDate: String?, notes: String?, list: String?) async throws -> String`
- `L2303` `static func hashFile(path: String, algorithm: String) async throws -> String`
- `L2335` `static func spotlightSearch(query: String, directory: String?) async throws -> String`
- `L2361` `static func previewFile(path: String) async throws -> String`
- `L2378` `static func getBatteryInfo() async throws -> String`
- `L2392` `static func getUserInfo() async throws -> String`
- `L2405` `static func listMenuItems(app: String?) async throws -> String`

### `Lumi/Domain/Services/ToolRegistry.swift`

- `L27` `private init()`
- `L34` `func register(_ tool: RegisteredTool)`
- `L39` `func getTool(named name: String) -> RegisteredTool?`
- `L44` `func getAllTools() -> [RegisteredTool]`
- `L49` `func getToolsForAI(enabledNames: [String] = []) -> [AITool]`
- `L61` `func getToolsForAIWithoutDesktopControl(enabledNames: [String] = []) -> [AITool]`
- `L79` `private func registerBuiltInTools()`
- `L2002` `func toAITool() -> AITool`
- `L2105` `static func readFile(path: String) async throws -> String`
- `L2123` `static func writeFile(path: String, content: String) async throws -> String`
- `L2130` `static func listDirectory(path: String) async throws -> String`
- `L2144` `static func executeCommand( command: String, workingDirectory: String? ) async throws -> String`
- `L2226` `private init()`
- `L2227` `func getAllTools() -> [RegisteredTool]`
- `L2228` `func getToolsForAI(enabledNames: [String] = []) -> [AITool]`
- `L2229` `func getToolsForAIWithoutDesktopControl() -> [AITool]`
- `L2230` `func getTool(named name: String) -> RegisteredTool?`

### `Lumi/Infrastructure/Audio/OpenAIVoiceManager.swift`

- `L18` `func startRecording() async throws`
- `L45` `func stopRecordingAndTranscribe() async throws -> String`
- `L71` `func recordAndTranscribeAutomatically( maxDuration: TimeInterval = 18.0, silenceThresholdDB: Float = -42.0, silenceDuration: TimeInterval = 1.2, minimumSpeechDuration: TimeInterval = 0.8 ) async throws -> String`
- `L93` `func speak(text: String) async throws`
- `L113` `private func requestMicrophoneAccessIfNeeded() async throws -> Bool`
- `L131` `private func transcribeAudio(at fileURL: URL) async throws -> String`
- `L161` `private func synthesizeSpeech(from text: String) async throws -> Data`
- `L185` `private func openAIKey() throws -> String`
- `L193` `private func appendField(_ name: String, value: String, to body: inout Data, boundary: String)`
- `L199` `private func appendFile( _ name: String, filename: String, mimeType: String, data: Data, to body: inout Data, boundary: String )`
- `L214` `private func checkHTTP(response: URLResponse, data: Data) throws`
- `L224` `private func waitForAutoStop( maxDuration: TimeInterval, silenceThresholdDB: Float, silenceDuration: TimeInterval, minimumSpeechDuration: TimeInterval ) async throws`
- `L261` `private func transcribeWithRealtimeVAD(maxDuration: TimeInterval) async throws -> String`
- `L377` `private func stopRealtimeCapture()`
- `L385` `private func sendRealtimeEvent(_ event: [String: Any], on socket: URLSessionWebSocketTask) async throws`
- `L393` `private func convertBuffer( _ inputBuffer: AVAudioPCMBuffer, with converter: AVAudioConverter, to outputFormat: AVAudioFormat ) -> AVAudioPCMBuffer?`
- `L421` `private func pcm16Data(from buffer: AVAudioPCMBuffer) -> Data?`
- `L429` `func startRecording() async throws`
- `L430` `func stopRecordingAndTranscribe() async throws -> String`
- `L431` `func recordAndTranscribeAutomatically() async throws -> String`
- `L432` `func speak(text: String) async throws`

### `Lumi/Infrastructure/Database/DatabaseManager.swift`

- `L27` `private init()`
- `L40` `private func fileURL(_ name: String) -> URL`
- `L44` `func load<T: Codable>(_ type: T.Type, from name: String, default defaultValue: @autoclosure () -> T) throws -> T`
- `L55` `func save<T: Codable>(_ value: T, to name: String) throws`
- `L64` `func rawData(for name: String) -> Data?`

### `Lumi/Infrastructure/Network/MacRemoteServer.swift`

- `L61` `private init()`
- `L65` `public func start()`
- `L110` `public func stop()`
- `L124` `public func approveConnection(_ id: UUID)`
- `L139` `public func rejectConnection(_ id: UUID)`
- `L146` `public func connectionHints() -> [String]`
- `L185` `private func handleListenerState(_ state: NWListener.State)`
- `L207` `private func accept(_ connection: NWConnection)`
- `L235` `private func removeConnection(id: UUID)`
- `L246` `private func receiveNext(on connection: NWConnection, bufferBox: BufferBox, id: UUID)`
- `L263` `private func drainBuffer(bufferBox: BufferBox, connection: NWConnection, id: UUID)`
- `L313` `private func updateClientName(id: UUID, name: String)`
- `L335` `private func execute(_ command: RemoteCommandMessage, from connectionID: UUID) async -> RemoteResponseMessage`
- `L650` `private func baseURL() -> URL`
- `L659` `private func latestUpdatedAt(in data: Data) -> Date`
- `L669` `private func latestUpdatedAt(inJSONObject json: Any) -> Date`
- `L690` `private func parseTimestamp(_ raw: Any) -> Date?`
- `L718` `private func runAppleScript(_ source: String) async throws -> String`
- `L736` `private func runShell(_ command: String) async throws -> String`
- `L760` `private func keyCode(for key: String) -> Int`
- `L779` `private func buildModifiers(from modString: String) -> String`
- `L791` `private func encodeResponse(_ response: RemoteResponseMessage) throws -> Data`
- `L799` `private func currentMouseLocation() -> CGPoint`
- `L803` `private func moveMouse(to point: CGPoint) throws`
- `L815` `private func clickMouse(at point: CGPoint, button: CGMouseButton) throws`
- `L826` `private func scrollMouse(deltaX: Int32, deltaY: Int32) throws`
- `L840` `private func exportedSettingsJSON() -> Data`
- `L859` `private func exportedAPIKeysJSON() -> Data`
- `L915` `init(id: UUID, success: Bool, result: String, error: String? = nil, imageData: String? = nil)`

### `Lumi/Infrastructure/Network/NetworkMonitor.swift`

- `L34` `private init()`
- `L41` `private func startMonitoring()`
- `L51` `func stopMonitoring()`

### `Lumi/Infrastructure/Network/USBDeviceObserver.swift`

- `L26` `private init()`
- `L28` `public func start()`
- `L72` `public func stop()`
- `L87` `private func processAddedDevices(_ iterator: io_iterator_t)`
- `L100` `private func processRemovedDevices(_ iterator: io_iterator_t)`
- `L112` `private func isIOSDevice(_ device: io_object_t) -> Bool`

### `Lumi/Infrastructure/ScreenCapture.swift`

- `L19` `nonisolated func captureScreenAsJPEG(maxWidth: CGFloat = 1440, displayID: UInt32? = nil) -> Data?`
- `L58` `func captureWindowAsJPEG(maxWidth: CGFloat = 1440) -> Data?`
- `L115` `func captureScreenAsJPEG(maxWidth: CGFloat = 1440, displayID: UInt32? = nil) -> Data?`

### `Lumi/Infrastructure/Security/AuthorizationManager.swift`

- `L46` `private init()`
- `L51` `func assessRisk( command: String, target: String?, policy: SecurityPolicy ) -> RiskLevel`
- `L100` `func shouldAutoApprove( riskLevel: RiskLevel, policy: SecurityPolicy ) -> Bool`
- `L108` `func validateCommand( _ command: String, policy: SecurityPolicy ) throws`

### `Lumi/Infrastructure/Security/SystemPermissionManager.swift`

- `L21` `private init()`
- `L25` `func refreshAll()`
- `L36` `func checkAccessibility()`
- `L41` `func requestAccessibility()`
- `L49` `func checkScreenRecording()`
- `L53` `func requestScreenRecording()`
- `L60` `func checkFullDiskAccess()`
- `L66` `func requestFullDiskAccess()`
- `L72` `func checkMicrophone()`
- `L76` `func requestMicrophone()`
- `L93` `func checkCamera()`
- `L97` `func requestCamera()`
- `L114` `func checkHelperStatus()`
- `L119` `func installHelper()`
- `L127` `func requestAutomation()`
- `L131` `func requestInputMonitoring()`
- `L135` `func requestFullAccess()`
- `L175` `private func openSystemSettings(path: String)`
- `L180` `private func hasUsageDescription(_ key: String) -> Bool`

### `Lumi/Presentation/Views/Agent/AgentDetailView.swift`

- `L12` `private func formatToolName(_ name: String) -> String`
- `L25` `init(agent: Agent)`
- `L205` `private func uniqueModels(_ models: [String]) -> [String]`
- `L425` `private func fetchModels()`
- `L614` `init(_ label: String, @ViewBuilder content: @escaping () -> Content)`
- `L681` `func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize`
- `L686` `func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ())`
- `L697` `init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat)`

### `Lumi/Presentation/Views/AgentSpace/AgentSpaceView.swift`

- `L17` `private func isRegularConversation(_ conv: Conversation) -> Bool`
- `L283` `private func create()`

### `Lumi/Presentation/Views/AgentSpace/ChatView.swift`

- `L67` `private func chatHeader(conv: Conversation) -> some View`
- `L123` `private func messagesArea(conv: Conversation) -> some View`
- `L152` `private func emptyConversationHint(conv: Conversation) -> some View`
- `L172` `private func sendMessage()`
- `L179` `private func agentFor(_ message: SpaceMessage) -> Agent?`
- `L184` `private func scrollToBottom(conv: Conversation, proxy: ScrollViewProxy)`
- `L191` `private func loadSettings(for conv: Conversation)`
- `L198` `private func saveSettings(for conv: Conversation)`
- `L205` `private func handleVoiceAction()`
- `L219` `private func handleVoicePlayback(for conv: Conversation)`
- `L566` `private func performSend()`
- `L572` `private func updateMentionState()`
- `L581` `private func insertMention(_ agent: Agent)`

### `Lumi/Presentation/Views/Health/HealthView.swift`

- `L95` `private init()`
- `L107` `@objc private func appActivated(_ note: Notification)`
- `L129` `func snapshot() -> (todaySeconds: TimeInterval, topAppName: String?, topAppSeconds: TimeInterval, weekly: [(String, Double)])`
- `L140` `private func bootstrapFrontmostApp()`
- `L150` `private func rotateDayIfNeeded(now: Date)`
- `L164` `private func flushCurrentSegment(until now: Date)`
- `L176` `private func weeklyTotals() -> [(String, Double)]`
- `L188` `private func storedDayStart() -> Date?`
- `L193` `private func loadPersisted()`
- `L200` `private func persist()`
- `L234` `private init()`
- `L269` `func requestAuthorizationIfNeeded() async`
- `L287` `func requestAuthorization() async`
- `L311` `private func authorizationRequestStatus() async -> HKAuthorizationRequestStatus`
- `L321` `func loadAllMetrics() async`
- `L358` `private func mapDTO(_ dto: HealthMetricDTO) -> HealthMetric`
- `L387` `func metricsForCategory(_ category: HealthCategory) -> [HealthMetric]`
- `L400` `private func loadActivityMetrics() async -> [HealthMetric]`
- `L427` `private func loadScreenTimeFallbackMetrics() -> [HealthMetric]`
- `L454` `private func formatDuration(_ seconds: TimeInterval) -> String`
- `L464` `private func loadHeartMetrics() async -> [HealthMetric]`
- `L493` `private func loadBodyMetrics() async -> [HealthMetric]`
- `L515` `private func loadSleepMetrics() async -> [HealthMetric]`
- `L518` `func fmt(_ minutes: Double) -> String`
- `L548` `private func loadWorkoutMetrics() async -> [HealthMetric]`
- `L566` `private func loadVitalsMetrics() async -> [HealthMetric]`
- `L583` `private func fetchDailySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double?`
- `L595` `private func fetchLatest(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double?`
- `L606` `private func fetchWeeklySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [(label: String, value: Double)]`
- `L627` `private func fetchWeeklyAvg(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [(label: String, value: Double)]`
- `L648` `private func fetchSleepMinutes() async -> (inBed: Double, asleep: Double, deep: Double, rem: Double)`
- `L682` `private func fetchMindfulMinutes() async -> Double`
- `L695` `private func fetchRecentWorkouts(limit: Int) async -> [HKWorkout]`
- `L707` `func analyzeCategory(_ category: HealthCategory, agent: Agent?) async`

### `Lumi/Presentation/Views/Health/IOSHealthDashboardView.swift`

- `L27` `func metrics(for category: HealthCategory) -> [HealthMetric]`
- `L44` `func load(notifySync: Bool = false) async`
- `L68` `func requestAuthorization() async`
- `L79` `func exportJSONSnapshot() async`
- `L92` `func analyze(category: HealthCategory, preferredAgent: Agent?) async`
- `L156` `private func resolveProviderAndModel(repo: AIProviderRepository, preferredAgent: Agent?) async throws -> (AIProvider, String)`
- `L186` `private func mapDTO(_ dto: HealthMetricDTO) -> HealthMetric`

### `Lumi/Presentation/Views/Main/CommandPaletteController.swift`

- `L34` `func show(agents: [Agent], appState: AppState, onSubmit: @escaping (_ text: String, _ agentId: UUID?) -> Void)`
- `L106` `func hide()`
- `L112` `func toggle(agents: [Agent], appState: AppState, onSubmit: @escaping (_ text: String, _ agentId: UUID?) -> Void)`
- `L261` `private func submit()`

### `Lumi/Presentation/Views/Main/HotkeyToastOverlay.swift`

- `L16` `func show(message: String)`
- `L35` `private func createPanel(message: String)`
- `L68` `private func update(message: String)`
- `L79` `private func hide()`
- `L92` `private func measuredSize(for view: HotkeyToastView) -> NSSize`
- `L108` `private func position(panel: NSPanel, size: NSSize)`

### `Lumi/Presentation/Views/Main/MainWindow.swift`

- `L20` `func makeNSView(context: Context) -> NSVisualEffectView`
- `L28` `func updateNSView(_ nsView: NSVisualEffectView, context: Context)`
- `L122` `func executeCurrentAgent() async`
- `L897` `private func syncUIFromTrigger()`
- `L922` `private func syncTriggerFromUI()`
- `L1003` `private func uniqueModels(_ models: [String]) -> [String]`
- `L1126` `private func fetchModels()`
- `L1160` `private func createAgent()`

### `Lumi/Presentation/Views/Main/QuickActionPanelController.swift`

- `L27` `func isIWorkApp() -> Bool`
- `L102` `func show(onAction: @escaping (QuickActionType) -> Void)`
- `L108` `func hide()`
- `L120` `func toggle(onAction: @escaping (QuickActionType) -> Void)`
- `L128` `func triggerAction(_ type: QuickActionType)`
- `L133` `private func createPanel()`
- `L189` `func addToolCall(_ toolName: String, args: [String: String])`
- `L208` `func show(initialText: String = "")`
- `L213` `func hide()`
- `L226` `func updateText(_ text: String)`
- `L233` `func addToolCall(_ toolName: String, args: [String: String])`
- `L238` `func setConversationId(_ id: UUID)`
- `L244` `func prepareForNewResponse()`
- `L252` `private func resizePanel()`
- `L272` `private func calculateContentHeight() -> CGFloat`
- `L281` `private func createPanel(initialText: String)`
- `L541` `private func sendUserInput()`
- `L547` `private func handleVoiceTap()`

### `Lumi/Presentation/Views/Main/ScreenControlOverlay.swift`

- `L24` `func show(onStop: @escaping () -> Void)`
- `L31` `func hide()`
- `L40` `private func createPanel(onStop: @escaping () -> Void)`

### `Lumi/Presentation/Views/Remote/IOSRealRemoteView.swift`

- `L32` `static func == (lhs: IOSRemoteDevice, rhs: IOSRemoteDevice) -> Bool`
- `L42` `init(type: String, parameters: [String: String] = [:])`
- `L58` `static func encode<T: Encodable>(_ value: T) throws -> Data`
- `L66` `static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T`
- `L80` `func start()`
- `L133` `func stop()`
- `L152` `func connect(to endpoint: NWEndpoint) async throws`
- `L179` `private func handleStateUpdate(_ state: NWConnection.State)`
- `L207` `private func handleTimeout()`
- `L221` `func connect(host: String, port: UInt16 = 47285) async throws`
- `L229` `func disconnect()`
- `L236` `func send(_ type: String, parameters: [String: String] = [:], timeout: TimeInterval = 15) async throws -> IOSRemoteResponse`
- `L263` `private func receiveLoop()`
- `L286` `private func drainBuffer()`
- `L335` `private func cancelPending(with error: Error)`
- `L372` `init()`
- `L402` `deinit`
- `L410` `func start()`
- `L411` `func stop()`
- `L413` `func connect(_ device: IOSRemoteDevice)`
- `L435` `func connectDirect()`
- `L465` `private func awaitApproval() async throws`
- `L496` `func disconnect()`
- `L503` `func ping()`
- `L507` `func screenshot()`
- `L511` `func setVolume(_ percent: Int)`
- `L515` `func runShell()`
- `L522` `func syncNow()`
- `L530` `private func syncBidirectional(showProgress: Bool) async`
- `L586` `func step(_ detail: String? = nil)`
- `L681` `private func beginRemoteSession()`
- `L695` `private func endRemoteSession()`
- `L704` `private func startContinuousSyncLoop()`
- `L716` `private func scheduleLocalChangeSync()`
- `L726` `private func shouldSkipPull(for file: String) -> Bool`
- `L736` `private func maxTimestamp(in data: Data) -> Date`
- `L746` `private func maxTimestamp(in json: Any) -> Date`
- `L767` `private func parseDateValue(_ raw: Any) -> Date?`
- `L781` `private func applyPulledData(_ data: Data, for file: String) async throws`
- `L803` `private func localSyncData(for file: String) -> Data?`
- `L825` `private func friendlyFileName(_ file: String) -> String`
- `L837` `private func localBaseURL() -> URL`
- `L845` `private func applySettingsFromJSON(_ data: Data)`
- `L852` `private func applyAPIKeysFromJSON(_ data: Data)`
- `L859` `private func exportedSettingsJSON() -> Data`
- `L878` `private func exportedAPIKeysJSON() -> Data`
- `L891` `private func run(_ type: String, parameters: [String: String] = [:], timeout: TimeInterval = 15)`

### `Lumi/Presentation/Views/Settings/SettingsView.swift`

- `L71` `private func sectionView(_ section: SettingsSection) -> some View`
- `L393` `private func loadSystemAccount()`
- `L542` `private func apiKeySection( provider: AIProvider, icon: String, color: Color, title: String, placeholder: String, key: Binding<String> ) -> some View`
- `L586` `private func loadKeyStatus()`
- `L595` `private func save(_ key: String, for provider: AIProvider)`
- `L700` `private func checkStatus()`

### `LumiAgentHelper/PrivilegedHelper.swift`

- `L19` `func run()`
- `L32` `func executeCommand( _ command: String, withAuthorization: Data ) throws -> String`

### `Tests/LumiAgentTests/AgentExecutionEngineTests.swift`

- `L16` `override func setUp() async throws`
- `L27` `func testEngineInitialization()`
- `L33` `func testExecutionWithSimplePrompt() async throws`
- `L58` `private func createTestAgent() -> Agent`
- `L75` `func sendMessage( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L96` `func sendMessageStream( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L110` `func getAvailableModels(provider: AIProvider) async throws -> [String]`
- `L120` `func create(_ session: ExecutionSession) async throws`
- `L124` `func update(_ session: ExecutionSession) async throws`
- `L130` `func get(id: UUID) async throws -> ExecutionSession?`
- `L134` `func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession]`
- `L138` `func getRecent(limit: Int) async throws -> [ExecutionSession]`

### `Tests/LumiAgentTests/AuthorizationManagerTests.swift`

- `L14` `override func setUp()`
- `L18` `func testRiskAssessmentForDangerousCommand()`
- `L29` `func testRiskAssessmentForSudoCommand()`
- `L40` `func testRiskAssessmentForSafePath()`
- `L51` `func testRiskAssessmentForSensitivePath()`
- `L62` `func testCommandValidationWithBlacklist()`
- `L72` `func testCommandValidationWithoutSudo()`
- `L87` `func testAutoApproveThreshold()`

### `legacy/LumiAgent/App/AppDelegate.swift`

- `L15` `func applicationDidFinishLaunching(_ notification: Notification)`
- `L36` `private func setupMenuBar()`
- `L48` `@objc func toggleApp()`
- `L58` `func applicationWillTerminate(_ notification: Notification)`
- `L63` `func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool`

### `legacy/LumiAgent/App/AutomationEngine.swift`

- `L28` `init(onFire: @escaping (AutomationRule) -> Void)`
- `L32` `deinit`
- `L36` `func update(rules: [AutomationRule])`
- `L41` `func runManually(_ rule: AutomationRule)`
- `L47` `private func start()`
- `L87` `func stop()`
- `L95` `private func restart()`
- `L103` `private func handleAppEvent(name: String, launched: Bool)`
- `L116` `private func handleScreenUnlock()`
- `L122` `private func pollBluetooth()`
- `L142` `private func checkSchedules()`
- `L182` `private func fire(_ rule: AutomationRule)`
- `L190` `private static func currentBluetoothDevices() -> Set<String>`

### `legacy/LumiAgent/App/GlobalHotkeyManager.swift`

- `L63` `private init()`
- `L67` `private func ensureEventHandlerInstalled()`
- `L118` `func register(keyCode: UInt32 = KeyCode.L, modifiers: UInt32 = Modifiers.command)`
- `L127` `func registerSecondary(keyCode: UInt32 = KeyCode.L, modifiers: UInt32 = Modifiers.control)`
- `L136` `func registerTertiary(keyCode: UInt32 = KeyCode.L, modifiers: UInt32 = Modifiers.option | Modifiers.command)`
- `L145` `func registerQuaternary(keyCode: UInt32, modifiers: UInt32)`
- `L153` `func registerFifth(keyCode: UInt32, modifiers: UInt32)`
- `L161` `func registerSixth(keyCode: UInt32, modifiers: UInt32)`
- `L168` `func unregister()`
- `L172` `func unregisterAll()`
- `L182` `func unregisterSecondary()`

### `legacy/LumiAgent/App/KeyboardShortcuts.swift`

- `L114` `private func openLogsDirectory()`

### `legacy/LumiAgent/App/LumiAgentApp.swift`

- `L24` `init()`
- `L32` `private func setupBundleIdentifier()`
- `L101` `private func captureScreenAsJPEG(maxWidth: CGFloat = 1440, displayID: UInt32? = nil) -> Data?`
- `L140` `private func captureWindowAsJPEG(maxWidth: CGFloat = 1440) -> Data?`
- `L197` `private func captureScreenAsJPEG(maxWidth: CGFloat = 1440, displayID: UInt32? = nil) -> Data?`
- `L218` `init(agentId: UUID, agentName: String, toolName: String, arguments: [String: String], result: String, success: Bool)`
- `L249` `func isDefaultAgent(_ id: UUID) -> Bool`
- `L253` `func setDefaultAgent(_ id: UUID?)`
- `L337` `init()`
- `L366` `private func setupGlobalHotkey()`
- `L446` `func refreshGlobalHotkeys()`
- `L450` `private func runGlobalTextAssist(_ action: TextAssistAction)`
- `L490` `func rewriteText(_ text: String, action: TextAssistAction) async throws -> String`
- `L521` `private func buildFrontmostDocumentContext() async -> String`
- `L553` `private func detectFrontmostDocumentPath() async -> String?`
- `L584` `private func waitForModifiersRelease(timeout: TimeInterval = 0.8) async`
- `L599` `private func captureSelectedText() async -> String?`
- `L641` `private func triggerCopyFromFrontmostApp() async`
- `L666` `private func readStringFromPasteboard(_ pboard: NSPasteboard) -> String?`
- `L683` `private func captureSelectedTextViaAccessibility() -> String?`
- `L700` `private func replaceSelectedText(with text: String) async`
- `L725` `private func sendCommandShortcut(_ keyCode: CGKeyCode)`
- `L737` `private func replaceSelectedTextViaAccessibility(_ replacement: String) -> Bool`
- `L754` `private func resolvedHotkeyTargetAgent() -> Agent?`
- `L759` `private func ensureHotkeyConversation(agentId: UUID) -> UUID`
- `L776` `private func rewriteTextStreaming( _ text: String, action: TextAssistAction, agent: Agent, conversationId: UUID ) async throws -> String`
- `L837` `func toggleCommandPalette()`
- `L843` `func toggleQuickActionPanel()`
- `L849` `func sendQuickAction(type: QuickActionType)`
- `L908` `private func buildQuickActionPrompt(type: QuickActionType) async -> (String, String?)`
- `L921` `private func buildDesktopCleanupPrompt(basePrompt: String) -> String`
- `L955` `private func desktopInventory(at directory: URL, maxItems: Int) -> String`
- `L985` `private func getActiveApplication() -> String`
- `L994` `private func isIWorkApp(bundleId: String) -> Bool`
- `L1005` `private func getIWorkDocumentInfo() async -> (info: String, content: String)`
- `L1093` `private func buildIWorkContext(app: String, docInfo: String, docContent: String, actionType: QuickActionType) -> String`
- `L1184` `func sendCommandPaletteMessage(text: String, agentId: UUID?)`
- `L1201` `private func startAutomationEngine()`
- `L1209` `func createAutomation()`
- `L1215` `func runAutomation(id: UUID)`
- `L1222` `private func fireAutomation(_ rule: AutomationRule)`
- `L1234` `private func loadAutomations()`
- `L1240` `private func saveAutomations()`
- `L1245` `func recordToolCall(agentId: UUID, agentName: String, toolName: String, arguments: [String: String], result: String)`
- `L1256` `func stopAgentControl()`
- `L1265` `private func loadAgents()`
- `L1276` `func updateAgent(_ agent: Agent)`
- `L1286` `func deleteAgent(id: UUID)`
- `L1296` `func applySelfUpdate(_ args: [String: String], agentId: UUID) -> String`
- `L1328` `private func loadConversations()`
- `L1334` `private func saveConversations()`
- `L1340` `func createDM(agentId: UUID) -> Conversation`
- `L1355` `func createGroup(agentIds: [UUID], title: String?) -> Conversation`
- `L1363` `func deleteConversation(id: UUID)`
- `L1370` `func sendMessage(_ text: String, in conversationId: UUID, agentMode: Bool = false, desktopControlEnabled: Bool = false)`
- `L1403` `private func streamResponse( from agent: Agent, in conversationId: UUID, history: [SpaceMessage], agentMode: Bool = false, desktopControlEnabled: Bool = false, delegationDepth: Int = 0, toolNameAllowlist: Set<String>? = nil`
- `L1635` `func updatePlaceholder(_ text: String)`

### `legacy/LumiAgent/App/LumiServicesProvider.swift`

- `L12` `@objc func extendSelectedText(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L20` `@objc func correctGrammar(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L28` `@objc func autoResolveText(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L36` `@objc func cleanDesktopService(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>)`
- `L48` `private func transformTextFromPasteboard( _ pboard: NSPasteboard, action: AppState.TextAssistAction, error: AutoreleasingUnsafeMutablePointer<NSString> )`

### `legacy/LumiAgent/App/iOSMainView.swift`

- `L155` `private func deleteAgents(at offsets: IndexSet)`
- `L342` `private func deleteConversations(at offsets: IndexSet)`
- `L435` `private func sendMessage()`
- `L631` `private func saveKey(_ key: String, for provider: AIProvider)`
- `L690` `private func createAgent()`
- `L754` `private func createConversation()`

### `legacy/LumiAgent/Data/DataSources/Remote/AIProviderTypes.swift`

- `L30` `init( role: Role, content: String, toolCallId: String? = nil, toolCalls: [ToolCall]? = nil, imageData: Data? = nil )`
- `L52` `init(name: String, description: String, parameters: AIToolParameters)`
- `L66` `init(type: String = "object", properties: [String: AIToolProperty], required: [String] = [])`
- `L88` `init(type: String, description: String, enumValues: [String]? = nil)`
- `L115` `init(id: String, content: String?, toolCalls: [ToolCall]?, finishReason: String?, usage: AIUsage?)`
- `L131` `init(promptTokens: Int, completionTokens: Int, totalTokens: Int)`
- `L153` `init(id: String, content: String?, toolCallChunk: ToolCallChunk?, finishReason: String?, done: Bool = false)`

### `legacy/LumiAgent/Data/DataSources/System/PrivilegedExecutor.swift`

- `L23` `init()`
- `L27` `deinit`
- `L33` `private func setupXPCConnection()`
- `L43` `func executePrivileged( command: String, arguments: [String] = [] ) async throws -> CommandExecutionResult`
- `L54` `func isHelperInstalled() -> Bool`
- `L61` `func installHelper() async throws`

### `legacy/LumiAgent/Data/DataSources/System/ProcessExecutor.swift`

- `L23` `init(timeout: TimeInterval = 300)`
- `L30` `func execute( command: String, arguments: [String] = [], environment: [String: String]? = nil, workingDirectory: URL? = nil ) async throws -> CommandExecutionResult`
- `L93` `func executeStreaming( command: String, arguments: [String] = [] ) -> AsyncThrowingStream<String, Error>`

### `legacy/LumiAgent/Data/Repositories/AIProviderRepository.swift`

- `L15` `private func udKey(_ provider: AIProvider) -> String`
- `L19` `func setAPIKey(_ key: String, for provider: AIProvider) throws`
- `L23` `func getAPIKey(for provider: AIProvider) throws -> String?`
- `L30` `func sendMessage( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String? = nil, tools: [AITool]? = nil, temperature: Double? = nil, maxTokens: Int? = nil`
- `L58` `func sendMessageStream( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String? = nil, tools: [AITool]? = nil, temperature: Double? = nil, maxTokens: Int? = nil`
- `L85` `func getAvailableModels(provider: AIProvider) async throws -> [String]`
- `L99` `private func openAIMessages(from messages: [AIMessage], systemPrompt: String?) -> [[String: Any]]`
- `L148` `private func anthropicMessages(from messages: [AIMessage]) -> [[String: Any]]`
- `L204` `private func geminiContents(from messages: [AIMessage]) -> [[String: Any]]`
- `L250` `private func openAIToolDefs(_ tools: [AITool]) -> [[String: Any]]`
- `L258` `private func anthropicToolDefs(_ tools: [AITool]) -> [[String: Any]]`
- `L265` `private func geminiToolDefs(_ tools: [AITool]) -> [[String: Any]]`
- `L277` `private func encodeArgs(_ args: [String: String]) -> String`
- `L283` `private func decodeArgs(_ jsonStr: String) -> [String: String]`
- `L290` `private func toArgStrings(_ dict: [String: Any]) -> [String: String]`
- `L298` `private func sendOpenAIMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int? ) async throws -> AIResponse`
- `L339` `private func sendOpenAIStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double?, maxTokens: Int? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L386` `private func openAIRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, stream: Bool ) throws -> URLRequest`
- `L419` `private func openAIUsage(_ json: [String: Any]) -> AIUsage?`
- `L430` `private func sendAnthropicMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int? ) async throws -> AIResponse`
- `L471` `private func sendAnthropicStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double?, maxTokens: Int? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L525` `private func anthropicRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, stream: Bool ) throws -> URLRequest`
- `L556` `private func anthropicUsage(_ json: [String: Any]) -> AIUsage?`
- `L567` `private func sendGeminiMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int? ) async throws -> AIResponse`
- `L607` `private func sendGeminiStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double?, maxTokens: Int? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L655` `private func geminiRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, maxTokens: Int?, stream: Bool ) throws -> URLRequest`
- `L687` `private func geminiUsage(_ json: [String: Any]) -> AIUsage?`
- `L698` `private func sendOllamaMessage( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double? ) async throws -> AIResponse`
- `L747` `private func sendOllamaStream( model: String, messages: [AIMessage], systemPrompt: String?, temperature: Double? ) async throws -> AsyncThrowingStream<AIStreamChunk, Error>`
- `L794` `private func ollamaRequest( model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool], temperature: Double?, stream: Bool ) throws -> URLRequest`
- `L813` `private func fetchOllamaModels() async throws -> [String]`
- `L822` `private func ollamaUsage(_ json: [String: Any]) -> AIUsage?`
- `L832` `private func checkHTTP(_ response: URLResponse, data: Data?, provider: String) throws`

### `legacy/LumiAgent/Data/Repositories/AgentRepository.swift`

- `L16` `init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue)`
- `L20` `func create(_ agent: Agent) async throws`
- `L26` `func update(_ agent: Agent) async throws`
- `L35` `func delete(id: UUID) async throws`
- `L41` `func get(id: UUID) async throws -> Agent?`
- `L47` `func getAll() async throws -> [Agent]`
- `L53` `func getByStatus(_ status: AgentStatus) async throws -> [Agent]`

### `legacy/LumiAgent/Data/Repositories/SessionRepository.swift`

- `L16` `init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue)`
- `L20` `func create(_ session: ExecutionSession) async throws`
- `L26` `func update(_ session: ExecutionSession) async throws`
- `L32` `func get(id: UUID) async throws -> ExecutionSession?`
- `L38` `func getForAgent(agentId: UUID, limit: Int = 50) async throws -> [ExecutionSession]`
- `L48` `func getRecent(limit: Int = 50) async throws -> [ExecutionSession]`

### `legacy/LumiAgent/Domain/Models/Agent.swift`

- `L23` `init( id: UUID = UUID(), name: String, configuration: AgentConfiguration, capabilities: [AgentCapability] = [], status: AgentStatus = .idle, createdAt: Date = Date(), updatedAt: Date = Date()`
- `L65` `init( provider: AIProvider, model: String, systemPrompt: String? = nil, temperature: Double? = 0.7, maxTokens: Int? = 4096, enabledTools: [String] = [], securityPolicy: SecurityPolicy = SecurityPolicy()`
- `L208` `init( allowSudo: Bool = false, requireApproval: Bool = true, whitelistedCommands: [String] = [], blacklistedCommands: [String] = ["rm -rf /", "dd if=/dev/zero", ":()`
- `L236` `static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool`

### `legacy/LumiAgent/Domain/Models/AutomationRule.swift`

- `L82` `func encode(to encoder: Encoder) throws`
- `L116` `init(from decoder: Decoder) throws`
- `L162` `init( id: UUID = UUID(), title: String = "New Automation", notes: String = "", trigger: AutomationTrigger = .manual, agentId: UUID? = nil, isEnabled: Bool = true )`

### `legacy/LumiAgent/Domain/Models/Conversation.swift`

- `L20` `func displayTitle(agents: [Agent]) -> String`
- `L28` `init( id: UUID = UUID(), title: String? = nil, participantIds: [UUID], messages: [SpaceMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date()`
- `L62` `init( id: UUID = UUID(), role: SpaceMessageRole, content: String, agentId: UUID? = nil, timestamp: Date = Date(), isStreaming: Bool = false, imageData: Data? = nil`

### `legacy/LumiAgent/Domain/Models/ExecutionSession.swift`

- `L23` `init( id: UUID = UUID(), agentId: UUID, userPrompt: String, steps: [ExecutionStep] = [], result: ExecutionResult? = nil, status: ExecutionStatus = .running, startedAt: Date = Date(),`
- `L59` `init( id: UUID = UUID(), type: ExecutionStepType, content: String, timestamp: Date = Date(), metadata: [String: String]? = nil )`
- `L139` `init( success: Bool, output: String? = nil, error: String? = nil, tokensUsed: Int? = nil, costEstimate: Double? = nil )`
- `L163` `init( id: String = UUID().uuidString, name: String, arguments: [String: String], result: ToolResult? = nil )`
- `L185` `init( success: Bool, output: String? = nil, error: String? = nil, executionTime: TimeInterval? = nil )`

### `legacy/LumiAgent/Domain/Models/iOSMainView.swift`

- `L234` `private func sendMessage()`
- `L336` `private func createAgent()`
- `L393` `private func createConversation()`

### `legacy/LumiAgent/Domain/Repositories/AIProviderRepositoryProtocol.swift`

- `L14` `func sendMessage( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L25` `func sendMessageStream( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L36` `func getAvailableModels(provider: AIProvider) async throws -> [String] }`

### `legacy/LumiAgent/Domain/Repositories/AgentRepositoryProtocol.swift`

- `L13` `func create(_ agent: Agent) async throws func update(_ agent: Agent) async throws`
- `L14` `func update(_ agent: Agent) async throws func delete(id: UUID) async throws`
- `L15` `func delete(id: UUID) async throws func get(id: UUID) async throws -> Agent? func getAll() async throws -> [Agent] func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L16` `func get(id: UUID) async throws -> Agent? func getAll() async throws -> [Agent] func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L17` `func getAll() async throws -> [Agent] func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L18` `func getByStatus(_ status: AgentStatus) async throws -> [Agent] }`
- `L24` `func create(_ session: ExecutionSession) async throws func update(_ session: ExecutionSession) async throws`
- `L25` `func update(_ session: ExecutionSession) async throws func get(id: UUID) async throws -> ExecutionSession? func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] func getRecent(limit: Int) async throws -> [ExecutionSession] }`
- `L26` `func get(id: UUID) async throws -> ExecutionSession? func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] func getRecent(limit: Int) async throws -> [ExecutionSession] }`
- `L27` `func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession] func getRecent(limit: Int) async throws -> [ExecutionSession] }`
- `L28` `func getRecent(limit: Int) async throws -> [ExecutionSession] }`

### `legacy/LumiAgent/Domain/Services/AgentExecutionEngine.swift`

- `L36` `init( aiRepository: AIProviderRepositoryProtocol = AIProviderRepository(), sessionRepository: SessionRepositoryProtocol = SessionRepository(), authorizationManager: AuthorizationManager = .shared, toolRegistry: ToolRegistry = .shared )`
- `L51` `func execute( agent: Agent, userPrompt: String ) async throws`
- `L101` `func stop() async`
- `L115` `private func executionLoop( agent: Agent, session: ExecutionSession, messages: inout [AIMessage], tools: [AITool] ) async throws`
- `L174` `private func processToolCall( _ toolCall: ToolCall, agent: Agent, session: ExecutionSession, messages: inout [AIMessage] ) async throws`
- `L208` `private func addStep( _ type: ExecutionStepType, content: String ) async`
- `L229` `private func completeSession( success: Bool, error: Error? = nil ) async`

### `legacy/LumiAgent/Domain/Services/MCPToolHandlers.swift`

- `L16` `private func expandPath(_ path: String) -> String`
- `L23` `static func createDirectory(path: String) async throws -> String`
- `L33` `static func deleteFile(path: String) async throws -> String`
- `L42` `static func moveFile(source: String, destination: String) async throws -> String`
- `L51` `static func copyFile(source: String, destination: String) async throws -> String`
- `L60` `static func searchFiles(directory: String, pattern: String) async throws -> String`
- `L75` `static func getFileInfo(path: String) async throws -> String`
- `L113` `static func appendToFile(path: String, content: String) async throws -> String`
- `L133` `static func getCurrentDatetime() async throws -> String`
- `L140` `static func getSystemInfo() async throws -> String`
- `L169` `static func listRunningProcesses() async throws -> String`
- `L186` `static func openApplication(name: String) async throws -> String`
- `L238` `static func openURL(url: String) async throws -> String`
- `L258` `static func fetchURL(url urlString: String) async throws -> String`
- `L269` `static func httpRequest( url urlString: String, method: String, headers: String?, body: String? ) async throws -> String`
- `L307` `static func webSearch(query: String) async throws -> String`
- `L315` `private static func braveSearch(query: String, apiKey: String) async throws -> String`
- `L340` `private static func duckDuckGoSearch(query: String) async throws -> String`
- `L367` `static func status(directory: String) async throws -> String`
- `L382` `static func log(directory: String, limit: Int) async throws -> String`
- `L397` `static func diff(directory: String, staged: Bool) async throws -> String`
- `L415` `static func commit(directory: String, message: String) async throws -> String`
- `L442` `static func branch(directory: String, create: String?) async throws -> String`
- `L470` `static func clone(url: String, destination: String) async throws -> String`
- `L487` `static func searchInFile(path: String, pattern: String) async throws -> String`
- `L505` `static func replaceInFile(path: String, search: String, replacement: String) async throws -> String`
- `L520` `static func calculate(expression: String) async throws -> String`
- `L534` `static func parseJSON(input: String) async throws -> String`
- `L543` `static func encodeBase64(input: String) async throws -> String`
- `L550` `static func decodeBase64(input: String) async throws -> String`
- `L558` `static func countLines(path: String) async throws -> String`
- `L572` `static func read() async throws -> String`
- `L578` `static func write(content: String) async throws -> String`
- `L589` `static func takeScreenshot(path: String) async throws -> String`
- `L612` `static func runPython(code: String) async throws -> String`
- `L630` `static func runNode(code: String) async throws -> String`
- `L654` `static func save(key: String, value: String) async throws -> String`
- `L659` `static func read(key: String) async throws -> String`
- `L666` `static func list() async throws -> String`
- `L677` `static func delete(key: String) async throws -> String`
- `L692` `static func listDevices() async throws -> String`
- `L706` `static func connectDevice(device: String, action: String) async throws -> String`
- `L728` `static func scanDevices() async throws -> String`
- `L738` `private static func shell(_ cmd: String) async throws -> String`
- `L755` `static func getVolume() async throws -> String`
- `L768` `static func setVolume(level: Int) async throws -> String`
- `L778` `static func setMute(muted: Bool) async throws -> String`
- `L790` `static func listAudioDevices() async throws -> String`
- `L803` `static func setOutputDevice(device: String) async throws -> String`
- `L818` `private static func shell(_ cmd: String) async throws -> String`
- `L836` `static func control(action: String, app: String?) async throws -> String`
- `L878` `private static func shell(_ cmd: String) async throws -> String`
- `L898` `static func getScreenInfo() async throws -> String`
- `L927` `private static func toQuartzPoint(x: Double, y: Double, frame: CGRect) -> CGPoint`
- `L940` `static func moveMouse(x: Double, y: Double) async throws -> String`
- `L949` `static func clickMouse(x: Double, y: Double, button: String, clicks: Int) async throws -> String`
- `L973` `static func scrollMouse(x: Double, y: Double, deltaX: Int, deltaY: Int) async throws -> String`
- `L986` `static func typeText(text: String) async throws -> String`
- `L1001` `static func pressKey(key: String, modifiers: String) async throws -> String`
- `L1030` `static func runAppleScript(script: String) async throws -> String`
- `L1049` `static func iworkWriteText(text: String) async throws -> String`
- `L1065` `static func iworkGetDocumentInfo() async throws -> String`
- `L1109` `static func iworkReplaceText(findText: String, replaceText: String, allOccurrences: Bool = true) async throws -> String`
- `L1147` `static func iworkInsertAfterAnchor(anchorText: String, newText: String) async throws -> String`
- `L1180` `private static func keyNameToCode(_ name: String) -> Int`

### `legacy/LumiAgent/Domain/Services/ToolRegistry.swift`

- `L27` `private init()`
- `L34` `func register(_ tool: RegisteredTool)`
- `L39` `func getTool(named name: String) -> RegisteredTool?`
- `L44` `func getAllTools() -> [RegisteredTool]`
- `L49` `func getToolsForAI(enabledNames: [String] = []) -> [AITool]`
- `L61` `func getToolsForAIWithoutDesktopControl(enabledNames: [String] = []) -> [AITool]`
- `L79` `private func registerBuiltInTools()`
- `L1351` `func toAITool() -> AITool`
- `L1421` `static func readFile(path: String) async throws -> String`
- `L1430` `static func writeFile(path: String, content: String) async throws -> String`
- `L1437` `static func listDirectory(path: String) async throws -> String`
- `L1451` `static func executeCommand( command: String, workingDirectory: String? ) async throws -> String`

### `legacy/LumiAgent/Infrastructure/Audio/OpenAIVoiceManager.swift`

- `L17` `func startRecording() async throws`
- `L44` `func stopRecordingAndTranscribe() async throws -> String`
- `L70` `func recordAndTranscribeAutomatically( maxDuration: TimeInterval = 18.0, silenceThresholdDB: Float = -42.0, silenceDuration: TimeInterval = 1.2, minimumSpeechDuration: TimeInterval = 0.8 ) async throws -> String`
- `L92` `func speak(text: String) async throws`
- `L112` `private func requestMicrophoneAccessIfNeeded() async throws -> Bool`
- `L130` `private func transcribeAudio(at fileURL: URL) async throws -> String`
- `L160` `private func synthesizeSpeech(from text: String) async throws -> Data`
- `L184` `private func openAIKey() throws -> String`
- `L192` `private func appendField(_ name: String, value: String, to body: inout Data, boundary: String)`
- `L198` `private func appendFile( _ name: String, filename: String, mimeType: String, data: Data, to body: inout Data, boundary: String )`
- `L213` `private func checkHTTP(response: URLResponse, data: Data) throws`
- `L223` `private func waitForAutoStop( maxDuration: TimeInterval, silenceThresholdDB: Float, silenceDuration: TimeInterval, minimumSpeechDuration: TimeInterval ) async throws`
- `L260` `private func transcribeWithRealtimeVAD(maxDuration: TimeInterval) async throws -> String`
- `L376` `private func stopRealtimeCapture()`
- `L384` `private func sendRealtimeEvent(_ event: [String: Any], on socket: URLSessionWebSocketTask) async throws`
- `L392` `private func convertBuffer( _ inputBuffer: AVAudioPCMBuffer, with converter: AVAudioConverter, to outputFormat: AVAudioFormat ) -> AVAudioPCMBuffer?`
- `L420` `private func pcm16Data(from buffer: AVAudioPCMBuffer) -> Data?`

### `legacy/LumiAgent/Infrastructure/Database/DatabaseManager.swift`

- `L25` `private init()`
- `L31` `private func setupDatabase()`
- `L58` `private func runMigrations() throws`

### `legacy/LumiAgent/Infrastructure/Database/DatabaseModels.swift`

- `L28` `init(row: Row) throws`
- `L57` `func encode(to container: inout PersistenceContainer) throws`
- `L90` `init(row: Row) throws`
- `L119` `func encode(to container: inout PersistenceContainer) throws`

### `legacy/LumiAgent/Infrastructure/Network/MacRemoteServer.swift`

- `L54` `private init()`
- `L58` `public func start()`
- `L96` `public func stop()`
- `L108` `private func handleListenerState(_ state: NWListener.State)`
- `L125` `private func accept(_ connection: NWConnection)`
- `L147` `private func removeConnection(_ connection: NWConnection)`
- `L155` `private func receiveLoop(on connection: NWConnection, buffer: inout Data)`
- `L161` `private func receiveNext(on connection: NWConnection, bufferBox: BufferBox)`
- `L177` `private func drainBuffer(_ data: Data, connection: NWConnection) async`
- `L200` `private func execute(_ command: RemoteCommandMessage) async -> RemoteResponseMessage`
- `L406` `private func runAppleScript(_ source: String) async throws -> String`
- `L424` `private func runShell(_ command: String) async throws -> String`
- `L448` `private func keyCode(for key: String) -> Int`
- `L467` `private func buildModifiers(from modString: String) -> String`
- `L479` `private func encodeResponse(_ response: RemoteResponseMessage) throws -> Data`
- `L514` `init(id: UUID, success: Bool, result: String, error: String? = nil, imageData: String? = nil)`

### `legacy/LumiAgent/Infrastructure/Network/NetworkMonitor.swift`

- `L31` `private init()`
- `L38` `private func startMonitoring()`
- `L48` `func stopMonitoring()`

### `legacy/LumiAgent/Infrastructure/Security/AuthorizationManager.swift`

- `L51` `private init()`
- `L56` `func assessRisk( command: String, target: String?, policy: SecurityPolicy ) -> RiskLevel`
- `L105` `func shouldAutoApprove( riskLevel: RiskLevel, policy: SecurityPolicy ) -> Bool`
- `L113` `func validateCommand( _ command: String, policy: SecurityPolicy ) throws`
- `L142` `private func generateReasoning( command: String, riskLevel: RiskLevel, target: String? ) -> String`
- `L165` `private func generateImpact( command: String, target: String? ) -> String`

### `legacy/LumiAgent/Infrastructure/Security/SystemPermissionManager.swift`

- `L20` `private init()`
- `L24` `func refreshAll()`
- `L35` `func checkAccessibility()`
- `L40` `func requestAccessibility()`
- `L48` `func checkScreenRecording()`
- `L52` `func requestScreenRecording()`
- `L59` `func checkFullDiskAccess()`
- `L65` `func requestFullDiskAccess()`
- `L71` `func checkMicrophone()`
- `L75` `func requestMicrophone()`
- `L91` `func checkCamera()`
- `L95` `func requestCamera()`
- `L111` `func checkHelperStatus()`
- `L116` `func installHelper()`
- `L124` `func requestAutomation()`
- `L128` `func requestInputMonitoring()`
- `L132` `func requestFullAccess()`
- `L172` `private func openSystemSettings(path: String)`
- `L177` `private func hasUsageDescription(_ key: String) -> Bool`

### `legacy/LumiAgent/Presentation/Views/Agent/AgentDetailView.swift`

- `L12` `private func formatToolName(_ name: String) -> String`
- `L25` `init(agent: Agent)`
- `L355` `private func fetchModels()`
- `L531` `init(_ label: String, @ViewBuilder content: @escaping () -> Content)`
- `L598` `func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize`
- `L603` `func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ())`
- `L614` `init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat)`

### `legacy/LumiAgent/Presentation/Views/AgentSpace/AgentSpaceView.swift`

- `L17` `private func isRegularConversation(_ conv: Conversation) -> Bool`
- `L282` `private func create()`

### `legacy/LumiAgent/Presentation/Views/AgentSpace/ChatView.swift`

- `L67` `private func chatHeader(conv: Conversation) -> some View`
- `L123` `private func messagesArea(conv: Conversation) -> some View`
- `L152` `private func emptyConversationHint(conv: Conversation) -> some View`
- `L172` `private func sendMessage()`
- `L179` `private func agentFor(_ message: SpaceMessage) -> Agent?`
- `L184` `private func scrollToBottom(conv: Conversation, proxy: ScrollViewProxy)`
- `L191` `private func loadSettings(for conv: Conversation)`
- `L198` `private func saveSettings(for conv: Conversation)`
- `L205` `private func handleVoiceAction()`
- `L219` `private func handleVoicePlayback(for conv: Conversation)`
- `L688` `private func performSend()`
- `L694` `private func updateMentionState()`
- `L703` `private func insertMention(_ agent: Agent)`

### `legacy/LumiAgent/Presentation/Views/Health/HealthView.swift`

- `L94` `private init()`
- `L106` `@objc private func appActivated(_ note: Notification)`
- `L128` `func snapshot() -> (todaySeconds: TimeInterval, topAppName: String?, topAppSeconds: TimeInterval, weekly: [(String, Double)])`
- `L139` `private func bootstrapFrontmostApp()`
- `L149` `private func rotateDayIfNeeded(now: Date)`
- `L163` `private func flushCurrentSegment(until now: Date)`
- `L175` `private func weeklyTotals() -> [(String, Double)]`
- `L187` `private func storedDayStart() -> Date?`
- `L192` `private func loadPersisted()`
- `L199` `private func persist()`
- `L231` `private init()`
- `L260` `func requestAuthorizationIfNeeded() async`
- `L278` `func requestAuthorization() async`
- `L295` `private func authorizationRequestStatus() async -> HKAuthorizationRequestStatus`
- `L305` `func loadAllMetrics() async`
- `L339` `func metricsForCategory(_ category: HealthCategory) -> [HealthMetric]`
- `L352` `private func loadActivityMetrics() async -> [HealthMetric]`
- `L379` `private func loadScreenTimeFallbackMetrics() -> [HealthMetric]`
- `L406` `private func formatDuration(_ seconds: TimeInterval) -> String`
- `L416` `private func loadHeartMetrics() async -> [HealthMetric]`
- `L445` `private func loadBodyMetrics() async -> [HealthMetric]`
- `L467` `private func loadSleepMetrics() async -> [HealthMetric]`
- `L470` `func fmt(_ minutes: Double) -> String`
- `L500` `private func loadWorkoutMetrics() async -> [HealthMetric]`
- `L518` `private func loadVitalsMetrics() async -> [HealthMetric]`
- `L535` `private func fetchDailySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double?`
- `L547` `private func fetchLatest(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double?`
- `L558` `private func fetchWeeklySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [(label: String, value: Double)]`
- `L579` `private func fetchWeeklyAvg(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [(label: String, value: Double)]`
- `L600` `private func fetchSleepMinutes() async -> (inBed: Double, asleep: Double, deep: Double, rem: Double)`
- `L634` `private func fetchMindfulMinutes() async -> Double`
- `L647` `private func fetchRecentWorkouts(limit: Int) async -> [HKWorkout]`
- `L659` `func analyzeCategory(_ category: HealthCategory, agent: Agent?) async`

### `legacy/LumiAgent/Presentation/Views/Main/CommandPaletteController.swift`

- `L33` `func show(agents: [Agent], appState: AppState, onSubmit: @escaping (_ text: String, _ agentId: UUID?) -> Void)`
- `L105` `func hide()`
- `L111` `func toggle(agents: [Agent], appState: AppState, onSubmit: @escaping (_ text: String, _ agentId: UUID?) -> Void)`
- `L260` `private func submit()`

### `legacy/LumiAgent/Presentation/Views/Main/HotkeyToastOverlay.swift`

- `L15` `func show(message: String)`
- `L34` `private func createPanel(message: String)`
- `L67` `private func update(message: String)`
- `L78` `private func hide()`
- `L89` `private func measuredSize(for view: HotkeyToastView) -> NSSize`
- `L105` `private func position(panel: NSPanel, size: NSSize)`

### `legacy/LumiAgent/Presentation/Views/Main/MainWindow.swift`

- `L70` `func executeCurrentAgent() async`
- `L780` `private func syncUIFromTrigger()`
- `L805` `private func syncTriggerFromUI()`
- `L939` `private func fetchModels()`
- `L955` `private func createAgent()`

### `legacy/LumiAgent/Presentation/Views/Main/QuickActionPanelController.swift`

- `L25` `func isIWorkApp() -> Bool`
- `L102` `func show(onAction: @escaping (QuickActionType) -> Void)`
- `L108` `func hide()`
- `L120` `func toggle(onAction: @escaping (QuickActionType) -> Void)`
- `L128` `func triggerAction(_ type: QuickActionType)`
- `L133` `private func createPanel()`
- `L188` `func addToolCall(_ toolName: String, args: [String: String])`
- `L207` `func show(initialText: String = "")`
- `L212` `func hide()`
- `L225` `func updateText(_ text: String)`
- `L232` `func addToolCall(_ toolName: String, args: [String: String])`
- `L237` `func setConversationId(_ id: UUID)`
- `L243` `func prepareForNewResponse()`
- `L251` `private func resizePanel()`
- `L271` `private func calculateContentHeight() -> CGFloat`
- `L280` `private func createPanel(initialText: String)`
- `L543` `private func sendUserInput()`
- `L549` `private func handleVoiceTap()`

### `legacy/LumiAgent/Presentation/Views/Main/ScreenControlOverlay.swift`

- `L24` `func show(onStop: @escaping () -> Void)`
- `L31` `func hide()`
- `L40` `private func createPanel(onStop: @escaping () -> Void)`

### `legacy/LumiAgent/Presentation/Views/Settings/SettingsView.swift`

- `L310` `private func loadSystemAccount()`
- `L450` `private func apiKeySection( provider: AIProvider, icon: String, color: Color, title: String, placeholder: String, key: Binding<String> ) -> some View`
- `L494` `private func loadKeyStatus()`
- `L503` `private func save(_ key: String, for provider: AIProvider)`

### `legacy/LumiAgent/Presentation/Views/Settings/iOSMainView_FIXED.swift`

- `L237` `private func sendMessage()`
- `L340` `private func createAgent()`
- `L397` `private func createConversation()`

### `legacy/LumiAgentHelper/PrivilegedHelper.swift`

- `L19` `func run()`
- `L32` `func executeCommand( _ command: String, withAuthorization: Data ) throws -> String`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/App/LumiAgentIOSApp.swift`

- `L47` `func application( _ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil ) -> Bool`
- `L60` `func applicationWillResignActive(_ application: UIApplication)`
- `L65` `func applicationDidBecomeActive(_ application: UIApplication)`
- `L69` `private func configureAudioSession()`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Data/Controllers/IOSBrightnessController.swift`

- `L19` `private init()`
- `L25` `public func getBrightness() -> Double`
- `L34` `public func setBrightness(_ level: Double, animated: Bool = true)`
- `L47` `public func increaseBrightness(step: Double = 0.1)`
- `L54` `public func decreaseBrightness(step: Double = 0.1)`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Data/Controllers/IOSMediaController.swift`

- `L51` `private init()`
- `L62` `private func setupAudioSession()`
- `L71` `private func attachVolumeView()`
- `L79` `private func setupNotifications()`
- `L98` `private func startPolling()`
- `L109` `private func refreshNowPlaying()`
- `L125` `private func refreshPlaybackState()`
- `L129` `private func refreshVolume()`
- `L135` `public func play()`
- `L140` `public func pause()`
- `L145` `public func togglePlayPause()`
- `L149` `public func nextTrack()`
- `L156` `public func previousTrack()`
- `L167` `public func stop()`
- `L172` `public func seek(to position: TimeInterval)`
- `L180` `public func setVolume(_ level: Double)`
- `L191` `public func increaseVolume(step: Double = 0.1)`
- `L196` `public func decreaseVolume(step: Double = 0.1)`
- `L200` `deinit`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Data/Controllers/IOSMessagesController.swift`

- `L27` `public init(recipients: [String], body: String = "", subject: String? = nil)`
- `L46` `private init()`
- `L66` `public init(request: MessageComposeRequest, completion: @escaping (MessageComposeResult) -> Void)`
- `L71` `public func makeUIViewController(context: Context) -> MFMessageComposeViewController`
- `L82` `public func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context)`
- `L84` `public func makeCoordinator() -> Coordinator`
- `L90` `init(completion: @escaping (MessageComposeResult) -> Void)`
- `L94` `public func messageComposeViewController( _ controller: MFMessageComposeViewController, didFinishWith result: MFMessageComposeResult )`
- `L116` `public func body(content: Content) -> some View`
- `L148` `func messageComposeSheet(_ request: Binding<MessageComposeRequest?>) -> some View`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Data/Controllers/IOSWeatherController.swift`

- `L45` `private override init()`
- `L54` `public func refresh()`
- `L74` `private func fetchWeather(for location: CLLocation) async`
- `L121` `private func applyResponse(_ response: OpenMeteoResponse)`
- `L139` `public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])`
- `L145` `public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)`
- `L149` `public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Data/Network/BonjourDiscovery.swift`

- `L42` `public init()`
- `L47` `public func startBrowsing()`
- `L84` `public func stopBrowsing()`
- `L92` `private func handleBrowseResults(_ results: [NWBrowser.Result])`
- `L110` `private func friendlyName(from serviceName: String) -> String`
- `L117` `deinit`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Data/Network/MacRemoteClient.swift`

- `L41` `public init()`
- `L45` `public func connect(to device: MacDevice) async throws`
- `L62` `public func disconnect()`
- `L72` `public func send(_ command: RemoteCommand, timeout: TimeInterval = 15) async throws -> RemoteCommandResponse`
- `L104` `private func handleConnectionState( _ nwState: NWConnection.State, continuation: CheckedContinuation<Void, Error>? )`
- `L130` `private func startReceiving()`
- `L134` `private func receiveLoop()`
- `L158` `private func drainBuffer()`
- `L176` `private func handleResponse(_ response: RemoteCommandResponse)`
- `L185` `private func cancelAllPending(with error: Error)`
- `L194` `private func makeTCPParameters() -> NWParameters`
- `L202` `public func setBrightness(_ level: Double) async throws -> RemoteCommandResponse`
- `L207` `public func setVolume(_ level: Double) async throws -> RemoteCommandResponse`
- `L212` `public func setMute(_ muted: Bool) async throws -> RemoteCommandResponse`
- `L217` `public func mediaPlay() async throws -> RemoteCommandResponse`
- `L221` `public func mediaPause() async throws -> RemoteCommandResponse`
- `L225` `public func mediaNext() async throws -> RemoteCommandResponse`
- `L229` `public func mediaPrevious() async throws -> RemoteCommandResponse`
- `L233` `public func mediaGetInfo() async throws -> RemoteCommandResponse`
- `L237` `public func screenshot() async throws -> RemoteCommandResponse`
- `L241` `public func typeText(_ text: String) async throws -> RemoteCommandResponse`
- `L246` `public func pressKey(_ key: String, modifiers: String = "") async throws -> RemoteCommandResponse`
- `L251` `public func openApplication(_ name: String) async throws -> RemoteCommandResponse`
- `L256` `public func runAppleScript(_ script: String) async throws -> RemoteCommandResponse`
- `L261` `public func getSystemInfo() async throws -> RemoteCommandResponse`
- `L265` `public func ping() async throws -> RemoteCommandResponse`
- `L269` `deinit`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Domain/Models/MacDevice.swift`

- `L25` `public init( name: String, serviceName: String, endpoint: NWEndpoint, connectionState: ConnectionState = .discovered )`
- `L75` `public static func == (lhs: MacDevice, rhs: MacDevice) -> Bool`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Domain/Models/RemoteCommand.swift`

- `L19` `public init( commandType: CommandType, parameters: [String: String] = [:] )`
- `L170` `public init( id: UUID, success: Bool, result: String, error: String? = nil, imageData: String? = nil )`
- `L184` `public static func failure(id: UUID, error: String) -> RemoteCommandResponse`
- `L194` `public static func encode<T: Encodable>(_ value: T) throws -> Data`
- `L202` `public static func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Domain/Models/SystemStatus.swift`

- `L49` `public init()`
- `L94` `func weatherInfo(for code: Int, isDay: Bool) -> (description: String, sfSymbol: String)`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Presentation/ViewModels/MacRemoteViewModel.swift`

- `L69` `public init()`
- `L76` `private func bindDiscovery()`
- `L90` `private func bindClient()`
- `L103` `public func startBrowsing()`
- `L107` `public func stopBrowsing()`
- `L113` `public func connect(to device: MacDevice)`
- `L132` `public func disconnect()`
- `L141` `public func refreshRemoteState() async`
- `L151` `private func runCommand(_ block: @escaping () async throws -> RemoteCommandResponse)`
- `L171` `public func setRemoteBrightness(_ level: Double)`
- `L181` `public func setRemoteVolume(_ level: Double)`
- `L189` `public func toggleRemoteMute()`
- `L200` `public func remotePlay()`
- `L206` `public func remotePause()`
- `L212` `public func remoteNext()`
- `L218` `public func remotePrevious()`
- `L225` `public func remoteGetNowPlaying()`
- `L238` `private func parseNowPlaying(_ text: String)`
- `L257` `public func takeRemoteScreenshot()`
- `L270` `public func sendTypeText()`
- `L283` `public func sendOpenApp()`
- `L296` `public func runAppleScript()`
- `L308` `public func runShellCommand()`
- `L325` `public func pressKey(_ key: String, modifiers: String = "")`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Presentation/ViewModels/SystemControlViewModel.swift`

- `L67` `public init()`
- `L77` `private func bindMedia()`
- `L107` `private func bindWeather()`
- `L121` `private func refreshBattery()`
- `L126` `private func setupBatteryNotifications()`
- `L139` `public func refreshBrightness()`
- `L145` `public func togglePlayPause()`
- `L146` `public func nextTrack()`
- `L147` `public func previousTrack()`
- `L149` `public func setVolume(_ level: Double)`
- `L155` `public func refreshWeather()`
- `L161` `public func composeMessage(to recipients: [String], body: String = "")`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Presentation/Views/ContentView.swift`

- `L18` `public init()`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Presentation/Views/Remote/MacRemoteView.swift`

- `L17` `public init()`

### `legacy/LumiAgentIOS/Sources/LumiAgentIOS/Presentation/Views/SystemControl/SystemControlView.swift`

- `L23` `public init()`
- `L156` `func makeUIView(context: Context) -> MPVolumeView`
- `L161` `func updateUIView(_ uiView: MPVolumeView, context: Context)`
- `L247` `private func formatTime(_ t: TimeInterval) -> String`

### `legacy/Tests/LumiAgentTests/AgentExecutionEngineTests.swift`

- `L16` `override func setUp() async throws`
- `L27` `func testEngineInitialization()`
- `L33` `func testExecutionWithSimplePrompt() async throws`
- `L58` `private func createTestAgent() -> Agent`
- `L75` `func sendMessage( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L96` `func sendMessageStream( provider: AIProvider, model: String, messages: [AIMessage], systemPrompt: String?, tools: [AITool]?, temperature: Double?, maxTokens: Int?`
- `L110` `func getAvailableModels(provider: AIProvider) async throws -> [String]`
- `L120` `func create(_ session: ExecutionSession) async throws`
- `L124` `func update(_ session: ExecutionSession) async throws`
- `L130` `func get(id: UUID) async throws -> ExecutionSession?`
- `L134` `func getForAgent(agentId: UUID, limit: Int) async throws -> [ExecutionSession]`
- `L138` `func getRecent(limit: Int) async throws -> [ExecutionSession]`

### `legacy/Tests/LumiAgentTests/AuthorizationManagerTests.swift`

- `L14` `override func setUp()`
- `L18` `func testRiskAssessmentForDangerousCommand()`
- `L29` `func testRiskAssessmentForSudoCommand()`
- `L40` `func testRiskAssessmentForSafePath()`
- `L51` `func testRiskAssessmentForSensitivePath()`
- `L62` `func testCommandValidationWithBlacklist()`
- `L72` `func testCommandValidationWithoutSudo()`
- `L87` `func testAutoApproveThreshold()`

### `legacy/scripts/convert_omniparser_to_coreml.py`

- `L22` `def main() -> None`

### `scripts/convert_omniparser_to_coreml.py`

- `L22` `def main() -> None`

### `scripts/generate_function_wiki.py`

- `L52` `def should_skip(path: Path) -> bool`
- `L59` `def iter_source_files(root: Path) -> Iterable[Path]`
- `L88` `def clean_signature(sig: str) -> str`
- `L97` `def parse_swift(path: Path) -> list[FunctionEntry]`
- `L140` `def parse_python(path: Path) -> list[FunctionEntry]`
- `L176` `def parse_shell(path: Path) -> list[FunctionEntry]`
- `L196` `def parse_file(path: Path) -> list[FunctionEntry]`
- `L204` `def collect_functions() -> list[FunctionEntry]`
- `L214` `def find_changes_in_worktree() -> tuple[dict[str, list[str]], dict[str, list[str]]]`
- `L244` `def is_func_signature(text: str, path: str) -> bool`
- `L261` `def dedupe(values: list[str]) -> list[str]`
- `L274` `def untracked_function_files(entries: list[FunctionEntry]) -> dict[str, list[FunctionEntry]]`
- `L300` `def write_reference(entries: list[FunctionEntry]) -> None`
- `L338` `def write_updates(entries: list[FunctionEntry]) -> None`
- `L397` `def main() -> None`
