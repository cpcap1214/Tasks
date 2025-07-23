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
    private let tasksFileName = "tasks.json"
    private let statsFileName = "stats.json"
    
    private init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - File URLs
    
    private var tasksFileURL: URL {
        return documentsDirectory.appendingPathComponent(tasksFileName)
    }
    
    private var statsFileURL: URL {
        return documentsDirectory.appendingPathComponent(statsFileName)
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
    
    // MARK: - File Management
    
    func clearAllData() throws {
        if FileManager.default.fileExists(atPath: tasksFileURL.path) {
            try FileManager.default.removeItem(at: tasksFileURL)
        }
        
        if FileManager.default.fileExists(atPath: statsFileURL.path) {
            try FileManager.default.removeItem(at: statsFileURL)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        return documentsDirectory
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