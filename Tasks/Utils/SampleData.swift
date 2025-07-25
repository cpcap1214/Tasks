//
//  SampleData.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation

struct SampleData {
    static func createSampleTasks() -> [Task] {
        var tasks: [Task] = []
        
        // High priority tasks
        tasks.append(Task(
            title: "完成項目線框圖",
            description: "設計手機應用的主要畫面，包括主控台、任務列表和設定頁面",
            priority: .high,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
        ))
        
        // Urgent task
        tasks.append(Task(
            title: "檢閱季度報告",
            description: "檢閱第四季財務報告並準備摘要",
            priority: .urgent,
            dueDate: Date()
        ))
        
        // Normal priority tasks - one with due date, one without
        tasks.append(Task(
            title: "安排團隊會議",
            description: "規劃下一個衝刺週期的活動並分配任務",
            priority: .normal,
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())
        ))
        
        // Task without due date - will go to Unscheduled Ideas
        tasks.append(Task(
            title: "更新文檔",
            description: "在開發者文檔中新增 API 端點",
            priority: .normal
        ))
        
        // More unscheduled ideas
        tasks.append(Task(
            title: "學習 SwiftUI 動畫",
            description: "探索進階動畫技巧以提升使用者體驗",
            priority: .low
        ))
        
        tasks.append(Task(
            title: "整理桌面檔案",
            description: "清理並整理桌面上的所有檔案",
            priority: .low
        ))
        
        // Add some completed tasks
        var completedTask1 = Task(
            title: "設置開發環境",
            description: "安裝 Xcode、配置 git 並設置項目結構",
            priority: .high
        )
        completedTask1.markAsCompleted()
        tasks.append(completedTask1)
        
        var completedTask2 = Task(
            title: "研究競爭對手應用",
            description: "研究 App Store 中類似的生產力應用",
            priority: .normal
        )
        completedTask2.markAsCompleted()
        tasks.append(completedTask2)
        
        // Add a deferred task
        var deferredTask = Task(
            title: "計劃假期",
            description: "研究目的地並預訂機票",
            priority: .low,
            dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())
        )
        deferredTask.markAsDeferred()
        tasks.append(deferredTask)
        
        return tasks
    }
    
    static func setupInitialData() {
        let taskService = TaskService.shared
        
        // Only add sample data if no tasks exist
        if taskService.tasks.isEmpty {
            let sampleTasks = createSampleTasks()
            for task in sampleTasks {
                taskService.addTask(task)
            }
        }
    }
}