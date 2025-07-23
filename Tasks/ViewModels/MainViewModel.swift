//
//  MainViewModel.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    @Published var currentTask: Task?
    @Published var hasIncompleteTasks: Bool = false
    @Published var isLoading: Bool = false
    
    private let taskService = TaskService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Listen to task service changes
        taskService.$tasks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCurrentTask()
            }
            .store(in: &cancellables)
    }
    
    private func updateCurrentTask() {
        currentTask = taskService.currentTask
        hasIncompleteTasks = taskService.hasIncompleteTasks
    }
    
    // MARK: - Task Actions
    
    func markCurrentTaskAsCompleted() {
        guard let task = currentTask else { return }
        
        isLoading = true
        taskService.markTaskAsCompleted(task)
        
        // Add slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
        }
    }
    
    func deferCurrentTask() {
        guard let task = currentTask else { return }
        
        isLoading = true
        taskService.markTaskAsDeferred(task)
        
        // Add slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
        }
    }
    
    // MARK: - Computed Properties
    
    var dashboardMessage: String {
        if isLoading {
            return "Processing..."
        } else if hasIncompleteTasks {
            return "Focus on your current task"
        } else {
            return "You've completed everything for today!"
        }
    }
    
    var canPerformActions: Bool {
        return currentTask != nil && !isLoading
    }
}