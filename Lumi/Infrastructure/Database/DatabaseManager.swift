//
//  DatabaseManager.swift
//  LumiAgent
//
//  Created by Lumi Agent on 2026-02-18.
//

import Foundation
import Combine

// MARK: - Database Manager

/// File-backed storage manager used by repositories.
final class DatabaseManager {
    static let shared = DatabaseManager()

    private let fileManager = FileManager.default
    private let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return enc
    }()
    private let decoder = JSONDecoder()
    private let ioQueue = DispatchQueue(label: "com.lumiagent.storage", qos: .utility)
    
    private var localBaseURL: URL
    private var cloudBaseURL: URL?
    
    @Published var isCloudEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isCloudEnabled, forKey: "settings.iCloudEnabled")
            NSUbiquitousKeyValueStore.default.set(isCloudEnabled, forKey: "settings.iCloudEnabled")
            NSUbiquitousKeyValueStore.default.synchronize()
            NotificationCenter.default.post(name: .lumiICloudStatusChanged, object: nil)
        }
    }

    private init() {
        // 1. Setup Local Storage
        let appSupport = (try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? fileManager.temporaryDirectory

        let localFolder = appSupport.appendingPathComponent("LumiAgent", isDirectory: true)
        try? fileManager.createDirectory(at: localFolder, withIntermediateDirectories: true)
        localBaseURL = localFolder
        
        // 2. Load Sync Preference
        NSUbiquitousKeyValueStore.default.synchronize()
        if NSUbiquitousKeyValueStore.default.object(forKey: "settings.iCloudEnabled") != nil {
            isCloudEnabled = NSUbiquitousKeyValueStore.default.bool(forKey: "settings.iCloudEnabled")
        } else {
            isCloudEnabled = UserDefaults.standard.bool(forKey: "settings.iCloudEnabled")
        }
        
        // 3. Setup Cloud Storage (async check)
        setupCloudContainer()
    }
    
    private func setupCloudContainer() {
        DispatchQueue.global(qos: .utility).async {
            if let containerURL = self.fileManager.url(forUbiquityContainerIdentifier: nil) {
                let cloudFolder = containerURL.appendingPathComponent("Documents", isDirectory: true)
                try? self.fileManager.createDirectory(at: cloudFolder, withIntermediateDirectories: true)
                DispatchQueue.main.async {
                    self.cloudBaseURL = cloudFolder
                }
            }
        }
    }

    private var currentBaseURL: URL {
        if isCloudEnabled, let cloud = cloudBaseURL {
            return cloud
        }
        return localBaseURL
    }

    private func fileURL(_ name: String) -> URL {
        currentBaseURL.appendingPathComponent(name, isDirectory: false)
    }

    func load<T: Codable>(_ type: T.Type, from name: String, default defaultValue: @autoclosure () -> T) throws -> T {
        try ioQueue.sync {
            let url = fileURL(name)
            guard fileManager.fileExists(atPath: url.path) else {
                return defaultValue()
            }
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        }
    }

    func save<T: Codable>(_ value: T, to name: String) throws {
        try ioQueue.sync {
            let url = fileURL(name)
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        }
    }
    
    // MARK: - Migration
    
    func migrateToCloud() async throws {
        guard let cloud = cloudBaseURL else { throw DatabaseError.iCloudUnavailable }
        
        try ioQueue.sync {
            let files = try fileManager.contentsOfDirectory(atPath: localBaseURL.path)
            for file in files {
                let localFile = localBaseURL.appendingPathComponent(file)
                let cloudFile = cloud.appendingPathComponent(file)
                
                if fileManager.fileExists(atPath: cloudFile.path) {
                    try fileManager.removeItem(at: cloudFile)
                }
                try fileManager.copyItem(at: localFile, to: cloudFile)
            }
        }
        isCloudEnabled = true
    }
    
    func migrateToLocal() async throws {
        guard let cloud = cloudBaseURL else { throw DatabaseError.iCloudUnavailable }
        
        try ioQueue.sync {
            let files = try fileManager.contentsOfDirectory(atPath: cloud.path)
            for file in files {
                let cloudFile = cloud.appendingPathComponent(file)
                let localFile = localBaseURL.appendingPathComponent(file)
                
                if fileManager.fileExists(atPath: localFile.path) {
                    try fileManager.removeItem(at: localFile)
                }
                try fileManager.copyItem(at: cloudFile, to: localFile)
            }
        }
        isCloudEnabled = false
    }
}

enum DatabaseError: Error, LocalizedError {
    case iCloudUnavailable
    
    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable: return "iCloud container could not be located. Check your system settings."
        }
    }
}
