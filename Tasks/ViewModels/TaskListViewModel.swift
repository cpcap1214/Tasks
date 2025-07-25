//
//  TaskListViewModel.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var showingAddTask = false
    @Published var editingTask: Task?
    @Published var selectedFilter: TaskFilter = .all
    @Published var searchText = ""
    
    private let taskService = TaskService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen to task service changes
        taskService.$tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.tasks = Task.sortTasks(tasks)
                self?.updateFilteredTasks()
            }
            .store(in: &cancellables)
        
        // Listen to filter and search changes
        Publishers.CombineLatest($selectedFilter, $searchText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.updateFilteredTasks()
            }
            .store(in: &cancellables)
    }
    
    private func updateFilteredTasks() {
        // For the new four-section layout, we don't need traditional filtering
        // Instead, we'll use the computed properties for each section
        // Keep the search functionality for when search is active
        var filtered = tasks
        
        // Apply search filter when search is active
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        filteredTasks = filtered
    }
    
    // MARK: - Helper Methods
    
    var isSearchActive: Bool {
        return !searchText.isEmpty
    }
    
    var hasAnyTasks: Bool {
        return !tasks.isEmpty
    }
    
    // MARK: - Task Actions
    
    func addTask(title: String, description: String? = nil, priority: TaskPriority, dueDate: Date? = nil) {
        let newTask = Task(title: title, description: description, priority: priority, dueDate: dueDate)
        taskService.addTask(newTask)
        showingAddTask = false
    }
    
    func updateTask(_ task: Task) {
        taskService.updateTask(task)
        editingTask = nil
    }
    
    func deleteTask(_ task: Task) {
        taskService.deleteTask(task)
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if task.isCompleted {
            taskService.resetTaskStatus(task)
        } else {
            taskService.markTaskAsCompleted(task)
        }
    }
    
    func toggleTaskDeferred(_ task: Task) {
        if task.isDeferred {
            taskService.resetTaskStatus(task)
        } else {
            taskService.markTaskAsDeferred(task)
        }
    }
    
    // MARK: - UI Actions
    
    func startAddingTask() {
        showingAddTask = true
    }
    
    func startEditingTask(_ task: Task) {
        editingTask = task
    }
    
    func cancelEditing() {
        editingTask = nil
        showingAddTask = false
    }
    
    // MARK: - Computed Properties for Four-Section Layout
    
    var taskCounts: (total: Int, pending: Int, completed: Int, deferred: Int) {
        let total = tasks.count
        let pending = tasks.filter { !$0.isCompleted && !$0.isDeferred }.count
        let completed = tasks.filter { $0.isCompleted }.count
        let deferred = tasks.filter { $0.isDeferred }.count
        
        return (total, pending, completed, deferred)
    }
    
    // MARK: - Four-Section Task Organization
    
    var nextToFocusTask: Task? {
        // Get the highest priority pending task with nearest due date
        let pendingTasks = tasks.filter { !$0.isCompleted && !$0.isDeferred }
        return pendingTasks.first // Already sorted by priority and due date
    }
    
    var upcomingTasks: [Task] {
        // Tasks with due dates, excluding the focused task
        let tasksWithDates = tasks.filter { task in
            !task.isCompleted && 
            !task.isDeferred && 
            task.dueDate != nil &&
            task.id != nextToFocusTask?.id
        }
        return Array(tasksWithDates) // Show up to 3 upcoming tasks
    }
    
    var unscheduledIdeas: [Task] {
        // Tasks without due dates, excluding completed and deferred
        let unscheduledTasks = tasks.filter { task in
            !task.isCompleted && 
            !task.isDeferred && 
            task.dueDate == nil &&
            task.id != nextToFocusTask?.id
        }
        return Array(unscheduledTasks) // Show up to 4 unscheduled ideas
    }
    
    var deferredTasks: [Task] {
        // All deferred tasks
        let deferred = tasks.filter { task in
            task.isDeferred
        }
        return Array(deferred) // Show up to 4 deferred tasks
    }
    
    var allIncompleteTasks: [Task] {
        // All incomplete tasks (not completed)
        return tasks.filter { !$0.isCompleted }
    }
    
    var doneThisWeek: [Task] {
        // Completed tasks from this week
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let thisWeekCompleted = tasks.filter { task in
            task.isCompleted &&
            task.completedAt != nil &&
            task.completedAt! >= weekAgo
        }
        return Array(thisWeekCompleted.prefix(4)) // Show up to 4 recently completed
    }
}

// MARK: - Task Filter Enum

enum TaskFilter: String, CaseIterable {
    case all = "全部"
    case pending = "待辦"
    case completed = "已完成"
    case deferred = "已延期"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Task Section Types

enum TaskSection: String, CaseIterable {
    case nextToFocus = "Next to Focus"
    case upcoming = "Upcoming"
    case unscheduledIdeas = "Unscheduled Ideas"
    case deferred = "Deferred"
    case doneThisWeek = "Done This Week"
    
    var displayName: String {
        switch self {
        case .nextToFocus:
            return "專注下一步"
        case .upcoming:
            return "即將到來"
        case .unscheduledIdeas:
            return "靈感收集"
        case .deferred:
            return "延期任務"
        case .doneThisWeek:
            return "本週完成"
        }
    }
    
}
