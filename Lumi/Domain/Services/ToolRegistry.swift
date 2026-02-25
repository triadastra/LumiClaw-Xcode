//
//  ToolRegistry.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Central registry for all available tools
//

#if os(macOS)
import Foundation

// MARK: - Tool Registry

/// Manages available tools and their definitions
final class ToolRegistry {
    // MARK: - Singleton

    static let shared = ToolRegistry()

    // MARK: - Properties

    private var tools: [String: RegisteredTool] = [:]

    // MARK: - Initialization

    private init() {
        registerBuiltInTools()
    }

    // MARK: - Registration

    /// Register a tool
    func register(_ tool: RegisteredTool) {
        tools[tool.name] = tool
    }

    /// Get a tool by name
    func getTool(named name: String) -> RegisteredTool? {
        tools[name]
    }

    /// Get all tools
    func getAllTools() -> [RegisteredTool] {
        Array(tools.values)
    }

    /// Get tools for AI (as AITool format). If enabledNames is empty, returns all tools.
    func getToolsForAI(enabledNames: [String] = []) -> [AITool] {
        let all = tools.values
        if enabledNames.isEmpty {
            return all.map { $0.toAITool() }
        }
        return all
            .filter { enabledNames.contains($0.name) }
            .map { $0.toAITool() }
    }

    /// Get tools for AI excluding desktop control tools.
    /// Allows screenshot and AppleScript but blocks mouse/keyboard/app control.
    func getToolsForAIWithoutDesktopControl(enabledNames: [String] = []) -> [AITool] {
        let desktopControlTools: Set<String> = [
            "click_mouse", "scroll_mouse", "move_mouse",
            "type_text", "press_key", "open_application"
        ]
        let all = tools.values
            .filter { !desktopControlTools.contains($0.name) }

        if enabledNames.isEmpty {
            return all.map { $0.toAITool() }
        }
        return all
            .filter { enabledNames.contains($0.name) }
            .map { $0.toAITool() }
    }

    // MARK: - Built-in Tools

    private func registerBuiltInTools() {

        // MARK: File Operations

        register(RegisteredTool(
            name: "read_file",
            description: "Read the contents of a file at the given path",
            category: .fileOperations,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file to read"
                    )
                ],
                required: ["path"]
            ),
            handler: { args in
                try await FileOperationHandler.readFile(path: args["path"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "write_file",
            description: "Write content to a file, creating it if it doesn't exist",
            category: .fileOperations,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file to write"
                    ),
                    "content": AIToolProperty(
                        type: "string",
                        description: "Content to write to the file"
                    )
                ],
                required: ["path", "content"]
            ),
            handler: { args in
                try await FileOperationHandler.writeFile(
                    path: args["path"] ?? "",
                    content: args["content"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "list_directory",
            description: "List files and directories in a given path",
            category: .fileOperations,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Directory path to list"
                    )
                ],
                required: ["path"]
            ),
            handler: { args in
                try await FileOperationHandler.listDirectory(path: args["path"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "create_directory",
            description: "Create a directory (and any intermediate directories) at the given path",
            category: .fileOperations,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path of the directory to create"
                    )
                ],
                required: ["path"]
            ),
            handler: { args in
                try await FileSystemTools.createDirectory(path: args["path"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "delete_file",
            description: "Delete a file or directory at the given path",
            category: .fileOperations,
            riskLevel: .high,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path of the file or directory to delete"
                    )
                ],
                required: ["path"]
            ),
            handler: { args in
                try await FileSystemTools.deleteFile(path: args["path"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "move_file",
            description: "Move or rename a file or directory",
            category: .fileOperations,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "source": AIToolProperty(
                        type: "string",
                        description: "Source path"
                    ),
                    "destination": AIToolProperty(
                        type: "string",
                        description: "Destination path"
                    )
                ],
                required: ["source", "destination"]
            ),
            handler: { args in
                try await FileSystemTools.moveFile(
                    source: args["source"] ?? "",
                    destination: args["destination"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "copy_file",
            description: "Copy a file or directory to a new location",
            category: .fileOperations,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "source": AIToolProperty(
                        type: "string",
                        description: "Source path"
                    ),
                    "destination": AIToolProperty(
                        type: "string",
                        description: "Destination path"
                    )
                ],
                required: ["source", "destination"]
            ),
            handler: { args in
                try await FileSystemTools.copyFile(
                    source: args["source"] ?? "",
                    destination: args["destination"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "search_files",
            description: "Recursively search for files matching a pattern in a directory",
            category: .fileOperations,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "directory": AIToolProperty(
                        type: "string",
                        description: "Directory to search in"
                    ),
                    "pattern": AIToolProperty(
                        type: "string",
                        description: "Regex or glob pattern to match file names against"
                    )
                ],
                required: ["directory", "pattern"]
            ),
            handler: { args in
                try await FileSystemTools.searchFiles(
                    directory: args["directory"] ?? "",
                    pattern: args["pattern"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "get_file_info",
            description: "Get metadata about a file or directory (size, dates, type, permissions)",
            category: .fileOperations,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file or directory"
                    )
                ],
                required: ["path"]
            ),
            handler: { args in
                try await FileSystemTools.getFileInfo(path: args["path"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "append_to_file",
            description: "Append content to the end of a file",
            category: .fileOperations,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file"
                    ),
                    "content": AIToolProperty(
                        type: "string",
                        description: "Content to append"
                    )
                ],
                required: ["path", "content"]
            ),
            handler: { args in
                try await FileSystemTools.appendToFile(
                    path: args["path"] ?? "",
                    content: args["content"] ?? ""
                )
            }
        ))

        // MARK: System Commands

        register(RegisteredTool(
            name: "execute_command",
            description: "Execute any shell command via /bin/bash and return its output. Supports pipes, redirects, tilde expansion, and all shell syntax.",
            category: .systemCommands,
            riskLevel: .high,
            parameters: AIToolParameters(
                properties: [
                    "command": AIToolProperty(
                        type: "string",
                        description: "Full shell command string, e.g. \"mkdir -p ~/Desktop/MyFolder\""
                    ),
                    "working_directory": AIToolProperty(
                        type: "string",
                        description: "Working directory for the command (optional)"
                    )
                ],
                required: ["command"]
            ),
            handler: { args in
                try await SystemCommandHandler.executeCommand(
                    command: args["command"] ?? "",
                    workingDirectory: args["working_directory"]
                )
            }
        ))

        register(RegisteredTool(
            name: "open_application",
            description: "Open a macOS application by name, e.g. Safari, Finder, Terminal, Notes, Calculator",
            category: .systemCommands,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "name": AIToolProperty(
                        type: "string",
                        description: "Application name as it appears in /Applications, e.g. \"Safari\", \"Finder\""
                    )
                ],
                required: ["name"]
            ),
            handler: { args in
                try await SystemTools.openApplication(name: args["name"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "open_url",
            description: "Open a URL in the default browser, or any url-scheme (file://, mailto:, etc.)",
            category: .systemCommands,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "url": AIToolProperty(
                        type: "string",
                        description: "URL to open, e.g. \"https://www.bing.com\""
                    )
                ],
                required: ["url"]
            ),
            handler: { args in
                try await SystemTools.openURL(url: args["url"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "get_current_datetime",
            description: "Get the current date and time",
            category: .systemCommands,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [:],
                required: []
            ),
            handler: { _ in
                try await SystemTools.getCurrentDatetime()
            }
        ))

        register(RegisteredTool(
            name: "get_system_info",
            description: "Get information about the system (OS, CPU, memory)",
            category: .systemCommands,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [:],
                required: []
            ),
            handler: { _ in
                try await SystemTools.getSystemInfo()
            }
        ))

        register(RegisteredTool(
            name: "list_processes",
            description: "List the top running processes sorted by CPU usage",
            category: .systemCommands,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [:],
                required: []
            ),
            handler: { _ in
                try await SystemTools.listRunningProcesses()
            }
        ))

        // MARK: Network Requests

        register(RegisteredTool(
            name: "fetch_url",
            description: "Fetch content from a URL using an HTTP GET request",
            category: .networkRequests,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "url": AIToolProperty(
                        type: "string",
                        description: "The URL to fetch"
                    )
                ],
                required: ["url"]
            ),
            handler: { args in
                try await NetworkTools.fetchURL(url: args["url"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "http_request",
            description: "Make an HTTP request with custom method, headers, and body",
            category: .networkRequests,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "url": AIToolProperty(
                        type: "string",
                        description: "The URL to request"
                    ),
                    "method": AIToolProperty(
                        type: "string",
                        description: "HTTP method (GET, POST, PUT, DELETE, PATCH, etc.)",
                        enumValues: ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
                    ),
                    "headers": AIToolProperty(
                        type: "string",
                        description: "JSON string of request headers (optional)"
                    ),
                    "body": AIToolProperty(
                        type: "string",
                        description: "Request body string (optional)"
                    )
                ],
                required: ["url", "method"]
            ),
            handler: { args in
                try await NetworkTools.httpRequest(
                    url: args["url"] ?? "",
                    method: args["method"] ?? "GET",
                    headers: args["headers"],
                    body: args["body"]
                )
            }
        ))

        register(RegisteredTool(
            name: "web_search",
            description: "Search the web for information using DuckDuckGo",
            category: .webSearch,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "query": AIToolProperty(
                        type: "string",
                        description: "Search query"
                    )
                ],
                required: ["query"]
            ),
            handler: { args in
                try await NetworkTools.webSearch(query: args["query"] ?? "")
            }
        ))

        // MARK: Git

        register(RegisteredTool(
            name: "git_status",
            description: "Show the working tree status of a git repository",
            category: .git,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "directory": AIToolProperty(
                        type: "string",
                        description: "Path to the git repository"
                    )
                ],
                required: ["directory"]
            ),
            handler: { args in
                try await GitTools.status(directory: args["directory"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "git_log",
            description: "Show recent git commit history",
            category: .git,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "directory": AIToolProperty(
                        type: "string",
                        description: "Path to the git repository"
                    ),
                    "limit": AIToolProperty(
                        type: "string",
                        description: "Number of commits to show (default: 10)"
                    )
                ],
                required: ["directory"]
            ),
            handler: { args in
                let limit = Int(args["limit"] ?? "10") ?? 10
                return try await GitTools.log(directory: args["directory"] ?? "", limit: limit)
            }
        ))

        register(RegisteredTool(
            name: "git_diff",
            description: "Show changes in the working tree or staged changes",
            category: .git,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "directory": AIToolProperty(
                        type: "string",
                        description: "Path to the git repository"
                    ),
                    "staged": AIToolProperty(
                        type: "string",
                        description: "Set to 'true' to show staged (cached) changes only"
                    )
                ],
                required: ["directory"]
            ),
            handler: { args in
                let staged = args["staged"]?.lowercased() == "true"
                return try await GitTools.diff(directory: args["directory"] ?? "", staged: staged)
            }
        ))

        register(RegisteredTool(
            name: "git_commit",
            description: "Stage all changes and create a git commit",
            category: .git,
            riskLevel: .high,
            parameters: AIToolParameters(
                properties: [
                    "directory": AIToolProperty(
                        type: "string",
                        description: "Path to the git repository"
                    ),
                    "message": AIToolProperty(
                        type: "string",
                        description: "Commit message"
                    )
                ],
                required: ["directory", "message"]
            ),
            handler: { args in
                try await GitTools.commit(
                    directory: args["directory"] ?? "",
                    message: args["message"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "git_branch",
            description: "List branches or create a new branch",
            category: .git,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "directory": AIToolProperty(
                        type: "string",
                        description: "Path to the git repository"
                    ),
                    "create": AIToolProperty(
                        type: "string",
                        description: "Name of the new branch to create (optional; omit to list branches)"
                    )
                ],
                required: ["directory"]
            ),
            handler: { args in
                try await GitTools.branch(
                    directory: args["directory"] ?? "",
                    create: args["create"]
                )
            }
        ))

        register(RegisteredTool(
            name: "git_clone",
            description: "Clone a git repository to a local destination",
            category: .git,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "url": AIToolProperty(
                        type: "string",
                        description: "Repository URL to clone"
                    ),
                    "destination": AIToolProperty(
                        type: "string",
                        description: "Local path to clone into"
                    )
                ],
                required: ["url", "destination"]
            ),
            handler: { args in
                try await GitTools.clone(
                    url: args["url"] ?? "",
                    destination: args["destination"] ?? ""
                )
            }
        ))

        // MARK: Text / Data

        register(RegisteredTool(
            name: "search_in_file",
            description: "Search for a pattern in a file and return matching lines with context",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file"
                    ),
                    "pattern": AIToolProperty(
                        type: "string",
                        description: "Regular expression or string to search for"
                    )
                ],
                required: ["path", "pattern"]
            ),
            handler: { args in
                try await DataTools.searchInFile(
                    path: args["path"] ?? "",
                    pattern: args["pattern"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "replace_in_file",
            description: "Replace all occurrences of a string in a file",
            category: .textData,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file"
                    ),
                    "search": AIToolProperty(
                        type: "string",
                        description: "String to search for"
                    ),
                    "replacement": AIToolProperty(
                        type: "string",
                        description: "Replacement string"
                    )
                ],
                required: ["path", "search", "replacement"]
            ),
            handler: { args in
                try await DataTools.replaceInFile(
                    path: args["path"] ?? "",
                    search: args["search"] ?? "",
                    replacement: args["replacement"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "calculate",
            description: "Evaluate a mathematical expression using Python",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "expression": AIToolProperty(
                        type: "string",
                        description: "Mathematical expression to evaluate (supports math module)"
                    )
                ],
                required: ["expression"]
            ),
            handler: { args in
                try await DataTools.calculate(expression: args["expression"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "parse_json",
            description: "Pretty-print and validate a JSON string",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "input": AIToolProperty(
                        type: "string",
                        description: "JSON string to parse and pretty-print"
                    )
                ],
                required: ["input"]
            ),
            handler: { args in
                try await DataTools.parseJSON(input: args["input"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "encode_base64",
            description: "Encode a string to Base64",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "input": AIToolProperty(
                        type: "string",
                        description: "String to encode"
                    )
                ],
                required: ["input"]
            ),
            handler: { args in
                try await DataTools.encodeBase64(input: args["input"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "decode_base64",
            description: "Decode a Base64-encoded string",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "input": AIToolProperty(
                        type: "string",
                        description: "Base64-encoded string to decode"
                    )
                ],
                required: ["input"]
            ),
            handler: { args in
                try await DataTools.decodeBase64(input: args["input"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "count_lines",
            description: "Count the number of lines in a file",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Absolute path to the file"
                    )
                ],
                required: ["path"]
            ),
            handler: { args in
                try await DataTools.countLines(path: args["path"] ?? "")
            }
        ))

        // MARK: Clipboard

        register(RegisteredTool(
            name: "read_clipboard",
            description: "Read the current contents of the clipboard",
            category: .clipboard,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [:],
                required: []
            ),
            handler: { _ in
                try await ClipboardTools.read()
            }
        ))

        register(RegisteredTool(
            name: "write_clipboard",
            description: "Write content to the clipboard",
            category: .clipboard,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "content": AIToolProperty(
                        type: "string",
                        description: "Content to write to the clipboard"
                    )
                ],
                required: ["content"]
            ),
            handler: { args in
                try await ClipboardTools.write(content: args["content"] ?? "")
            }
        ))

        // MARK: Screenshot

        register(RegisteredTool(
            name: "take_screenshot",
            description: "Take a screenshot and save it to a file",
            category: .screenshot,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "path": AIToolProperty(
                        type: "string",
                        description: "Destination file path (default: ~/Desktop/screenshot.png)"
                    )
                ],
                required: []
            ),
            handler: { args in
                try await MediaTools.takeScreenshot(path: args["path"] ?? "")
            }
        ))

        // MARK: Code Execution

        register(RegisteredTool(
            name: "run_python",
            description: "Execute Python 3 code and return its output",
            category: .codeExecution,
            riskLevel: .high,
            parameters: AIToolParameters(
                properties: [
                    "code": AIToolProperty(
                        type: "string",
                        description: "Python 3 code to execute"
                    )
                ],
                required: ["code"]
            ),
            handler: { args in
                try await CodeTools.runPython(code: args["code"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "run_node",
            description: "Execute Node.js code and return its output",
            category: .codeExecution,
            riskLevel: .high,
            parameters: AIToolParameters(
                properties: [
                    "code": AIToolProperty(
                        type: "string",
                        description: "Node.js code to execute"
                    )
                ],
                required: ["code"]
            ),
            handler: { args in
                try await CodeTools.runNode(code: args["code"] ?? "")
            }
        ))

        // MARK: Memory

        register(RegisteredTool(
            name: "memory_save",
            description: "Persist a key-value pair to long-term memory",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "key": AIToolProperty(
                        type: "string",
                        description: "Memory key"
                    ),
                    "value": AIToolProperty(
                        type: "string",
                        description: "Value to store"
                    )
                ],
                required: ["key", "value"]
            ),
            handler: { args in
                try await MemoryTools.save(key: args["key"] ?? "", value: args["value"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "memory_read",
            description: "Read a value from long-term memory by key",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "key": AIToolProperty(
                        type: "string",
                        description: "Memory key to look up"
                    )
                ],
                required: ["key"]
            ),
            handler: { args in
                try await MemoryTools.read(key: args["key"] ?? "")
            }
        ))

        register(RegisteredTool(
            name: "memory_list",
            description: "List all keys stored in long-term memory",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [:],
                required: []
            ),
            handler: { _ in
                try await MemoryTools.list()
            }
        ))

        register(RegisteredTool(
            name: "memory_delete",
            description: "Delete a key from long-term memory",
            category: .textData,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "key": AIToolProperty(
                        type: "string",
                        description: "Memory key to delete"
                    )
                ],
                required: ["key"]
            ),
            handler: { args in
                try await MemoryTools.delete(key: args["key"] ?? "")
            }
        ))

        // MARK: Screen Control
        // Requires Accessibility access in System Settings → Privacy & Security → Accessibility.

        register(RegisteredTool(
            name: "get_screen_info",
            description: "Get screen dimensions, current cursor position (top-left origin), and frontmost application name",
            category: .screenControl,
            riskLevel: .low,
            parameters: AIToolParameters(properties: [:], required: []),
            handler: { _ in try await ScreenControlTools.getScreenInfo() }
        ))

        register(RegisteredTool(
            name: "move_mouse",
            description: "Move the mouse cursor to the given screen coordinates. (0,0) is the top-left corner of the screen.",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "x": AIToolProperty(type: "string", description: "Horizontal coordinate from left edge of screen"),
                    "y": AIToolProperty(type: "string", description: "Vertical coordinate from top edge of screen")
                ],
                required: ["x", "y"]
            ),
            handler: { args in
                try await ScreenControlTools.moveMouse(
                    x: Double(args["x"] ?? "0") ?? 0,
                    y: Double(args["y"] ?? "0") ?? 0
                )
            }
        ))

        register(RegisteredTool(
            name: "click_mouse",
            description: "Click the mouse at the given coordinates. Use clicks=2 for a double-click.",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "x": AIToolProperty(type: "string", description: "Horizontal coordinate (top-left origin)"),
                    "y": AIToolProperty(type: "string", description: "Vertical coordinate (top-left origin)"),
                    "button": AIToolProperty(type: "string", description: "Mouse button: \"left\" (default) or \"right\"",
                                            enumValues: ["left", "right"]),
                    "clicks": AIToolProperty(type: "string", description: "Number of clicks: 1 (default) or 2 for double-click")
                ],
                required: ["x", "y"]
            ),
            handler: { args in
                try await ScreenControlTools.clickMouse(
                    x: Double(args["x"] ?? "0") ?? 0,
                    y: Double(args["y"] ?? "0") ?? 0,
                    button: args["button"] ?? "left",
                    clicks: Int(args["clicks"] ?? "1") ?? 1
                )
            }
        ))

        register(RegisteredTool(
            name: "scroll_mouse",
            description: "Scroll the mouse wheel at the given position. Positive delta_y scrolls up, negative scrolls down.",
            category: .screenControl,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "x": AIToolProperty(type: "string", description: "Horizontal coordinate"),
                    "y": AIToolProperty(type: "string", description: "Vertical coordinate"),
                    "delta_y": AIToolProperty(type: "string", description: "Vertical scroll amount in pixels (positive = up, negative = down)"),
                    "delta_x": AIToolProperty(type: "string", description: "Horizontal scroll amount in pixels (optional, default 0)")
                ],
                required: ["x", "y", "delta_y"]
            ),
            handler: { args in
                try await ScreenControlTools.scrollMouse(
                    x: Double(args["x"] ?? "0") ?? 0,
                    y: Double(args["y"] ?? "0") ?? 0,
                    deltaX: Int(args["delta_x"] ?? "0") ?? 0,
                    deltaY: Int(args["delta_y"] ?? "0") ?? 0
                )
            }
        ))

        register(RegisteredTool(
            name: "type_text",
            description: "Type a string of text into the currently focused application",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "text": AIToolProperty(type: "string", description: "Text to type")
                ],
                required: ["text"]
            ),
            handler: { args in try await ScreenControlTools.typeText(text: args["text"] ?? "") }
        ))

        register(RegisteredTool(
            name: "press_key",
            description: "Press a named key with optional modifier keys. Key names: return, tab, space, escape, delete, left, right, up, down, a-z, 0-9, f1-f8, home, end, pageup, pagedown",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "key": AIToolProperty(type: "string", description: "Key name, e.g. \"return\", \"tab\", \"escape\", \"a\""),
                    "modifiers": AIToolProperty(type: "string", description: "Comma-separated modifiers: command, shift, option, control (e.g. \"command,shift\")")
                ],
                required: ["key"]
            ),
            handler: { args in
                try await ScreenControlTools.pressKey(
                    key: args["key"] ?? "",
                    modifiers: args["modifiers"] ?? ""
                )
            }
        ))

        register(RegisteredTool(
            name: "run_applescript",
            description: "Execute an AppleScript and return its result. Useful for querying UI state, controlling apps, or automating complex workflows.",
            category: .screenControl,
            riskLevel: .high,
            parameters: AIToolParameters(
                properties: [
                    "script": AIToolProperty(type: "string", description: "AppleScript source code to execute")
                ],
                required: ["script"]
            ),
            handler: { args in try await ScreenControlTools.runAppleScript(script: args["script"] ?? "") }
        ))

        // MARK: iWork (Pages, Numbers, Keynote) Tools

        register(RegisteredTool(
            name: "iwork_write_text",
            description: "Write text directly to the active iWork document (Pages, Numbers, or Keynote) at the current cursor position. Automatically handles escaping.",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "text": AIToolProperty(type: "string", description: "Text to write to the document")
                ],
                required: ["text"]
            ),
            handler: { args in try await ScreenControlTools.iworkWriteText(text: args["text"] ?? "") }
        ))

        register(RegisteredTool(
            name: "iwork_get_document_info",
            description: "Get information about the currently active iWork document, including its name and type (Pages document, Numbers spreadsheet, or Keynote presentation).",
            category: .screenControl,
            riskLevel: .low,
            parameters: AIToolParameters(properties: [:], required: []),
            handler: { _ in try await ScreenControlTools.iworkGetDocumentInfo() }
        ))

        register(RegisteredTool(
            name: "iwork_replace_text",
            description: "Find and replace text in the active Pages document using the Find & Replace dialog. Supports replacing all occurrences or just the first match.",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "find_text": AIToolProperty(type: "string", description: "Text to find"),
                    "replace_text": AIToolProperty(type: "string", description: "Text to replace it with"),
                    "all_occurrences": AIToolProperty(type: "string", description: "true to replace all occurrences, false for first match only", enumValues: ["true", "false"])
                ],
                required: ["find_text", "replace_text"]
            ),
            handler: { args in
                try await ScreenControlTools.iworkReplaceText(
                    findText: args["find_text"] ?? "",
                    replaceText: args["replace_text"] ?? "",
                    allOccurrences: args["all_occurrences"]?.lowercased() != "false"
                )
            }
        ))

        register(RegisteredTool(
            name: "iwork_insert_after_anchor",
            description: "Find specific anchor text in a Pages document and insert new text after it. Useful for adding content at specific locations.",
            category: .screenControl,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "anchor_text": AIToolProperty(type: "string", description: "Text to find in the document"),
                    "new_text": AIToolProperty(type: "string", description: "Text to insert after the anchor")
                ],
                required: ["anchor_text", "new_text"]
            ),
            handler: { args in
                try await ScreenControlTools.iworkInsertAfterAnchor(
                    anchorText: args["anchor_text"] ?? "",
                    newText: args["new_text"] ?? ""
                )
            }
        ))

        // MARK: Bluetooth

        register(RegisteredTool(
            name: "bluetooth_list_devices",
            description: "List all paired Bluetooth devices and whether each is currently connected. Also shows battery level when available.",
            category: .bluetooth,
            riskLevel: .low,
            parameters: AIToolParameters(properties: [:], required: []),
            handler: { _ in try await BluetoothTools.listDevices() }
        ))

        register(RegisteredTool(
            name: "bluetooth_connect",
            description: "Connect or disconnect a paired Bluetooth device by name or MAC address. Requires blueutil (brew install blueutil).",
            category: .bluetooth,
            riskLevel: .medium,
            parameters: AIToolParameters(
                properties: [
                    "device": AIToolProperty(type: "string",
                        description: "Device name or MAC address, e.g. \"AirPods Pro\" or \"xx:xx:xx:xx:xx:xx\""),
                    "action": AIToolProperty(type: "string",
                        description: "connect or disconnect",
                        enumValues: ["connect", "disconnect"])
                ],
                required: ["device", "action"]
            ),
            handler: { args in
                try await BluetoothTools.connectDevice(
                    device: args["device"] ?? "",
                    action: args["action"] ?? "connect"
                )
            }
        ))

        register(RegisteredTool(
            name: "bluetooth_scan",
            description: "Scan for nearby discoverable Bluetooth devices (10-second inquiry). Requires blueutil (brew install blueutil).",
            category: .bluetooth,
            riskLevel: .low,
            parameters: AIToolParameters(properties: [:], required: []),
            handler: { _ in try await BluetoothTools.scanDevices() }
        ))

        // MARK: Volume & Audio

        register(RegisteredTool(
            name: "get_volume",
            description: "Get the current system output volume level (0–100) and mute state.",
            category: .media,
            riskLevel: .low,
            parameters: AIToolParameters(properties: [:], required: []),
            handler: { _ in try await VolumeTools.getVolume() }
        ))

        register(RegisteredTool(
            name: "set_volume",
            description: "Set the system output volume to a level between 0 (silent) and 100 (max).",
            category: .media,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "level": AIToolProperty(type: "string",
                        description: "Volume level 0–100")
                ],
                required: ["level"]
            ),
            handler: { args in
                try await VolumeTools.setVolume(level: Int(args["level"] ?? "50") ?? 50)
            }
        ))

        register(RegisteredTool(
            name: "set_mute",
            description: "Mute or unmute the system audio output.",
            category: .media,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "muted": AIToolProperty(type: "string",
                        description: "true to mute, false to unmute",
                        enumValues: ["true", "false"])
                ],
                required: ["muted"]
            ),
            handler: { args in
                try await VolumeTools.setMute(muted: args["muted"]?.lowercased() == "true")
            }
        ))

        register(RegisteredTool(
            name: "list_audio_devices",
            description: "List all available audio input and output devices on this Mac.",
            category: .media,
            riskLevel: .low,
            parameters: AIToolParameters(properties: [:], required: []),
            handler: { _ in try await VolumeTools.listAudioDevices() }
        ))

        register(RegisteredTool(
            name: "set_audio_output",
            description: "Switch the system audio output device by name (e.g. switch to AirPods or a Bluetooth speaker). Requires SwitchAudioSource (brew install switchaudio-osx).",
            category: .media,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "device": AIToolProperty(type: "string",
                        description: "Exact device name as shown by list_audio_devices, e.g. \"AirPods Pro\"")
                ],
                required: ["device"]
            ),
            handler: { args in
                try await VolumeTools.setOutputDevice(device: args["device"] ?? "")
            }
        ))

        // MARK: Media Control

        register(RegisteredTool(
            name: "media_control",
            description: "Control media playback in Spotify, Music, Podcasts, or any running media app. Actions: play, pause, toggle, next, previous, stop.",
            category: .media,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "action": AIToolProperty(type: "string",
                        description: "Playback action",
                        enumValues: ["play", "pause", "toggle", "next", "previous", "stop"]),
                    "app": AIToolProperty(type: "string",
                        description: "Target app name: Spotify, Music, Podcasts. Omit to auto-detect the running player.")
                ],
                required: ["action"]
            ),
            handler: { args in
                try await MediaControlTools.control(
                    action: args["action"] ?? "toggle",
                    app: args["app"]
                )
            }
        ))

        // MARK: Self-Modification
        // Intercepted by AppState.streamResponse — handler here is a placeholder only.

        register(RegisteredTool(
            name: "update_self",
            description: "Update your own agent configuration. Use this when the user asks you to change your name, personality, system prompt, model, or temperature. Only call this when explicitly asked.",
            category: .systemCommands,
            riskLevel: .low,
            parameters: AIToolParameters(
                properties: [
                    "name": AIToolProperty(
                        type: "string",
                        description: "New agent name (optional)"
                    ),
                    "system_prompt": AIToolProperty(
                        type: "string",
                        description: "New system prompt that defines your personality and behavior (optional)"
                    ),
                    "model": AIToolProperty(
                        type: "string",
                        description: "New model to use, e.g. gpt-4o or claude-sonnet-4-6 (optional)"
                    ),
                    "temperature": AIToolProperty(
                        type: "string",
                        description: "New temperature between 0.0 (focused) and 1.0 (creative) (optional)"
                    )
                ],
                required: []
            ),
            handler: { _ in "Self-update applied." }
        ))
    }
}

/// MARK: - Registered Tool

struct RegisteredTool {
    let name: String
    let description: String
    let category: ToolCategory
    let riskLevel: RiskLevel
    let parameters: AIToolParameters
    let handler: ToolHandler

    var displayCategory: String {
        category.displayName
    }

    func toAITool() -> AITool {
        AITool(
            name: name,
            description: description,
            parameters: parameters
        )
    }
}

// MARK: - Tool Category

enum ToolCategory: String, CaseIterable {
    case fileOperations
    case systemCommands
    case webSearch
    case codeExecution
    case databaseAccess
    case networkRequests
    case git
    case textData
    case clipboard
    case screenshot
    case screenControl
    case bluetooth
    case media

    var displayName: String {
        switch self {
        case .fileOperations:   return "File Operations"
        case .systemCommands:   return "System Commands"
        case .webSearch:        return "Web Search"
        case .codeExecution:    return "Code Execution"
        case .databaseAccess:   return "Database Access"
        case .networkRequests:  return "Network Requests"
        case .git:              return "Git"
        case .textData:         return "Text & Data"
        case .clipboard:        return "Clipboard"
        case .screenshot:       return "Screenshot"
        case .screenControl:    return "Screen Control"
        case .bluetooth:        return "Bluetooth"
        case .media:            return "Media & Volume"
        }
    }

    var icon: String {
        switch self {
        case .fileOperations:   return "doc.fill"
        case .systemCommands:   return "terminal.fill"
        case .webSearch:        return "magnifyingglass"
        case .codeExecution:    return "chevron.left.forwardslash.chevron.right"
        case .databaseAccess:   return "cylinder.fill"
        case .networkRequests:  return "network"
        case .git:              return "arrow.triangle.branch"
        case .textData:         return "text.alignleft"
        case .clipboard:        return "clipboard.fill"
        case .screenshot:       return "camera.fill"
        case .screenControl:    return "cursorarrow.motionlines"
        case .bluetooth:        return "antenna.radiowaves.left.and.right"
        case .media:            return "music.note"
        }
    }
}

// MARK: - Tool Handler

typealias ToolHandler = ([String: String]) async throws -> String

// MARK: - Legacy Tool Handlers (kept for backward compatibility)

enum FileOperationHandler {
    static func readFile(path: String) async throws -> String {
        let path = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: path) else {
            throw ToolError.fileNotFound(path)
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    static func writeFile(path: String, content: String) async throws -> String {
        let path = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return "File written successfully: \(path)"
    }

    static func listDirectory(path: String) async throws -> String {
        let path = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        let items = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: []
        )
        let itemNames = items.map { $0.lastPathComponent }.sorted().joined(separator: "\n")
        return itemNames
    }
}

enum SystemCommandHandler {
    static func executeCommand(
        command: String,
        workingDirectory: String?
    ) async throws -> String {
        // Run through /bin/bash so the full shell syntax works:
        // pipes, redirects, tilde expansion, quoted args, etc.
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]

        if let wd = workingDirectory {
            let expanded = (wd as NSString).expandingTildeInPath
            process.currentDirectoryURL = URL(fileURLWithPath: expanded)
        }

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError  = errPipe

        try process.run()
        process.waitUntilExit()

        let out = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        if process.terminationStatus == 0 {
            return out.isEmpty ? "Done." : out
        } else {
            throw ToolError.commandFailed(err.isEmpty ? "exit \(process.terminationStatus)" : err.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}

// MARK: - Tool Error

enum ToolError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidCommand
    case invalidURL(String)
    case commandFailed(String)
    case permissionDenied
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidCommand:
            return "Invalid command format"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .commandFailed(let error):
            return "Command failed: \(error)"
        case .permissionDenied:
            return "Permission denied"
        case .notImplemented:
            return "Tool not yet implemented"
        }
    }
}
#else
import Foundation

struct RegisteredTool {
    let name: String
    let description: String
    let category: ToolCategory
    let riskLevel: RiskLevel
}

enum ToolCategory: String, CaseIterable {
    case fileOperations, systemCommands, webSearch, codeExecution
    case databaseAccess, networkRequests, git, textData
    case clipboard, screenshot, screenControl, bluetooth, media

    var displayName: String { rawValue }
    var icon: String { "wrench" }
}

final class ToolRegistry {
    static let shared = ToolRegistry()
    private init() {}
    func getAllTools() -> [RegisteredTool] { [] }
    func getToolsForAI(enabledNames: [String] = []) -> [AITool] { [] }
    func getToolsForAIWithoutDesktopControl() -> [AITool] { [] }
    func getTool(named name: String) -> RegisteredTool? { nil }
}
#endif
