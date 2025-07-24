//
//  AllTasksView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct AllTasksView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                headerView
                    .padding(.horizontal, AppConstants.Spacing.pageMargin)
                    .padding(.bottom, AppConstants.Spacing.contentSpacing)
                
                // Filter and Search
                filterSection
                    .padding(.horizontal, AppConstants.Spacing.pageMargin)
                    .padding(.bottom, AppConstants.Spacing.elementSpacing)
                
                // Task List
                taskListView
            }
            .background(AppConstants.Colors.background)
            .navigationTitle("所有任務")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.startAddingTask) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppConstants.Colors.accent)
                    }
                }
            }
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
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 20) {
            // Header Title
            Text("Task Overview")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Task counts grid - modern card layout
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ModernStatsCard(
                        icon: "list.bullet",
                        title: "Total Tasks",
                        value: "\(viewModel.taskCounts.total)",
                        color: AppConstants.Colors.accent
                    )
                    
                    ModernStatsCard(
                        icon: "clock",
                        title: "Pending",
                        value: "\(viewModel.taskCounts.pending)",
                        color: .orange
                    )
                }
                
                HStack(spacing: 16) {
                    ModernStatsCard(
                        icon: "checkmark.circle",
                        title: "Completed",
                        value: "\(viewModel.taskCounts.completed)",
                        color: .green
                    )
                    
                    ModernStatsCard(
                        icon: "pause.circle",
                        title: "Deferred",
                        value: "\(viewModel.taskCounts.deferred)",
                        color: .gray
                    )
                }
            }
        }
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        VStack(spacing: 16) {
            // Modern Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppConstants.Colors.secondaryText)
                
                TextField("搜尋任務...", text: $viewModel.searchText)
                    .font(.system(size: 16))
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            
            // Modern Filter Picker
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Text(filter.displayName)
                        .tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Task List View
    
    private var taskListView: some View {
        Group {
            if viewModel.filteredTasks.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Modern Task list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredTasks) { task in
                            ModernTaskRow(
                                task: task,
                                onToggleCompletion: {
                                    withAnimation(AppConstants.Animation.stateChange) {
                                        viewModel.toggleTaskCompletion(task)
                                    }
                                },
                                onEdit: {
                                    viewModel.startEditingTask(task)
                                },
                                onDelete: {
                                    withAnimation(AppConstants.Animation.stateChange) {
                                        viewModel.deleteTask(task)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .background(AppConstants.Colors.background)
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            Spacer()
            
            Image(systemName: searchTextOrFilter ? "magnifyingglass" : "list.bullet")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppConstants.Colors.secondaryText)
            
            Text(emptyStateTitle)
                .font(AppConstants.Fonts.title)
                .foregroundColor(AppConstants.Colors.primaryText)
            
            Text(emptyStateMessage)
                .font(AppConstants.Fonts.secondaryContent)
                .foregroundColor(AppConstants.Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            if !searchTextOrFilter {
                Button(action: viewModel.startAddingTask) {
                    Text("新增第一個任務")
                        .font(AppConstants.Fonts.button)
                        .foregroundColor(AppConstants.Colors.background)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(AppConstants.Colors.accent)
                        .cornerRadius(AppConstants.CornerRadius.button)
                }
                .padding(.top, AppConstants.Spacing.contentSpacing)
            }
            
            Spacer()
        }
        .padding(.horizontal, AppConstants.Spacing.pageMargin)
    }
    
    // MARK: - Computed Properties
    
    private var searchTextOrFilter: Bool {
        !viewModel.searchText.isEmpty || viewModel.selectedFilter != .all
    }
    
    private var emptyStateTitle: String {
        if !viewModel.searchText.isEmpty {
            return "沒有結果"
        } else if viewModel.selectedFilter != .all {
            return "沒有\(viewModel.selectedFilter.displayName)任務"
        } else {
            return "還沒有任務"
        }
    }
    
    private var emptyStateMessage: String {
        if !viewModel.searchText.isEmpty {
            return "試試調整搜尋條件或篩選設定"
        } else if viewModel.selectedFilter != .all {
            return "目前沒有\(viewModel.selectedFilter.displayName.lowercased())任務"
        } else {
            return "新增第一個任務開始專注工作"
        }
    }
}

// MARK: - Modern Stats Card View

struct ModernStatsCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryText)
            }
            
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppConstants.Colors.secondaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppConstants.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppConstants.Colors.border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Modern Task Row View

struct ModernTaskRow: View {
    let task: Task
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(task.isCompleted ? .green : AppConstants.Colors.border)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task Content
            VStack(alignment: .leading, spacing: 8) {
                // Title and Priority
                HStack {
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(task.isCompleted ? AppConstants.Colors.secondaryText : AppConstants.Colors.primaryText)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Priority & Status indicators
                    HStack(spacing: 6) {
                        if task.isDeferred {
                            HStack(spacing: 4) {
                                Image(systemName: "pause.circle.fill")
                                    .font(.system(size: 10))
                                Text("延期")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if task.priority == .high || task.priority == .urgent {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 10))
                                Text(task.priority.displayName)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(task.priority == .urgent ? .red : .orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((task.priority == .urgent ? Color.red : Color.orange).opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Description
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .lineLimit(2)
                }
                
                // Dates
                HStack {
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text("到期: \(dueDate.shortDateString)")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(
                            dueDate.daysFromNow() <= 1 && dueDate.daysFromNow() >= 0 
                            ? .red 
                            : AppConstants.Colors.secondaryText
                        )
                    }
                    
                    Spacer()
                    
                    Text("建立於 \(task.createdAt.shortDateString)")
                        .font(.system(size: 12))
                        .foregroundColor(AppConstants.Colors.secondaryText)
                }
            }
            
            // Action Button
            Menu {
                Button(action: onEdit) {
                    Label("編輯", systemImage: "pencil")
                }
                
                Button(action: onToggleCompletion) {
                    Label(
                        task.isCompleted ? "標記為待辦" : "標記為完成",
                        systemImage: task.isCompleted ? "circle" : "checkmark.circle"
                    )
                }
                
                Divider()
                
                Button(role: .destructive, action: onDelete) {
                    Label("刪除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppConstants.Colors.secondaryText)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(16)
        .background(AppConstants.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppConstants.Colors.border, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    AllTasksView()
}