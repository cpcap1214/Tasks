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
            // 低優先級任務 (2個)
            Task(
                title: "整理桌面檔案",
                description: "清理桌面上的文件，將重要文件歸檔到適當的資料夾中，刪除不需要的檔案。建立良好的檔案管理習慣。",
                priority: .low,
                dueDate: calendar.date(byAdding: .day, value: 7, to: today)
            ),
            Task(
                title: "閱讀一篇技術文章",
                description: "選擇一篇與工作相關的技術文章進行深度閱讀，做筆記並思考如何應用到實際工作中。持續學習新知識。",
                priority: .low,
                dueDate: calendar.date(byAdding: .day, value: 5, to: today)
            ),
            
            // 普通優先級任務 (2個)  
            Task(
                title: "規劃下週工作安排",
                description: "檢視下週的行程表，安排重要會議和任務的時間分配。確保工作與生活的平衡，預留緩衝時間處理突發事件。",
                priority: .normal,
                dueDate: calendar.date(byAdding: .day, value: 3, to: today)
            ),
            Task(
                title: "更新履歷和LinkedIn",
                description: "檢查並更新個人履歷，新增最近的工作經驗和技能。同步更新LinkedIn個人檔案，確保資訊的完整性和時效性。",
                priority: .normal,
                dueDate: calendar.date(byAdding: .day, value: 10, to: today)
            ),
            
            // 高優先級任務 (2個)
            Task(
                title: "完成月度專案報告",
                description: "整理本月專案進度資料，分析完成率和遇到的挑戰。準備簡報並安排與主管討論，制定下個月的改進計畫。",
                priority: .high,
                dueDate: calendar.date(byAdding: .day, value: 2, to: today)
            ),
            Task(
                title: "預約重要會議",
                description: "聯繫客戶安排下週的專案檢討會議，確認會議室和所需設備。準備會議議程和相關文件資料。",
                priority: .high,
                dueDate: calendar.date(byAdding: .day, value: 1, to: today)
            ),
            
            // 緊急優先級任務 (2個)
            Task(
                title: "回覆重要客戶郵件",
                description: "立即回覆客戶關於專案進度的詢問郵件，提供詳細的狀況更新和下一步行動計畫。維持良好的客戶關係。",
                priority: .urgent,
                dueDate: today
            ),
            Task(
                title: "修復系統緊急問題",
                description: "處理生產環境中發現的系統錯誤，進行緊急修復並測試。聯繫相關團隊成員協助解決，確保系統穩定運行。",
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