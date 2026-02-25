//
//  MCPToolHandlers.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//
//  Real implementations for all MCP tool handlers
//

#if os(macOS)
import Foundation
import AppKit

// MARK: - Path Helpers

private func expandPath(_ path: String) -> String {
    (path as NSString).expandingTildeInPath
}

// MARK: - File System Tools

enum FileSystemTools {
    static func createDirectory(path: String) async throws -> String {
        let expanded = expandPath(path)
        try FileManager.default.createDirectory(
            atPath: expanded,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return "Directory created: \(expanded)"
    }

    static func deleteFile(path: String) async throws -> String {
        let expanded = expandPath(path)
        guard FileManager.default.fileExists(atPath: expanded) else {
            throw ToolError.fileNotFound(expanded)
        }
        try FileManager.default.removeItem(atPath: expanded)
        return "Deleted: \(expanded)"
    }

    static func moveFile(source: String, destination: String) async throws -> String {
        let src = expandPath(source), dst = expandPath(destination)
        guard FileManager.default.fileExists(atPath: src) else {
            throw ToolError.fileNotFound(src)
        }
        try FileManager.default.moveItem(atPath: src, toPath: dst)
        return "Moved \(src) → \(dst)"
    }

    static func copyFile(source: String, destination: String) async throws -> String {
        let src = expandPath(source), dst = expandPath(destination)
        guard FileManager.default.fileExists(atPath: src) else {
            throw ToolError.fileNotFound(src)
        }
        try FileManager.default.copyItem(atPath: src, toPath: dst)
        return "Copied \(src) → \(dst)"
    }

    static func searchFiles(directory: String, pattern: String) async throws -> String {
        let directory = expandPath(directory)
        let enumerator = FileManager.default.enumerator(atPath: directory)
        var matches: [String] = []
        while let file = enumerator?.nextObject() as? String {
            if file.range(of: pattern, options: .regularExpression) != nil {
                matches.append((directory as NSString).appendingPathComponent(file))
            }
        }
        if matches.isEmpty {
            return "No files matching '\(pattern)' found in \(directory)"
        }
        return matches.joined(separator: "\n")
    }

    static func getFileInfo(path: String) async throws -> String {
        let path = expandPath(path)
        guard FileManager.default.fileExists(atPath: path) else {
            throw ToolError.fileNotFound(path)
        }
        let attrs = try FileManager.default.attributesOfItem(atPath: path)
        let size = attrs[.size] as? Int ?? 0
        let created = attrs[.creationDate] as? Date
        let modified = attrs[.modificationDate] as? Date
        let fileType = attrs[.type] as? FileAttributeType
        let posixPerms = attrs[.posixPermissions] as? Int ?? 0

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium

        let typeStr: String
        if fileType == .typeDirectory {
            typeStr = "Directory"
        } else if fileType == .typeSymbolicLink {
            typeStr = "Symbolic Link"
        } else {
            typeStr = "File"
        }

        let permsStr = String(posixPerms, radix: 8)

        var lines = [
            "Path: \(path)",
            "Type: \(typeStr)",
            "Size: \(size) bytes (\(ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)))",
            "Permissions: \(permsStr)"
        ]
        if let c = created { lines.append("Created: \(formatter.string(from: c))") }
        if let m = modified { lines.append("Modified: \(formatter.string(from: m))") }
        return lines.joined(separator: "\n")
    }

    static func appendToFile(path: String, content: String) async throws -> String {
        let path = expandPath(path)
        let url = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: path) {
            let fileHandle = try FileHandle(forWritingTo: url)
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            if let data = content.data(using: .utf8) {
                fileHandle.write(data)
            }
        } else {
            try content.write(to: url, atomically: true, encoding: .utf8)
        }
        return "Appended to \(path)"
    }
}

// MARK: - System Tools

enum SystemTools {
    static func getCurrentDatetime() async throws -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter.string(from: Date())
    }

    static func getSystemInfo() async throws -> String {
        let info = ProcessInfo.processInfo
        let totalRAM = Int64(info.physicalMemory)
        let ramStr = ByteCountFormatter.string(fromByteCount: totalRAM, countStyle: .memory)

        var lines = [
            "Hostname: \(info.hostName)",
            "OS Version: \(info.operatingSystemVersionString)",
            "CPU Cores (logical): \(info.processorCount)",
            "Active Processors: \(info.activeProcessorCount)",
            "Physical Memory: \(ramStr)",
            "Process ID: \(info.processIdentifier)",
            "Uptime: \(Int(info.systemUptime)) seconds"
        ]

        // Try sysctl for CPU brand string
        let executor = ProcessExecutor()
        let cpuResult = try? await executor.execute(
            command: "sysctl",
            arguments: ["-n", "machdep.cpu.brand_string"]
        )
        if let cpuBrand = cpuResult?.output?.trimmingCharacters(in: .whitespacesAndNewlines),
           !cpuBrand.isEmpty {
            lines.insert("CPU: \(cpuBrand)", at: 2)
        }

        return lines.joined(separator: "\n")
    }

    static func listRunningProcesses() async throws -> String {
        let executor = ProcessExecutor()
        // Use /bin/ps directly to avoid env lookup issues with sorting
        let result = try await executor.execute(
            command: "ps",
            arguments: ["aux", "-r"]
        )
        if result.success, let output = result.output {
            let lines = output.components(separatedBy: "\n")
            // Header + top 20 processes
            let selected = Array(lines.prefix(21))
            return selected.joined(separator: "\n")
        } else {
            throw ToolError.commandFailed(result.error ?? "ps failed")
        }
    }

    static func openApplication(name: String) async throws -> String {
        // Sanitize: strip characters that could break the shell script
        let safe = name.replacingOccurrences(of: "\"", with: "")
                       .replacingOccurrences(of: "`", with: "")
                       .replacingOccurrences(of: "$", with: "")
                       .trimmingCharacters(in: .whitespacesAndNewlines)

        // Strategy:
        // 1. open -a "name"          — exact bundle name (fastest)
        // 2. mdfind                  — Spotlight fuzzy search across all volumes
        // 3. find in common dirs     — /Applications, ~/Applications, /System/Applications
        let script = """
        set -e
        if open -a "\(safe)" 2>/dev/null; then
            echo "Opened \(safe)"
            exit 0
        fi
        APP=$(mdfind "kMDItemContentType == 'com.apple.application-bundle'" -name "\(safe)" 2>/dev/null | head -1)
        if [ -n "$APP" ]; then
            open "$APP"
            echo "Opened $APP"
            exit 0
        fi
        APP=$(find /Applications ~/Applications /System/Applications /System/Library/CoreServices -maxdepth 4 -iname "*\(safe)*.app" 2>/dev/null | head -1)
        if [ -n "$APP" ]; then
            open "$APP"
            echo "Opened $APP"
            exit 0
        fi
        echo "Could not find application: \(safe)" >&2
        exit 1
        """

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", script]
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        try process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            let out = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            return out.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw ToolError.commandFailed(err.isEmpty ? "Could not open \(safe)" : err.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    static func openURL(url: String) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "open \"\(url)\""]
        let errPipe = Pipe()
        process.standardError = errPipe
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus == 0 {
            return "Opened URL: \(url)"
        } else {
            let err = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            throw ToolError.commandFailed(err.isEmpty ? "Could not open \(url)" : err)
        }
    }
}

// MARK: - Network Tools

enum NetworkTools {
    static func fetchURL(url urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw ToolError.invalidURL(urlString)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let body = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? "<binary data>"
        let truncated = body.count > 8000 ? String(body.prefix(8000)) + "\n...[truncated]" : body
        return "Status: \(statusCode)\n\n\(truncated)"
    }

    static func httpRequest(
        url urlString: String,
        method: String,
        headers: String?,
        body: String?
    ) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw ToolError.invalidURL(urlString)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()

        // Parse headers JSON
        if let headersJSON = headers,
           let headersData = headersJSON.data(using: .utf8),
           let headersDict = try? JSONSerialization.jsonObject(with: headersData) as? [String: String] {
            for (key, value) in headersDict {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Set body
        if let body = body {
            request.httpBody = body.data(using: .utf8)
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let responseHeaders = (response as? HTTPURLResponse)?.allHeaderFields as? [String: String] ?? [:]
        let responseBody = String(data: data, encoding: .utf8) ?? "<binary data>"
        let truncated = responseBody.count > 8000 ? String(responseBody.prefix(8000)) + "\n...[truncated]" : responseBody

        var result = "Status: \(statusCode)\n"
        result += "Headers: \(responseHeaders)\n\n"
        result += truncated
        return result
    }

    static func webSearch(query: String) async throws -> String {
        let braveKey = UserDefaults.standard.string(forKey: "settings.braveAPIKey") ?? ""
        if !braveKey.isEmpty {
            return try await braveSearch(query: query, apiKey: braveKey)
        }
        return try await duckDuckGoSearch(query: query)
    }

    private static func braveSearch(query: String, apiKey: String) async throws -> String {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.search.brave.com/res/v1/web/search?q=\(encoded)&count=10")
        else { throw ToolError.invalidURL(query) }

        var req = URLRequest(url: url, timeoutInterval: 15)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(apiKey, forHTTPHeaderField: "X-Subscription-Token")

        let (data, _) = try await URLSession.shared.data(for: req)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let web = json["web"] as? [String: Any],
              let results = web["results"] as? [[String: Any]], !results.isEmpty
        else { return "No Brave results found for: \(query)" }

        var output = "Search results for '\(query)':\n\n"
        for (i, r) in results.prefix(10).enumerated() {
            let title = r["title"] as? String ?? "No title"
            let url   = r["url"]   as? String ?? ""
            let desc  = r["description"] as? String ?? ""
            output += "\(i + 1). \(title)\n   \(url)\n   \(desc)\n\n"
        }
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func duckDuckGoSearch(query: String) async throws -> String {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.duckduckgo.com/?q=\(encoded)&format=json&no_html=1&skip_disambig=1")
        else { throw ToolError.invalidURL(query) }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "No results found for: \(query)"
        }

        var output = ""
        if let abstract = json["AbstractText"] as? String, !abstract.isEmpty {
            output += "Summary:\n\(abstract)\n\n"
        }
        if let related = json["RelatedTopics"] as? [[String: Any]] {
            let texts = related.compactMap { $0["Text"] as? String }.filter { !$0.isEmpty }.prefix(5)
            if !texts.isEmpty {
                output += "Related:\n" + texts.map { "- \($0)" }.joined(separator: "\n")
            }
        }
        return output.isEmpty ? "No results found for: \(query) — add a Brave API key in Settings for better results." : output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Git Tools

enum GitTools {
    static func status(directory: String) async throws -> String {
        let executor = ProcessExecutor()
        let workDir = URL(fileURLWithPath: directory)
        let result = try await executor.execute(
            command: "git",
            arguments: ["status"],
            workingDirectory: workDir
        )
        if result.success {
            return result.output ?? ""
        } else {
            throw ToolError.commandFailed(result.error ?? "git status failed")
        }
    }

    static func log(directory: String, limit: Int) async throws -> String {
        let executor = ProcessExecutor()
        let workDir = URL(fileURLWithPath: directory)
        let result = try await executor.execute(
            command: "git",
            arguments: ["log", "--oneline", "-\(limit)"],
            workingDirectory: workDir
        )
        if result.success {
            return result.output ?? ""
        } else {
            throw ToolError.commandFailed(result.error ?? "git log failed")
        }
    }

    static func diff(directory: String, staged: Bool) async throws -> String {
        let executor = ProcessExecutor()
        let workDir = URL(fileURLWithPath: directory)
        var args = ["diff"]
        if staged { args.append("--staged") }
        let result = try await executor.execute(
            command: "git",
            arguments: args,
            workingDirectory: workDir
        )
        if result.success {
            let output = result.output ?? ""
            return output.isEmpty ? "No changes" : output
        } else {
            throw ToolError.commandFailed(result.error ?? "git diff failed")
        }
    }

    static func commit(directory: String, message: String) async throws -> String {
        let executor = ProcessExecutor()
        let workDir = URL(fileURLWithPath: directory)

        // Stage all changes
        let addResult = try await executor.execute(
            command: "git",
            arguments: ["add", "-A"],
            workingDirectory: workDir
        )
        if !addResult.success {
            throw ToolError.commandFailed(addResult.error ?? "git add failed")
        }

        // Commit
        let commitResult = try await executor.execute(
            command: "git",
            arguments: ["commit", "-m", message],
            workingDirectory: workDir
        )
        if commitResult.success {
            return commitResult.output ?? "Committed successfully"
        } else {
            throw ToolError.commandFailed(commitResult.error ?? "git commit failed")
        }
    }

    static func branch(directory: String, create: String?) async throws -> String {
        let executor = ProcessExecutor()
        let workDir = URL(fileURLWithPath: directory)
        if let branchName = create {
            let result = try await executor.execute(
                command: "git",
                arguments: ["checkout", "-b", branchName],
                workingDirectory: workDir
            )
            if result.success {
                return result.output ?? "Branch '\(branchName)' created and checked out"
            } else {
                throw ToolError.commandFailed(result.error ?? "git branch failed")
            }
        } else {
            let result = try await executor.execute(
                command: "git",
                arguments: ["branch", "-a"],
                workingDirectory: workDir
            )
            if result.success {
                return result.output ?? ""
            } else {
                throw ToolError.commandFailed(result.error ?? "git branch failed")
            }
        }
    }

    static func clone(url: String, destination: String) async throws -> String {
        let executor = ProcessExecutor()
        let result = try await executor.execute(
            command: "git",
            arguments: ["clone", url, destination]
        )
        if result.success {
            return result.output ?? "Cloned \(url) to \(destination)"
        } else {
            throw ToolError.commandFailed(result.error ?? "git clone failed")
        }
    }
}

// MARK: - Data Tools

enum DataTools {
    static func searchInFile(path: String, pattern: String) async throws -> String {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ToolError.fileNotFound(path)
        }
        let executor = ProcessExecutor()
        let result = try await executor.execute(
            command: "grep",
            arguments: ["-n", "-C", "2", pattern, path]
        )
        if result.success {
            let output = result.output ?? ""
            return output.isEmpty ? "No matches found for '\(pattern)' in \(path)" : output
        } else {
            // grep returns exit code 1 when no matches, which ProcessExecutor treats as failure
            return "No matches found for '\(pattern)' in \(path)"
        }
    }

    static func replaceInFile(path: String, search: String, replacement: String) async throws -> String {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ToolError.fileNotFound(path)
        }
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url, encoding: .utf8)
        let count = content.components(separatedBy: search).count - 1
        if count == 0 {
            return "Pattern '\(search)' not found in \(path)"
        }
        let newContent = content.replacingOccurrences(of: search, with: replacement)
        try newContent.write(to: url, atomically: true, encoding: .utf8)
        return "Replaced \(count) occurrence(s) of '\(search)' with '\(replacement)' in \(path)"
    }

    static func calculate(expression: String) async throws -> String {
        let executor = ProcessExecutor()
        let code = "import math; print(\(expression))"
        let result = try await executor.execute(
            command: "python3",
            arguments: ["-c", code]
        )
        if result.success {
            return result.output?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        } else {
            throw ToolError.commandFailed(result.error ?? "Calculation failed")
        }
    }

    static func parseJSON(input: String) async throws -> String {
        guard let data = input.data(using: .utf8) else {
            throw ToolError.commandFailed("Invalid input string")
        }
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let prettyData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
        return String(data: prettyData, encoding: .utf8) ?? input
    }

    static func encodeBase64(input: String) async throws -> String {
        guard let data = input.data(using: .utf8) else {
            throw ToolError.commandFailed("Invalid input string")
        }
        return data.base64EncodedString()
    }

    static func decodeBase64(input: String) async throws -> String {
        guard let data = Data(base64Encoded: input),
              let decoded = String(data: data, encoding: .utf8) else {
            throw ToolError.commandFailed("Invalid Base64 input")
        }
        return decoded
    }

    static func countLines(path: String) async throws -> String {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ToolError.fileNotFound(path)
        }
        let content = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
        let count = content.components(separatedBy: "\n").count
        return "\(count) lines in \(path)"
    }
}

// MARK: - Clipboard Tools

enum ClipboardTools {
    @MainActor
    static func read() async throws -> String {
        let pb = NSPasteboard.general
        return pb.string(forType: .string) ?? ""
    }

    @MainActor
    static func write(content: String) async throws -> String {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(content, forType: .string)
        return "Written to clipboard: \(content.prefix(100))\(content.count > 100 ? "..." : "")"
    }
}

// MARK: - Media Tools

enum MediaTools {
    static func takeScreenshot(path: String) async throws -> String {
        let destination: String
        if path.isEmpty {
            destination = (NSHomeDirectory() as NSString).appendingPathComponent("Desktop/screenshot.png")
        } else {
            destination = path
        }
        let executor = ProcessExecutor()
        let result = try await executor.execute(
            command: "/usr/sbin/screencapture",
            arguments: ["-x", destination]
        )
        if result.success {
            return "Screenshot saved to \(destination)"
        } else {
            throw ToolError.commandFailed(result.error ?? "screencapture failed")
        }
    }
}

// MARK: - Code Tools

enum CodeTools {
    static func runPython(code: String) async throws -> String {
        let tmpFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("lumi_\(UUID().uuidString).py")
        try code.write(to: tmpFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tmpFile) }

        let executor = ProcessExecutor()
        let result = try await executor.execute(
            command: "python3",
            arguments: [tmpFile.path]
        )
        if result.success {
            return result.output ?? ""
        } else {
            throw ToolError.commandFailed(result.error ?? "Python execution failed")
        }
    }

    static func runNode(code: String) async throws -> String {
        let tmpFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("lumi_\(UUID().uuidString).js")
        try code.write(to: tmpFile, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tmpFile) }

        let executor = ProcessExecutor()
        let result = try await executor.execute(
            command: "node",
            arguments: [tmpFile.path]
        )
        if result.success {
            return result.output ?? ""
        } else {
            throw ToolError.commandFailed(result.error ?? "Node execution failed")
        }
    }
}

// MARK: - Memory Tools

enum MemoryTools {
    private static let prefix = "lumiagent.memory."

    static func save(key: String, value: String) async throws -> String {
        UserDefaults.standard.set(value, forKey: prefix + key)
        return "Saved '\(key)'"
    }

    static func read(key: String) async throws -> String {
        guard let value = UserDefaults.standard.string(forKey: prefix + key) else {
            return "Key '\(key)' not found in memory"
        }
        return value
    }

    static func list() async throws -> String {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(prefix) }
            .map { String($0.dropFirst(prefix.count)) }
            .sorted()
        if allKeys.isEmpty {
            return "No keys stored in memory"
        }
        return allKeys.joined(separator: "\n")
    }

    static func delete(key: String) async throws -> String {
        let fullKey = prefix + key
        guard UserDefaults.standard.object(forKey: fullKey) != nil else {
            return "Key '\(key)' not found in memory"
        }
        UserDefaults.standard.removeObject(forKey: fullKey)
        return "Deleted '\(key)' from memory"
    }
}

// MARK: - Bluetooth Tools

enum BluetoothTools {

    /// List all paired Bluetooth devices and their connection status.
    static func listDevices() async throws -> String {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/bash")
        proc.arguments = ["-c", "system_profiler SPBluetoothDataType 2>/dev/null"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try proc.run(); proc.waitUntilExit()
        let raw = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return raw.isEmpty ? "No Bluetooth information available." : raw
    }

    /// Connect or disconnect a paired device by name or MAC address.
    /// Requires `blueutil` (brew install blueutil).
    static func connectDevice(device: String, action: String) async throws -> String {
        let act = action.lowercased()
        guard act == "connect" || act == "disconnect" else {
            throw ToolError.commandFailed("action must be 'connect' or 'disconnect'")
        }
        // Locate blueutil
        let which = try await shell("which blueutil 2>/dev/null || echo ''")
        let blueutilPath = which.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !blueutilPath.isEmpty else {
            return """
            blueutil is not installed. Install it with:
              brew install blueutil
            Then retry: bluetooth_connect device=\"\(device)\" action=\"\(action)\"
            """
        }
        let cmd = "\(blueutilPath) --\(act) \"\(device)\""
        let result = try await shell(cmd)
        return result.isEmpty ? "\(act.capitalized)ed \(device)" : result
    }

    /// Scan for discoverable nearby Bluetooth devices (10-second inquiry).
    /// Requires `blueutil` (brew install blueutil).
    static func scanDevices() async throws -> String {
        let which = try await shell("which blueutil 2>/dev/null || echo ''")
        let blueutilPath = which.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !blueutilPath.isEmpty else {
            return "blueutil is not installed. Install with: brew install blueutil"
        }
        let result = try await shell("\(blueutilPath) --inquiry --format new-json 2>/dev/null || \(blueutilPath) --inquiry")
        return result.isEmpty ? "No devices found nearby." : result
    }

    private static func shell(_ cmd: String) async throws -> String {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/bash")
        proc.arguments = ["-c", cmd]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try proc.run(); proc.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - Volume Tools

enum VolumeTools {

    static func getVolume() async throws -> String {
        let script = "get volume settings"
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", script]
        let pipe = Pipe()
        proc.standardOutput = pipe
        try proc.run(); proc.waitUntilExit()
        let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return "Volume settings: \(out)"
    }

    static func setVolume(level: Int) async throws -> String {
        let clamped = max(0, min(100, level))
        let script = "set volume output volume \(clamped)"
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", script]
        try proc.run(); proc.waitUntilExit()
        return "Volume set to \(clamped)%"
    }

    static func setMute(muted: Bool) async throws -> String {
        let script = muted
            ? "set volume with output muted"
            : "set volume without output muted"
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", script]
        try proc.run(); proc.waitUntilExit()
        return muted ? "Audio muted." : "Audio unmuted."
    }

    /// List all audio output devices.
    static func listAudioDevices() async throws -> String {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/bash")
        proc.arguments = ["-c", "system_profiler SPAudioDataType 2>/dev/null"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        try proc.run(); proc.waitUntilExit()
        let raw = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        return raw.isEmpty ? "No audio device information available." : raw
    }

    /// Switch the system audio output device by name.
    /// Requires `SwitchAudioSource` (brew install switchaudio-osx).
    static func setOutputDevice(device: String) async throws -> String {
        let which = try? await shell("which SwitchAudioSource 2>/dev/null || echo ''")
        let tool = (which ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tool.isEmpty else {
            return """
            SwitchAudioSource is not installed. Install it with:
              brew install switchaudio-osx
            Then retry: set_audio_output device=\"\(device)\"
            Available devices can be found with: list_audio_devices
            """
        }
        let result = try await shell("\(tool) -s \"\(device)\"")
        return result.isEmpty ? "Switched audio output to \(device)" : result
    }

    private static func shell(_ cmd: String) async throws -> String {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/bash")
        proc.arguments = ["-c", cmd]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try proc.run(); proc.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - Media Control Tools

enum MediaControlTools {

    /// Play, pause, toggle, next, previous, or stop media in Spotify, Music, or any running player.
    static func control(action: String, app: String?) async throws -> String {
        let act = action.lowercased()

        // Determine which app to target
        let target: String
        if let a = app, !a.isEmpty {
            target = a
        } else {
            // Auto-detect: prefer Spotify, then Music, then any running media app
            let running = try? await shell(
                "osascript -e 'tell application \"System Events\" to get name of every process whose background only is false'"
            )
            let procs = running ?? ""
            if procs.contains("Spotify") { target = "Spotify" }
            else if procs.contains("Music") { target = "Music" }
            else if procs.contains("Podcasts") { target = "Podcasts" }
            else { target = "Music" }
        }

        let command: String
        switch act {
        case "play":          command = "tell application \"\(target)\" to play"
        case "pause":         command = "tell application \"\(target)\" to pause"
        case "toggle", "playpause":
            command = "tell application \"\(target)\" to playpause"
        case "next", "next track":
            command = "tell application \"\(target)\" to next track"
        case "previous", "prev", "previous track":
            command = "tell application \"\(target)\" to previous track"
        case "stop":          command = "tell application \"\(target)\" to stop"
        default:
            throw ToolError.commandFailed("Unknown action '\(action)'. Use: play, pause, toggle, next, previous, stop")
        }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", command]
        proc.standardError = Pipe()
        try proc.run(); proc.waitUntilExit()
        return "\(act.capitalized) sent to \(target)."
    }

    private static func shell(_ cmd: String) async throws -> String {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/bash")
        proc.arguments = ["-c", cmd]
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = Pipe()
        try proc.run(); proc.waitUntilExit()
        return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

// MARK: - Screen Control Tools
// Requires Accessibility access: System Settings → Privacy & Security → Accessibility → LumiAgent

enum ScreenControlTools {

    // MARK: Screen Info

    static func getScreenInfo() async throws -> String {
        let info = await MainActor.run { () -> (Int, Int, Int, Int, String) in
            let frame = NSScreen.main?.frame ?? .init(x: 0, y: 0, width: 1440, height: 900)
            let loc = NSEvent.mouseLocation
            let front = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
            let cursorY = Int(frame.height) - Int(loc.y)
            return (Int(frame.width), Int(frame.height), Int(loc.x), cursorY, front)
        }
        return """
        Screen size: \(info.0)×\(info.1) (coordinates: top-left origin)
        Cursor position: (\(info.2), \(info.3))
        Frontmost app: \(info.4)
        """
    }

    // MARK: Mouse Control

    /// Convert tool coordinates (top-left origin, px from top-left of NSScreen.main) to
    /// global CGEvent coordinates (top-left origin of primary display, Y increases downward).
    ///
    /// CGEvent is NOT Quartz/NSScreen — it uses top-left origin.
    /// NSScreen uses bottom-left origin (Y upward, Cartesian).
    ///
    /// For a screen at NSScreen frame (ox, oy, w, h), a point (x, y) measured from its
    /// top-left corner maps to CGEvent global coords:
    ///   CGEvent.x = ox + x
    ///   CGEvent.y = primaryH - oy - h + y        (where primaryH = height of primary display)
    ///
    /// For the primary display (oy=0, h=primaryH): CGEvent.y = y — no flip, passes through.
    private static func toQuartzPoint(x: Double, y: Double, frame: CGRect) -> CGPoint {
        // Primary display always has NSScreen frame.origin = (0, 0).
        let primaryH = NSScreen.screens
            .first { $0.frame.origin.x == 0 && $0.frame.origin.y == 0 }
            .map { $0.frame.height }
            ?? frame.height
        return CGPoint(
            x: frame.origin.x + x,
            y: primaryH - frame.origin.y - frame.height + y
        )
    }

    /// Move mouse cursor. Coordinates: (0,0) = top-left of screen.
    static func moveMouse(x: Double, y: Double) async throws -> String {
        let frame = await MainActor.run { NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900) }
        let point = toQuartzPoint(x: x, y: y, frame: frame)
        CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)
        return "Mouse moved to (\(Int(x)), \(Int(y)))"
    }

    /// Click at position. button: "left" or "right". clicks: 1 or 2 for double-click.
    static func clickMouse(x: Double, y: Double, button: String, clicks: Int) async throws -> String {
        let frame = await MainActor.run { NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900) }
        let point = toQuartzPoint(x: x, y: y, frame: frame)
        let isRight = button.lowercased() == "right"
        let btn: CGMouseButton = isRight ? .right : .left
        let downType: CGEventType = isRight ? .rightMouseDown : .leftMouseDown
        let upType: CGEventType = isRight ? .rightMouseUp : .leftMouseUp

        let count = max(1, min(clicks, 2))
        for clickState in 1...count {
            let down = CGEvent(mouseEventSource: nil, mouseType: downType,
                               mouseCursorPosition: point, mouseButton: btn)
            down?.setIntegerValueField(.mouseEventClickState, value: Int64(clickState))
            let up = CGEvent(mouseEventSource: nil, mouseType: upType,
                             mouseCursorPosition: point, mouseButton: btn)
            up?.setIntegerValueField(.mouseEventClickState, value: Int64(clickState))
            down?.post(tap: .cghidEventTap)
            up?.post(tap: .cghidEventTap)
        }
        let clickWord = count == 2 ? "Double-clicked" : "Clicked"
        return "\(clickWord) \(button) button at (\(Int(x)), \(Int(y)))"
    }

    /// Scroll at position. Positive deltaY = scroll up, negative = scroll down.
    static func scrollMouse(x: Double, y: Double, deltaX: Int, deltaY: Int) async throws -> String {
        let frame = await MainActor.run { NSScreen.main?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900) }
        let point = toQuartzPoint(x: x, y: y, frame: frame)
        let event = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 2,
                            wheel1: Int32(deltaY), wheel2: Int32(deltaX), wheel3: 0)
        event?.location = point
        event?.post(tap: .cghidEventTap)
        return "Scrolled at (\(Int(x)), \(Int(y))): deltaY=\(deltaY), deltaX=\(deltaX)"
    }

    // MARK: Keyboard Control

    /// Type a string of text using AppleScript's keystroke command.
    static func typeText(text: String) async throws -> String {
        let safe = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "System Events"
            keystroke "\(safe)"
        end tell
        """
        try await runAppleScript(script: script)
        return "Typed: \(text)"
    }

    /// Press a named key (e.g. "return", "tab", "escape", "a") with optional modifier keys.
    /// modifiers: comma-separated list of "command", "shift", "option", "control"
    static func pressKey(key: String, modifiers: String) async throws -> String {
        let mods = modifiers
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .compactMap { mod -> String? in
                switch mod {
                case "command", "cmd": return "command down"
                case "shift": return "shift down"
                case "option", "alt": return "option down"
                case "control", "ctrl": return "control down"
                case "": return nil
                default: return nil
                }
            }
        let code = keyNameToCode(key)
        let modStr = mods.isEmpty ? "" : " using {\(mods.joined(separator: ", "))}"
        let script = """
        tell application "System Events"
            key code \(code)\(modStr)
        end tell
        """
        try await runAppleScript(script: script)
        return "Pressed key: \(key)\(modifiers.isEmpty ? "" : " + \(modifiers)")"
    }

    // MARK: AppleScript

    /// Run arbitrary AppleScript and return the result.
    @discardableResult
    static func runAppleScript(script: String) async throws -> String {
        try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                var errDict: NSDictionary?
                let appleScript = NSAppleScript(source: script)
                if let result = appleScript?.executeAndReturnError(&errDict) {
                    cont.resume(returning: result.stringValue ?? "(script completed, no return value)")
                } else {
                    let msg = errDict?["NSAppleScriptErrorMessage"] as? String
                        ?? "AppleScript execution failed"
                    cont.resume(throwing: ToolError.commandFailed(msg))
                }
            }
        }
    }

    // MARK: - iWork Tools (Pages, Numbers, Keynote)

    /// Write text to the active iWork document at the cursor position.
    static func iworkWriteText(text: String) async throws -> String {
        let safe = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
        let script = """
        tell application "System Events"
            tell process "Pages" to set frontmost to true
            keystroke "\(safe)"
        end tell
        """
        _ = try await runAppleScript(script: script)
        return "Text written to iWork document: \(text.prefix(100))"
    }

    /// Get information about the active iWork document (name, word count, etc).
    static func iworkGetDocumentInfo() async throws -> String {
        let script = """
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
            return "No iWork app is currently active"
        end if
        """
        return try await runAppleScript(script: script)
    }

    /// Replace text in the active iWork document using find and replace.
    static func iworkReplaceText(findText: String, replaceText: String, allOccurrences: Bool = true) async throws -> String {
        let findSafe = findText
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let replaceSafe = replaceText
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "System Events"
            set frontmostApp to name of (first application process whose frontmost is true)
        end tell

        if frontmostApp contains "Pages" then
            tell application "Pages"
                activate
                tell application "System Events"
                    keystroke "f" using command down
                    delay 0.5
                    keystroke "\(findSafe)"
                    delay 0.3
                    key code 48 -- Tab to replace field
                    keystroke "\(replaceSafe)"
                    delay 0.2
                    \(allOccurrences ? "keystroke \"a\" using command down -- Replace All" : "keystroke \"&\" using command down -- Replace")
                    delay 0.3
                    key code 53 -- Escape to close find dialog
                end tell
                return "Text replaced in Pages document"
            end tell
        else
            return "Find and replace is only supported in Pages currently"
        end if
        """
        return try await runAppleScript(script: script)
    }

    /// Insert text at a specific position or after finding an anchor text in Pages/iWork.
    static func iworkInsertAfterAnchor(anchorText: String, newText: String) async throws -> String {
        let anchorSafe = anchorText
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let newTextSafe = newText
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")

        let script = """
        tell application "Pages"
            activate
            tell application "System Events"
                keystroke "f" using command down -- Open Find
                delay 0.5
                keystroke "\(anchorSafe)"
                delay 0.2
                key code 36 -- Return to find first occurrence
                delay 0.3
                key code 53 -- Escape to close find
                delay 0.2
                key code 124 -- Right arrow to go past anchor text
                delay 0.1
                key code 36 -- Enter a new line
                keystroke "\(newTextSafe)"
            end tell
        end tell
        """
        return try await runAppleScript(script: script)
    }

    // MARK: Key Code Lookup

    private static func keyNameToCode(_ name: String) -> Int {
        switch name.lowercased() {
        case "a": return 0;  case "s": return 1;  case "d": return 2;  case "f": return 3
        case "h": return 4;  case "g": return 5;  case "z": return 6;  case "x": return 7
        case "c": return 8;  case "v": return 9;  case "b": return 11; case "q": return 12
        case "w": return 13; case "e": return 14; case "r": return 15; case "y": return 16
        case "t": return 17; case "1": return 18; case "2": return 19; case "3": return 20
        case "4": return 21; case "6": return 22; case "5": return 23; case "=": return 24
        case "9": return 25; case "7": return 26; case "-": return 27; case "8": return 28
        case "0": return 29; case "o": return 31; case "u": return 32; case "i": return 34
        case "p": return 35; case "l": return 37; case "j": return 38; case "k": return 40
        case "n": return 45; case "m": return 46; case "return", "enter": return 36
        case "tab": return 48; case "space": return 49; case "delete", "backspace": return 51
        case "escape", "esc": return 53; case "left": return 123; case "right": return 124
        case "down": return 125; case "up": return 126; case "home": return 115
        case "end": return 119; case "pageup": return 116; case "pagedown": return 121
        case "f1": return 122; case "f2": return 120; case "f3": return 99; case "f4": return 118
        case "f5": return 96;  case "f6": return 97;  case "f7": return 98; case "f8": return 100
        default: return 36
        }
    }
}
#endif
