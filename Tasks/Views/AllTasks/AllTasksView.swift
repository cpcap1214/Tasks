//
//  AllTasksView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct AllTasksView: View {
    @StateObject private var viewModel = TaskListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean white background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header with Add Button
                    HStack {
                        Spacer()
                        
                        Text("所有任務")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        addButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    if !viewModel.hasAnyTasks {
                        // Empty state
                        emptyStateContent
                    } else {
                        // Four-section layout
                        fourSectionContent
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingAddTask) {
                AddTaskView { title, description, priority, dueDate in
                    viewModel.addTask(
                        title: title,
                        description: description,
                        priority: priority,
                        dueDate: dueDate
                    )
                }
            }
            .sheet(item: $viewModel.editingTask) { task in
                AddTaskView(
                    onSave: { title, description, priority, dueDate in
                        var updatedTask = task
                        updatedTask.title = title
                        updatedTask.description = description
                        updatedTask.priority = priority
                        updatedTask.dueDate = dueDate
                        viewModel.updateTask(updatedTask)
                    },
                    editingTask: task
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Four Section Content
    
    private var fourSectionContent: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                // Next to Focus Section
                if let focusTask = viewModel.nextToFocusTask {
                    TaskSectionView(
                        section: .nextToFocus,
                        tasks: [focusTask],
                        onTaskAction: handleTaskAction
                    )
                }
                
                // Upcoming Section
                if !viewModel.upcomingTasks.isEmpty {
                    TaskSectionView(
                        section: .upcoming,
                        tasks: viewModel.upcomingTasks,
                        onTaskAction: handleTaskAction
                    )
                }
                
                // Unscheduled Ideas Section
                if !viewModel.unscheduledIdeas.isEmpty {
                    TaskSectionView(
                        section: .unscheduledIdeas,
                        tasks: viewModel.unscheduledIdeas,
                        onTaskAction: handleTaskAction
                    )
                }
                
                
                
                // Add some bottom padding
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Toolbar Items
    
    private var addButton: some View {
        Button(action: viewModel.startAddingTask) {
            Image(systemName: "plus")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Empty State Content
    
    private var emptyStateContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("歡迎使用 Tasks")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("新增你的第一個任務開始管理你的工作")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: viewModel.startAddingTask) {
                Text("新增任務")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 16)
            
            Spacer()
        }
    }
    
    // MARK: - Task Action Handler
    
    private func handleTaskAction(_ action: TaskAction, task: Task) {
        switch action {
        case .toggleCompletion:
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.toggleTaskCompletion(task)
            }
        case .edit:
            viewModel.startEditingTask(task)
        case .delete:
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.deleteTask(task)
            }
        case .deferTask:
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.toggleTaskDeferred(task)
            }
        }
    }
}

// MARK: - Task Section View

struct TaskSectionView: View {
    let section: TaskSection
    let tasks: [Task]
    let onTaskAction: (TaskAction, Task) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            Text(section.displayName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Tasks
            VStack(spacing: 12) {
                ForEach(tasks) { task in
                    TaskCard(
                        task: task,
                        isCompleted: task.isCompleted,
                        showFocusStyle: section == .nextToFocus,
                        onTaskAction: onTaskAction
                    )
                }
            }
        }
    }
}


// MARK: - Basic Task Card

struct TaskCard: View {
    let task: Task
    let isCompleted: Bool
    let showFocusStyle: Bool
    let onTaskAction: (TaskAction, Task) -> Void
    
    @State private var showingFullDescription = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion Button
            Button(action: {
                onTaskAction(.toggleCompletion, task)
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isCompleted ? .green : .gray.opacity(0.6))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                HStack {
                    Text(task.title)
                        .font(.system(size: showFocusStyle ? 18 : 16, weight: showFocusStyle ? .semibold : .medium))
                        .foregroundColor(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)
                        .lineLimit(showFocusStyle ? 3 : 2)
                    
                    Spacer()
                    
                    // Priority Indicator - 更顯眼的設計
                    if task.priority != .normal {
                        Circle()
                            .fill(priorityColor(for: task.priority))
                            .frame(width: task.priority == .urgent ? 12 : 10, 
                                   height: task.priority == .urgent ? 12 : 10)
                            .scaleEffect(task.priority == .urgent ? 1.1 : 1.0)
                            .animation(task.priority == .urgent ? 
                                .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : 
                                .none, value: task.priority)
                    }
                }
                
                // Description
                if let description = task.description, !description.isEmpty, (showFocusStyle || description.count < 50) {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(showFocusStyle ? 3 : 1)
                }
                
                // Defer status indicator
                if task.isDeferred {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text("已延期")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Due Date
                if let dueDate = task.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(formatDateString(dueDate))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(daysBetween(from: Date(), to: dueDate) < 0 ? .red : .secondary)
                }
            }
            
            // Context Menu Button
            Menu {
                Button(action: {
                    onTaskAction(.edit, task)
                }) {
                    Label("編輯", systemImage: "pencil")
                }
                
                Button(action: {
                    onTaskAction(.toggleCompletion, task)
                }) {
                    Label(
                        isCompleted ? "標記為待辦" : "標記為完成",
                        systemImage: isCompleted ? "circle" : "checkmark.circle"
                    )
                }
                
                if !isCompleted {
                    Button(action: {
                        onTaskAction(.deferTask, task)
                    }) {
                        Label(
                            task.isDeferred ? "取消延期" : "延期任務",
                            systemImage: task.isDeferred ? "clock.arrow.circlepath" : "clock"
                        )
                    }
                }
                
                Divider()
                
                Button(role: .destructive, action: {
                    onTaskAction(.delete, task)
                }) {
                    Label("刪除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: .black.opacity(showFocusStyle ? 0.08 : 0.04),
                    radius: showFocusStyle ? 8 : 4,
                    x: 0,
                    y: showFocusStyle ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    showFocusStyle ? Color.blue.opacity(0.2) : Color.clear,
                    lineWidth: showFocusStyle ? 1 : 0
                )
        )
        .onLongPressGesture {
            if let description = task.description, !description.isEmpty {
                showingFullDescription = true
            }
        }
        .alert("任務詳細描述", isPresented: $showingFullDescription) {
            Button("確定", role: .cancel) { }
        } message: {
            if let description = task.description {
                Text(description)
            }
        }
    }
}

// MARK: - Task Action Enum

enum TaskAction {
    case toggleCompletion
    case edit
    case delete
    case deferTask
}

// MARK: - Helper Functions

private func formatDateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    let calendar = Calendar.current
    
    if calendar.isDateInToday(date) {
        return "今天"
    } else if calendar.isDateInTomorrow(date) {
        return "明天"
    } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    } else {
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

private func daysBetween(from startDate: Date, to endDate: Date) -> Int {
    let calendar = Calendar.current
    let start = calendar.startOfDay(for: startDate)
    let end = calendar.startOfDay(for: endDate)
    let components = calendar.dateComponents([.day], from: start, to: end)
    return components.day ?? 0
}

private func priorityColor(for priority: TaskPriority) -> Color {
    switch priority {
    case .low:
        return .green
    case .normal:
        return .blue
    case .high:
        return .orange
    case .urgent:
        return .red
    }
}


// MARK: - Preview

#Preview {
    AllTasksView()
        .preferredColorScheme(.light)
}