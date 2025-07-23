//
//  TaskService.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation
import Combine

class TaskService: ObservableObject {
    static let shared = TaskService()
    
    @Published var tasks: [Task] = []
    @Published var stats: AppStats = AppStats()
    
    private let fileManager = FileManagerService.shared
    
    private init() {
        loadData()
        recordAppOpen()
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        loadTasks()
        loadStats()
    }
    
    private func loadTasks() {
        do {
            tasks = try fileManager.loadTasks()
        } catch {
            print("Failed to load tasks: \(error)")
            tasks = []
        }
    }
    
    private func loadStats() {
        do {
            stats = try fileManager.loadStats()
        } catch {
            print("Failed to load stats: \(error)")
            stats = AppStats()
        }
    }
    
    // MARK: - Data Saving
    
    private func saveTasks() {
        do {
            try fileManager.saveTasks(tasks)
        } catch {
            print("Failed to save tasks: \(error)")
        }
    }
    
    private func saveStats() {
        do {
            try fileManager.saveStats(stats)
        } catch {
            print("Failed to save stats: \(error)")
        }
    }
    
    // MARK: - Task Management
    
    func addTask(_ task: Task) {
        tasks.append(task)
        stats.incrementTasksCreated()
        saveTasks()
        saveStats()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func markTaskAsCompleted(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].markAsCompleted()
            stats.incrementTasksCompleted()
            saveTasks()
            saveStats()
        }
    }
    
    func markTaskAsDeferred(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].markAsDeferred()
            saveTasks()
        }
    }
    
    func resetTaskStatus(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            let wasCompleted = tasks[index].isCompleted
            tasks[index].resetStatus()
            
            // Adjust stats if task was previously completed
            if wasCompleted && stats.tasksCompleted > 0 {
                stats.tasksCompleted -= 1
                saveStats()
            }
            
            saveTasks()
        }
    }
    
    // MARK: - Task Queries
    
    var sortedTasks: [Task] {
        return Task.sortTasks(tasks)
    }
    
    var currentTask: Task? {
        let incompleteTasks = tasks.filter { !$0.isCompleted && !$0.isDeferred }
        return Task.sortTasks(incompleteTasks).first
    }
    
    var completedTasks: [Task] {
        return tasks.filter { $0.isCompleted }
    }
    
    var pendingTasks: [Task] {
        return tasks.filter { !$0.isCompleted && !$0.isDeferred }
    }
    
    var deferredTasks: [Task] {
        return tasks.filter { $0.isDeferred }
    }
    
    var hasIncompleteTasks: Bool {
        return !pendingTasks.isEmpty
    }
    
    // MARK: - Statistics
    
    private func recordAppOpen() {
        stats.incrementAppOpens()
        saveStats()
    }
    
    func getCompletionRate() -> Double {
        guard stats.totalTasksCreated > 0 else { return 0.0 }
        return Double(stats.tasksCompleted) / Double(stats.totalTasksCreated)
    }
    
    // MARK: - Bulk Operations
    
    func clearAllTasks() {
        tasks.removeAll()
        saveTasks()
    }
    
    func clearCompletedTasks() {
        tasks.removeAll { $0.isCompleted }
        saveTasks()
    }
    
    func resetAllStats() {
        stats = AppStats()
        saveStats()
    }
}