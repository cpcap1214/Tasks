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
        var filtered = tasks
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .pending:
            filtered = filtered.filter { !$0.isCompleted && !$0.isDeferred }
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        case .deferred:
            filtered = filtered.filter { $0.isDeferred }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        filteredTasks = filtered
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
    
    // MARK: - Computed Properties
    
    var taskCounts: (total: Int, pending: Int, completed: Int, deferred: Int) {
        let total = tasks.count
        let pending = tasks.filter { !$0.isCompleted && !$0.isDeferred }.count
        let completed = tasks.filter { $0.isCompleted }.count
        let deferred = tasks.filter { $0.isDeferred }.count
        
        return (total, pending, completed, deferred)
    }
}

// MARK: - Task Filter Enum

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
    case deferred = "Deferred"
    
    var displayName: String {
        return self.rawValue
    }
}