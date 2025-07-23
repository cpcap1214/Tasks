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
            title: "Complete project wireframes",
            description: "Design the main screens for the mobile app including dashboard, task list, and settings",
            priority: .high,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
        ))
        
        // Urgent task
        tasks.append(Task(
            title: "Review quarterly reports",
            description: "Go through Q4 financial reports and prepare summary",
            priority: .urgent,
            dueDate: Date()
        ))
        
        // Normal priority tasks
        tasks.append(Task(
            title: "Schedule team meeting",
            description: "Plan next sprint activities and assign tasks",
            priority: .normal,
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())
        ))
        
        tasks.append(Task(
            title: "Update documentation",
            description: "Add new API endpoints to the developer docs",
            priority: .normal,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ))
        
        // Low priority task
        tasks.append(Task(
            title: "Organize desktop files",
            description: "Clean up and organize all the files on desktop",
            priority: .low
        ))
        
        // Add some completed tasks
        var completedTask1 = Task(
            title: "Setup development environment",
            description: "Install Xcode, configure git, and setup project structure",
            priority: .high
        )
        completedTask1.markAsCompleted()
        tasks.append(completedTask1)
        
        var completedTask2 = Task(
            title: "Research competitor apps",
            description: "Study similar productivity apps in the App Store",
            priority: .normal
        )
        completedTask2.markAsCompleted()
        tasks.append(completedTask2)
        
        // Add a deferred task
        var deferredTask = Task(
            title: "Plan vacation",
            description: "Research destinations and book flights",
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