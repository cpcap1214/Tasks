//
//  Task.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation

struct Task: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var description: String?
    var priority: TaskPriority
    var dueDate: Date?
    var isCompleted: Bool
    var isDeferred: Bool
    var createdAt: Date
    var completedAt: Date?
    var deferredAt: Date?
    
    init(
        title: String,
        description: String? = nil,
        priority: TaskPriority = .normal,
        dueDate: Date? = nil
    ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = false
        self.isDeferred = false
        self.createdAt = Date()
        self.completedAt = nil
        self.deferredAt = nil
    }
    
    // MARK: - Task Actions
    
    mutating func markAsCompleted() {
        isCompleted = true
        completedAt = Date()
        isDeferred = false
        deferredAt = nil
    }
    
    mutating func markAsDeferred() {
        isDeferred = true
        deferredAt = Date()
        isCompleted = false
        completedAt = nil
    }
    
    mutating func resetStatus() {
        isCompleted = false
        isDeferred = false
        completedAt = nil
        deferredAt = nil
    }
    
    // MARK: - Sorting Logic
    
    var sortPriority: Int {
        // Higher priority number = higher importance
        // Completed and deferred tasks have lower priority
        if isCompleted || isDeferred {
            return -1000 + priority.sortOrder
        }
        return priority.sortOrder * 1000
    }
    
    var sortDate: Date {
        return dueDate ?? Date.distantFuture
    }
    
    static func sortTasks(_ tasks: [Task]) -> [Task] {
        return tasks.sorted { task1, task2 in
            // First: Priority (higher priority first)
            if task1.sortPriority != task2.sortPriority {
                return task1.sortPriority > task2.sortPriority
            }
            
            // Second: Due date (earlier date first)
            if task1.sortDate != task2.sortDate {
                return task1.sortDate < task2.sortDate
            }
            
            // Third: Created date (newer first)
            return task1.createdAt > task2.createdAt
        }
    }
}