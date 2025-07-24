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
            
            // Initialize with default tasks if no tasks exist
            if tasks.isEmpty {
                initializeDefaultTasks()
            }
        } catch {
            print("Failed to load tasks: \(error)")
            tasks = []
            // Initialize with default tasks on first launch
            initializeDefaultTasks()
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
    
    // MARK: - Default Tasks Initialization
    
    private func initializeDefaultTasks() {
        let calendar = Calendar.current
        let today = Date()
        
        let defaultTasks: [Task] = [
            // 低優先級任務 (2個) - App基礎設定
            Task(
                title: "個人化您的任務管理體驗",
                description: "完成這個任務後，您將了解如何使用 Tasks 的核心功能。嘗試標記完成、延期功能，並觀察任務在不同區域間的移動。",
                priority: .low,
                dueDate: calendar.date(byAdding: .day, value: 7, to: today)
            ),
            Task(
                title: "探索長按查看完整描述功能",
                description: "當任務描述過長時，您可以長按任務卡片來查看完整內容。這個功能在 Dashboard 和所有任務頁面都可以使用，讓您更好地管理詳細資訊。",
                priority: .low,
                dueDate: calendar.date(byAdding: .day, value: 5, to: today)
            ),
            
            // 普通優先級任務 (2個) - 功能介紹
            Task(
                title: "熟悉四大任務區域分類",
                description: "Tasks 將您的任務分為四個區域：專注下一步（最重要任務）、即將到來（有期限任務）、靈感收集（無期限想法）、延期任務（暫時延後）。了解這個分類有助於提高工作效率。",
                priority: .normal,
                dueDate: calendar.date(byAdding: .day, value: 3, to: today)
            ),
            Task(
                title: "測試 Dashboard 的專注模式",
                description: "Dashboard 只顯示一個最重要的任務，幫助您專注。您可以通過滑動手勢快速完成或延期任務，也可以使用底部按鈕進行操作。",
                priority: .normal,
                dueDate: calendar.date(byAdding: .day, value: 4, to: today)
            ),
            
            // 高優先級任務 (2個) - 進階功能
            Task(
                title: "練習使用優先級系統",
                description: "Tasks 提供四種優先級：低、普通、高、緊急。高優先級和緊急任務會顯示彩色標記。學會正確設定優先級可以幫助您更好地安排工作順序。",
                priority: .high,
                dueDate: calendar.date(byAdding: .day, value: 2, to: today)
            ),
            Task(
                title: "體驗滑動手勢操作",
                description: "在 Dashboard 頁面，您可以右滑完成任務，左滑延期任務。這個直觀的手勢操作讓任務管理更加快速便捷。",
                priority: .high,
                dueDate: calendar.date(byAdding: .day, value: 1, to: today)
            ),
            
            // 緊急優先級任務 (2個) - 快速上手
            Task(
                title: "創建您的第一個自定義任務",
                description: "點擊右上角的 + 按鈕，嘗試創建一個屬於您的任務。您可以設定標題、描述、優先級和截止日期。完成這步後，您就完全掌握了 Tasks 的基本用法！",
                priority: .urgent,
                dueDate: today
            ),
            Task(
                title: "完成 Tasks 應用設定",
                description: "這是您的最後一個設定任務！完成後，請刪除所有範例任務，開始使用 Tasks 管理您的真實工作。記住：一次專注一個任務，效率更高！",
                priority: .urgent,
                dueDate: today
            )
        ]
        
        // Add all default tasks
        for task in defaultTasks {
            tasks.append(task)
            stats.incrementTasksCreated()
        }
        
        // Save to storage
        saveTasks()
        saveStats()
    }
}