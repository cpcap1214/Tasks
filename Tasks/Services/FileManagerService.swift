//
//  FileManagerService.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation

class FileManagerService {
    static let shared = FileManagerService()
    
    private let documentsDirectory: URL
    private let backupDirectory: URL
    private let tasksFileName = "tasks.json"
    private let statsFileName = "stats.json"
    private let tasksBackupFileName = "tasks_backup.json"
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        backupDirectory = documentsDirectory.appendingPathComponent("Backups")
        
        // Create backup directory if it doesn't exist
        try? FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - File URLs
    
    private var tasksFileURL: URL {
        return documentsDirectory.appendingPathComponent(tasksFileName)
    }
    
    private var statsFileURL: URL {
        return documentsDirectory.appendingPathComponent(statsFileName)
    }
    
    private var tasksBackupFileURL: URL {
        return backupDirectory.appendingPathComponent(tasksBackupFileName)
    }
    
    // MARK: - Tasks Persistence
    
    func saveTasks(_ tasks: [Task]) throws {
        let data = try JSONEncoder().encode(tasks)
        try data.write(to: tasksFileURL)
    }
    
    func loadTasks() throws -> [Task] {
        guard FileManager.default.fileExists(atPath: tasksFileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: tasksFileURL)
        let tasks = try JSONDecoder().decode([Task].self, from: data)
        return tasks
    }
    
    // MARK: - Stats Persistence
    
    func saveStats(_ stats: AppStats) throws {
        let data = try JSONEncoder().encode(stats)
        try data.write(to: statsFileURL)
    }
    
    func loadStats() throws -> AppStats {
        guard FileManager.default.fileExists(atPath: statsFileURL.path) else {
            return AppStats()
        }
        
        let data = try Data(contentsOf: statsFileURL)
        let stats = try JSONDecoder().decode(AppStats.self, from: data)
        return stats
    }
    
    // MARK: - Backup Management
    
    func createTasksBackup(_ tasks: [Task]) throws {
        let data = try JSONEncoder().encode(tasks)
        try data.write(to: tasksBackupFileURL)
    }
    
    func loadBackupTasks() throws -> [Task] {
        guard FileManager.default.fileExists(atPath: tasksBackupFileURL.path) else {
            throw FileManagerError.backupNotFound
        }
        
        let data = try Data(contentsOf: tasksBackupFileURL)
        let tasks = try JSONDecoder().decode([Task].self, from: data)
        return tasks
    }
    
    func hasBackup() -> Bool {
        return FileManager.default.fileExists(atPath: tasksBackupFileURL.path)
    }
    
    // MARK: - File Management
    
    func clearAllData() throws {
        if FileManager.default.fileExists(atPath: tasksFileURL.path) {
            try FileManager.default.removeItem(at: tasksFileURL)
        }
        
        if FileManager.default.fileExists(atPath: statsFileURL.path) {
            try FileManager.default.removeItem(at: statsFileURL)
        }
        
        // Also clear backup
        if FileManager.default.fileExists(atPath: tasksBackupFileURL.path) {
            try FileManager.default.removeItem(at: tasksBackupFileURL)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return documentsDirectory
    }
    
    func getDataSize() -> String {
        var totalSize: Int64 = 0
        
        let urls = [tasksFileURL, statsFileURL, tasksBackupFileURL]
        
        for url in urls {
            if let fileSize = try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 {
                totalSize += fileSize
            }
        }
        
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

// MARK: - FileManager Errors

enum FileManagerError: Error, LocalizedError {
    case backupNotFound
    case corruptedData
    case insufficientStorage
    
    var errorDescription: String? {
        switch self {
        case .backupNotFound:
            return "備份檔案不存在"
        case .corruptedData:
            return "資料檔案已損壞"
        case .insufficientStorage:
            return "儲存空間不足"
        }
    }
}

// MARK: - App Statistics Model

struct AppStats: Codable {
    var tasksCompleted: Int
    var appOpens: Int
    var totalTasksCreated: Int
    var lastOpenDate: Date?
    
    init() {
        self.tasksCompleted = 0
        self.appOpens = 0
        self.totalTasksCreated = 0
        self.lastOpenDate = nil
    }
    
    mutating func incrementAppOpens() {
        appOpens += 1
        lastOpenDate = Date()
    }
    
    mutating func incrementTasksCompleted() {
        tasksCompleted += 1
    }
    
    mutating func incrementTasksCreated() {
        totalTasksCreated += 1
    }
}