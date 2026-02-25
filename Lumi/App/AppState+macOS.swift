//
//  AppState+macOS.swift
//  LumiAgent
//
//  macOS-only AppState methods: global hotkeys, text assist, quick actions,
//  iWork context, and automation engine lifecycle.
//

#if os(macOS)
import AppKit
import Foundation
import Carbon.HIToolbox
import ApplicationServices

extension AppState {

    // MARK: - Text Assist Action

    enum TextAssistAction {
        case extend
        case grammar
        case autoResolve
        case followRequest

        var title: String {
            switch self {
            case .extend: return "Extend"
            case .grammar: return "Grammar Fix"
            case .autoResolve: return "Auto Resolve"
            case .followRequest: return "Do Request"
            }
        }

        var instruction: String {
            switch self {
            case .extend:
                return "Extend and improve this text while preserving tone. Return only the final revised text."
            case .grammar:
                return "Correct grammar, spelling, punctuation, and clarity. Return only the corrected text."
            case .autoResolve:
                return "Resolve obvious wording issues, remove awkward phrasing, and improve readability. Return only the final text."
            case .followRequest:
                return "Treat the selected text as the user's instruction or question. Do what it asks or answer it directly. Return plain text only."
            }
        }

        var systemPrompt: String {
            switch self {
            case .followRequest:
                return "You are a capable assistant. Execute or answer the user's request from selected text. Output plain text only."
            default:
                return "You are a precise writing assistant. Output plain text only."
            }
        }
    }

    // MARK: - Global Hotkey Setup

    func setupGlobalHotkey() {
        guard enableGlobalHotkeys else {
            GlobalHotkeyManager.shared.unregisterAll()
            return
        }

        GlobalHotkeyManager.shared.onActivate = { [weak self] in
            HotkeyToastOverlayController.shared.show(message: "⌘L hotkey ran")
            self?.toggleCommandPalette()
        }
        GlobalHotkeyManager.shared.register(
            keyCode: GlobalHotkeyManager.KeyCode.L,
            modifiers: GlobalHotkeyManager.Modifiers.command
        )

        GlobalHotkeyManager.shared.onActivate2 = { [weak self] in
            HotkeyToastOverlayController.shared.show(message: "⌃L hotkey ran")
            self?.toggleCommandPalette()
        }
        GlobalHotkeyManager.shared.registerSecondary(
            keyCode: GlobalHotkeyManager.KeyCode.L,
            modifiers: GlobalHotkeyManager.Modifiers.control
        )

        GlobalHotkeyManager.shared.onActivate3 = { [weak self] in
            HotkeyToastOverlayController.shared.show(message: "⌥⌘L hotkey ran")
            self?.toggleQuickActionPanel()
        }
        GlobalHotkeyManager.shared.registerTertiary(
            keyCode: GlobalHotkeyManager.KeyCode.L,
            modifiers: GlobalHotkeyManager.Modifiers.option | GlobalHotkeyManager.Modifiers.command
        )

        GlobalHotkeyManager.shared.onActivate4 = { [weak self] in
            HotkeyToastOverlayController.shared.show(message: "⌥⌘E hotkey ran")
            self?.runGlobalTextAssist(.extend)
        }
        GlobalHotkeyManager.shared.registerQuaternary(
            keyCode: GlobalHotkeyManager.KeyCode.E,
            modifiers: GlobalHotkeyManager.Modifiers.option | GlobalHotkeyManager.Modifiers.command
        )

        GlobalHotkeyManager.shared.onActivate5 = { [weak self] in
            HotkeyToastOverlayController.shared.show(message: "⌥⌘G hotkey ran")
            self?.runGlobalTextAssist(.grammar)
        }
        GlobalHotkeyManager.shared.registerFifth(
            keyCode: GlobalHotkeyManager.KeyCode.G,
            modifiers: GlobalHotkeyManager.Modifiers.option | GlobalHotkeyManager.Modifiers.command
        )

        GlobalHotkeyManager.shared.onActivate6 = { [weak self] in
            HotkeyToastOverlayController.shared.show(message: "⌥⌘R hotkey ran")
            self?.runGlobalTextAssist(.followRequest)
        }
        GlobalHotkeyManager.shared.registerSixth(
            keyCode: GlobalHotkeyManager.KeyCode.R,
            modifiers: GlobalHotkeyManager.Modifiers.option | GlobalHotkeyManager.Modifiers.command
        )

        AgentReplyBubbleController.shared.onSend = { [weak self] text, convId in
            AgentReplyBubbleController.shared.prepareForNewResponse()
            self?.sendMessage(text, in: convId, agentMode: true)
        }
    }

    func refreshGlobalHotkeys() {
        setupGlobalHotkey()
    }

    // MARK: - Global Text Assist

    private func runGlobalTextAssist(_ action: TextAssistAction) {
        Task {
            if !AXIsProcessTrusted() {
                HotkeyToastOverlayController.shared.show(message: "Trust Lumi in Settings -> Accessibility")
                print("⚠️ Accessibility access not granted. Global text assist will fail.")
                return
            }

            guard let selectedText = await captureSelectedText(), !selectedText.isEmpty else {
                HotkeyToastOverlayController.shared.show(message: "\(action.title): no selected text")
                print("⚠️ No selected text captured for global text assist.")
                return
            }
            guard let targetAgent = resolvedHotkeyTargetAgent() else {
                HotkeyToastOverlayController.shared.show(message: "\(action.title): no agent")
                return
            }

            let convId = ensureHotkeyConversation(agentId: targetAgent.id)
            do {
                let rewritten = try await rewriteTextStreaming(
                    selectedText,
                    action: action,
                    agent: targetAgent,
                    conversationId: convId
                )
                guard !rewritten.isEmpty else {
                    HotkeyToastOverlayController.shared.show(message: "\(action.title): empty result")
                    return
                }
                await replaceSelectedText(with: rewritten)
                HotkeyToastOverlayController.shared.show(message: "\(action.title): applied")
            } catch {
                HotkeyToastOverlayController.shared.show(message: "\(action.title): failed")
                print("⚠️ Text assist failed: \(error.localizedDescription)")
            }
        }
    }

    func rewriteText(_ text: String, action: TextAssistAction) async throws -> String {
        guard let targetId = defaultExteriorAgentId ?? agents.first?.id,
              let agent = agents.first(where: { $0.id == targetId }) else {
            throw NSError(domain: "LumiAgent", code: 1, userInfo: [NSLocalizedDescriptionKey: "No target agent found."])
        }

        let docContext = await buildFrontmostDocumentContext()
        let prompt = """
        \(action.instruction)

        \(docContext)

        Text:
        \"\"\"
        \(text)
        \"\"\"
        """

        let repo = AIProviderRepository()
        let response = try await repo.sendMessage(
            provider: agent.configuration.provider,
            model: agent.configuration.model,
            messages: [AIMessage(role: .user, content: prompt)],
            systemPrompt: action.systemPrompt,
            tools: [],
            temperature: 0.2,
            maxTokens: 1200
        )
        return (response.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Frontmost Document Context

    private func buildFrontmostDocumentContext() async -> String {
        let bundleId = getActiveApplication()
        let appName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown App"

        if isIWorkApp(bundleId: bundleId) {
            let (docInfo, content) = await getIWorkDocumentInfo()
            let snippet = String(content.prefix(5000))
            return """
            Active app: \(appName) (\(bundleId))
            Active document info: \(docInfo)
            If relevant, align your rewrite style with this document context:
            \(snippet.isEmpty ? "(No readable iWork content found)" : snippet)
            """
        }

        if let localPath = await detectFrontmostDocumentPath(),
           FileManager.default.fileExists(atPath: localPath),
           FileManager.default.isReadableFile(atPath: localPath),
           let content = try? String(contentsOfFile: localPath, encoding: .utf8) {
            let snippet = String(content.prefix(5000))
            return """
            Active app: \(appName) (\(bundleId))
            Active local document: \(localPath)
            Use this context to keep the selected rewrite consistent with the current file:
            \(snippet.isEmpty ? "(File is empty)" : snippet)
            """
        }

        return "Active app: \(appName) (\(bundleId)). No readable local document context was detected."
    }

    private func detectFrontmostDocumentPath() async -> String? {
        let script = """
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
        end tell

        if frontApp is "TextEdit" then
            tell application "TextEdit"
                if (count of documents) > 0 then
                    try
                        return POSIX path of (path of document 1)
                    on error
                        return ""
                    end try
                end if
            end tell
        end if

        return ""
        """

        if let out = try? await ScreenControlTools.runAppleScript(script: script) {
            let path = out.trimmingCharacters(in: .whitespacesAndNewlines)
            if path.hasPrefix("/") { return path }
        }
        return nil
    }

    // MARK: - Text Selection / Replacement

    private func waitForModifiersRelease(timeout: TimeInterval = 0.8) async {
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            let modifiers = CGEventSource.flagsState(.combinedSessionState)
            let isAnyDown = modifiers.contains(.maskCommand) ||
                            modifiers.contains(.maskAlternate) ||
                            modifiers.contains(.maskControl) ||
                            modifiers.contains(.maskShift)
            if !isAnyDown { return }
            try? await Task.sleep(nanoseconds: 40_000_000)
        }
    }

    private func captureSelectedText() async -> String? {
        if let selectedAX = captureSelectedTextViaAccessibility(),
           !selectedAX.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return selectedAX.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        await waitForModifiersRelease()

        let pasteboard = NSPasteboard.general
        let previous = pasteboard.string(forType: .string)
        var selected: String?

        for attempt in 0..<3 {
            let sentinel = "__LUMI_SELECTION_SENTINEL__\(UUID().uuidString)"
            pasteboard.clearContents()
            pasteboard.setString(sentinel, forType: .string)

            await triggerCopyFromFrontmostApp()
            try? await Task.sleep(nanoseconds: UInt64(300_000_000 + (attempt * 150_000_000)))

            let copied = readStringFromPasteboard(pasteboard)?
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if let copied, !copied.isEmpty, copied != sentinel {
                selected = copied
                break
            }
        }

        pasteboard.clearContents()
        if let previous {
            pasteboard.setString(previous, forType: .string)
        }

        return selected
    }

    private func triggerCopyFromFrontmostApp() async {
        sendCommandShortcut(CGKeyCode(kVK_ANSI_C))
        try? await Task.sleep(nanoseconds: 120_000_000)

        _ = try? await ScreenControlTools.runAppleScript(script: """
        tell application "System Events" to keystroke "c" using command down
        """)
        try? await Task.sleep(nanoseconds: 120_000_000)

        _ = try? await ScreenControlTools.runAppleScript(script: """
        tell application "System Events"
            tell first application process whose frontmost is true
                if exists menu bar 1 then
                    try
                        click menu item "Copy" of menu 1 of menu bar item "Edit" of menu bar 1
                    end try
                end if
            end tell
        end tell
        """)
    }

    private func readStringFromPasteboard(_ pboard: NSPasteboard) -> String? {
        if let s = pboard.string(forType: .string), !s.isEmpty { return s }
        if let s = pboard.string(forType: NSPasteboard.PasteboardType("public.utf8-plain-text")), !s.isEmpty { return s }
        if let s = pboard.string(forType: NSPasteboard.PasteboardType("public.utf16-external-plain-text")), !s.isEmpty { return s }

        if let rtfData = pboard.data(forType: .rtf),
           let attr = try? NSAttributedString(
               data: rtfData,
               options: [.documentType: NSAttributedString.DocumentType.rtf],
               documentAttributes: nil
           ) {
            let s = attr.string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !s.isEmpty { return s }
        }
        return nil
    }

    private func captureSelectedTextViaAccessibility() -> String? {
        let system = AXUIElementCreateSystemWide()
        var focusedObj: CFTypeRef?
        guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focusedObj) == .success,
              let focusedObj else {
            return nil
        }
        let focused = focusedObj as! AXUIElement

        var selectedObj: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focused, kAXSelectedTextAttribute as CFString, &selectedObj) == .success,
              let selectedObj else {
            return nil
        }
        return selectedObj as? String
    }

    private func replaceSelectedText(with text: String) async {
        guard !text.isEmpty else { return }

        if replaceSelectedTextViaAccessibility(text) { return }

        await waitForModifiersRelease()

        let pasteboard = NSPasteboard.general
        let previous = pasteboard.string(forType: .string)

        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        sendCommandShortcut(CGKeyCode(kVK_ANSI_V))
        try? await Task.sleep(nanoseconds: 140_000_000)

        if let previous {
            pasteboard.clearContents()
            pasteboard.setString(previous, forType: .string)
        }
    }

    private func sendCommandShortcut(_ keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .combinedSessionState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            return
        }
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }

    private func replaceSelectedTextViaAccessibility(_ replacement: String) -> Bool {
        let system = AXUIElementCreateSystemWide()
        var focusedObj: CFTypeRef?
        guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focusedObj) == .success,
              let focusedObj else {
            return false
        }
        let focused = focusedObj as! AXUIElement

        let result = AXUIElementSetAttributeValue(
            focused,
            kAXSelectedTextAttribute as CFString,
            replacement as CFTypeRef
        )
        return result == .success
    }

    // MARK: - Hotkey Conversation Helpers

    private func resolvedHotkeyTargetAgent() -> Agent? {
        guard let id = defaultExteriorAgentId ?? agents.first?.id else { return nil }
        return agents.first { $0.id == id }
    }

    private func ensureHotkeyConversation(agentId: UUID) -> UUID {
        if let savedId = UUID(uuidString: hotkeyConversationIdString),
           conversations.contains(where: { $0.id == savedId }) {
            return savedId
        }

        if let existing = conversations.first(where: { ($0.title ?? "") == "Hotkey Space" }) {
            hotkeyConversationIdString = existing.id.uuidString
            return existing.id
        }

        let conv = Conversation(title: "Hotkey Space", participantIds: [agentId])
        conversations.insert(conv, at: 0)
        hotkeyConversationIdString = conv.id.uuidString
        return conv.id
    }

    private func rewriteTextStreaming(
        _ text: String,
        action: TextAssistAction,
        agent: Agent,
        conversationId: UUID
    ) async throws -> String {
        guard let convIndex = conversations.firstIndex(where: { $0.id == conversationId }) else {
            throw NSError(domain: "LumiAgent", code: 2, userInfo: [NSLocalizedDescriptionKey: "Hotkey conversation not found"])
        }

        let userDisplay = "Hotkey \(action.title):\n\n\(text)"
        conversations[convIndex].messages.append(SpaceMessage(role: .user, content: userDisplay))
        conversations[convIndex].updatedAt = Date()

        let placeholderId = UUID()
        conversations[convIndex].messages.append(
            SpaceMessage(id: placeholderId, role: .agent, content: "", agentId: agent.id, isStreaming: true)
        )

        let docContext = await buildFrontmostDocumentContext()
        let prompt = """
        \(action.instruction)

        \(docContext)

        Text:
        \"\"\"
        \(text)
        \"\"\"
        """

        let repo = AIProviderRepository()
        let stream = try await repo.sendMessageStream(
            provider: agent.configuration.provider,
            model: agent.configuration.model,
            messages: [AIMessage(role: .user, content: prompt)],
            systemPrompt: action.systemPrompt,
            tools: [],
            temperature: 0.2,
            maxTokens: 1200
        )

        var accumulated = ""
        for try await chunk in stream {
            if let content = chunk.content, !content.isEmpty {
                accumulated += content
                if let ci = conversations.firstIndex(where: { $0.id == conversationId }),
                   let mi = conversations[ci].messages.firstIndex(where: { $0.id == placeholderId }) {
                    conversations[ci].messages[mi].content = accumulated
                }
            }
        }

        if let ci = conversations.firstIndex(where: { $0.id == conversationId }),
           let mi = conversations[ci].messages.firstIndex(where: { $0.id == placeholderId }) {
            conversations[ci].messages[mi].isStreaming = false
            conversations[ci].updatedAt = Date()
        }
        return accumulated.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Command Palette & Quick Actions

    func toggleCommandPalette() {
        CommandPaletteController.shared.toggle(agents: agents, appState: self) { [weak self] text, agentId in
            self?.sendCommandPaletteMessage(text: text, agentId: agentId)
        }
    }

    func toggleQuickActionPanel() {
        QuickActionPanelController.shared.toggle { [weak self] actionType in
            self?.sendQuickAction(type: actionType)
        }
    }

    func sendQuickAction(type: QuickActionType) {
        let targetId = defaultExteriorAgentId ?? agents.first?.id
        guard let targetId, let targetAgent = agents.first(where: { $0.id == targetId }) else {
            print("⚠️ No agents available for quick action")
            return
        }

        Task {
            let convId: UUID
            if let existing = conversations.first(where: { !$0.isGroup && $0.participantIds == [targetAgent.id] }) {
                convId = existing.id
            } else {
                let conv = Conversation(participantIds: [targetAgent.id])
                conversations.insert(conv, at: 0)
                convId = conv.id
            }

            DispatchQueue.main.async {
                AgentReplyBubbleController.shared.show(initialText: "Processing...")
                AgentReplyBubbleController.shared.setConversationId(convId)
            }

            let jpeg: Data? = await Task.detached(priority: .userInitiated) {
                captureScreenAsJPEG(maxWidth: 1440)
            }.value

            let (prompt, _) = await buildQuickActionPrompt(type: type)
            let finalPrompt = type == .cleanDesktop ? buildDesktopCleanupPrompt(basePrompt: prompt) : prompt

            guard let convIndex = conversations.firstIndex(where: { $0.id == convId }) else { return }

            let userMsg = SpaceMessage(role: .user, content: finalPrompt, imageData: jpeg)
            conversations[convIndex].messages.append(userMsg)
            conversations[convIndex].updatedAt = Date()

            let history = conversations[convIndex].messages.filter { !$0.isStreaming }
            let allowlist: Set<String>? = {
                guard type == .cleanDesktop else { return nil }
                return ["list_directory", "get_file_info", "create_directory", "move_file", "copy_file"]
            }()
            await streamResponse(from: targetAgent, in: convId,
                                 history: history, agentMode: true,
                                 toolNameAllowlist: allowlist)
        }
    }

    private func buildQuickActionPrompt(type: QuickActionType) async -> (String, String?) {
        let activeApp = getActiveApplication()

        if isIWorkApp(bundleId: activeApp) {
            let (docInfo, docContent) = await getIWorkDocumentInfo()
            let iworkContext = buildIWorkContext(app: activeApp, docInfo: docInfo, docContent: docContent, actionType: type)
            let enhancedPrompt = type.prompt + "\n\n" + iworkContext
            return (enhancedPrompt, iworkContext)
        }

        return (type.prompt, nil)
    }

    private func buildDesktopCleanupPrompt(basePrompt: String) -> String {
        let desktopURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
        let inventory = desktopInventory(at: desktopURL, maxItems: 250)
        return """
        \(basePrompt)

        ═══ SAFETY MODE: DESKTOP CLEANUP ═══
        Goal: tidy the Desktop safely.

        HARD RULES (DO NOT BREAK):
        1. NEVER delete anything. No destructive operations.
        2. NEVER move directories/folders. Only move loose files.
        3. NEVER modify file contents.
        4. NEVER move files that look like code/project assets:
           - extensions: .swift .xcodeproj .xcworkspace .py .js .ts .tsx .jsx .go .rs .java .kt .c .cpp .h .hpp .rb .php .sh
           - names containing: README, LICENSE, Dockerfile, Makefile, Package.swift, package.json, pyproject.toml, go.mod, Cargo.toml
        5. If uncertain, leave file in place and report.

        Allowed organization pattern:
        - Move loose files into Desktop subfolders such as:
          Images, Documents, PDFs, Archives, Audio, Video, Screenshots, Others
        - Preserve filenames exactly.

        Available tools are restricted by policy for this action.

        Desktop path: \(desktopURL.path)

        Current Desktop inventory:
        \(inventory)

        Return a concise summary of what was moved and what was intentionally left untouched.
        """
    }

    private func desktopInventory(at directory: URL, maxItems: Int) -> String {
        let fm = FileManager.default
        guard let urls = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return "(Could not read Desktop contents)"
        }

        let sorted = urls.sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        let slice = sorted.prefix(maxItems)
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file

        let lines = slice.map { url -> String in
            let vals = try? url.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])
            let isDir = vals?.isDirectory == true
            let sizeText = isDir ? "-" : formatter.string(fromByteCount: Int64(vals?.fileSize ?? 0))
            let dateText = vals?.contentModificationDate?.formatted(date: .abbreviated, time: .shortened) ?? "unknown"
            return "- \(url.lastPathComponent) | \(isDir ? "folder" : "file") | size: \(sizeText) | modified: \(dateText)"
        }

        if sorted.count > maxItems {
            return lines.joined(separator: "\n") + "\n- ... and \(sorted.count - maxItems) more items"
        }
        return lines.isEmpty ? "(Desktop is empty)" : lines.joined(separator: "\n")
    }

    // MARK: - Active Application

    private func getActiveApplication() -> String {
        NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
    }

    // MARK: - iWork Context

    private func isIWorkApp(bundleId: String) -> Bool {
        let iworkBundleIds = [
            "com.apple.iWork.Pages",
            "com.apple.iWork.Numbers",
            "com.apple.iWork.Keynote",
            "com.apple.creativestudio.keynote",
        ]
        return iworkBundleIds.contains(bundleId)
    }

    private func getIWorkDocumentInfo() async -> (info: String, content: String) {
        let infoScript = """
        tell application "System Events"
            set frontmostApp to name of (first application process whose frontmost is true)
        end tell

        if frontmostApp contains "Pages" then
            tell application "Pages"
                if (count of documents) > 0 then
                    set activeDoc to document 1
                    set docName to name of activeDoc
                    return "Document: " & docName
                else
                    return "No active Pages document"
                end if
            end tell
        else if frontmostApp contains "Numbers" then
            tell application "Numbers"
                if (count of documents) > 0 then
                    set activeDoc to document 1
                    set docName to name of activeDoc
                    return "Spreadsheet: " & docName
                else
                    return "No active Numbers document"
                end if
            end tell
        else if frontmostApp contains "Keynote" then
            tell application "Keynote"
                if (count of presentations) > 0 then
                    set activePresentation to presentation 1
                    set docName to name of activePresentation
                    return "Presentation: " & docName
                else
                    return "No active Keynote presentation"
                end if
            end tell
        else
            return "Unknown iWork app"
        end if
        """

        let contentScript = """
        tell application "System Events"
            set frontmostApp to name of (first application process whose frontmost is true)
        end tell

        if frontmostApp contains "Pages" then
            tell application "Pages"
                if (count of documents) > 0 then
                    set activeDoc to document 1
                    set allText to text of activeDoc
                    return allText
                else
                    return "No content"
                end if
            end tell
        else if frontmostApp contains "Numbers" then
            tell application "Numbers"
                if (count of documents) > 0 then
                    set activeDoc to document 1
                    set allText to text of activeDoc
                    return allText
                else
                    return "No content"
                end if
            end tell
        else if frontmostApp contains "Keynote" then
            return "(Keynote presentations cannot be easily extracted as text)"
        else
            return "Unknown content"
        end if
        """

        var info = "Unknown"
        var content = ""

        do {
            info = try await ScreenControlTools.runAppleScript(script: infoScript)
            content = try await ScreenControlTools.runAppleScript(script: contentScript)
        } catch {
            info = "Could not get iWork document info"
            content = ""
        }

        return (info, content)
    }

    private func buildIWorkContext(app: String, docInfo: String, docContent: String, actionType: QuickActionType) -> String {
        let appName = app.contains("Keynote") ? "Keynote" :
                     app.contains("Numbers") ? "Numbers" : "Pages"

        let contentSection = !docContent.isEmpty &&
            docContent != "(Keynote presentations cannot be easily extracted as text)" &&
            docContent != "No content"
            ? """

            ═══ DOCUMENT CONTENT ═══
            \(docContent.prefix(5000))
            \(docContent.count > 5000 ? "\n... (content truncated)" : "")
            """
            : ""

        switch actionType {
        case .analyzePage:
            return """
            You are working with \(appName). \(docInfo)

            ═══ TASK: PROOFREAD AND FIX ═══
            Review the entire document content below for:
            1. TYPOS and spelling errors
            2. GRAMMAR issues and awkward phrasing
            3. WEIRD or out-of-place words that don't fit
            4. FORMATTING inconsistencies
            5. CLARITY improvements

            If you find issues:
            - Use iwork_replace_text to fix typos and grammar
            - Use iwork_write_text to add clarifications or rephrase awkward sections
            - Suggest any other improvements
            \(contentSection)

            IMPORTANT: Be thorough and fix all issues you find.
            """

        case .thinkAndWrite:
            return """
            You are working with \(appName). \(docInfo)

            ═══ TASK: EDIT AND IMPROVE ═══
            Review the document content and:
            1. Identify any typos, grammar errors, or unclear passages.
            2. Fix them or continue the writing as appropriate.
            3. Suggest improvements to clarity and flow.

            ═══ AUTONOMOUS WRITING ═══
            You should be PROACTIVE. If you have a clear idea of what to write or fix:
            - Use `run_applescript` to directly insert or replace text in the active application.
            - For browser-based apps, use JavaScript via AppleScript to manipulate the DOM.
            - For native apps, use System Events to type or paste content.

            TOOLS AVAILABLE:
            - iwork_replace_text / iwork_write_text (if applicable)
            - run_applescript (use for ANY app to type/insert/edit)
            - type_text / press_key (last resort)
            \(contentSection)

            Be proactive and fix issues directly without asking for permission.
            """

        case .writeNew:
            return """
            You are working with \(appName). \(docInfo)

            ═══ TASK: REVIEW AND ENHANCE ═══
            Read the current content and:
            1. Check for any spelling, grammar, or clarity issues
            2. Identify opportunities to enhance or expand the content
            3. Use the iWork tools to make improvements:
               - iwork_replace_text: Fix errors and improve wording
               - iwork_write_text: Add new content
               - iwork_insert_after_anchor: Insert content at specific locations

            Make it the best version possible.
            \(contentSection)

            Fix all issues you find automatically.
            """

        case .cleanDesktop:
            return """
            \(docInfo)

            The user requested Desktop cleanup. Ignore the current document content and focus only on safe Desktop organization.
            Do not edit documents in the active app.
            """
        }
    }

    // MARK: - Automation Engine

    func startAutomationEngine() {
        automationEngine = AutomationEngine { [weak self] rule in
            self?.fireAutomation(rule)
        }
        automationEngine?.update(rules: automations)
    }
}

#endif
