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
            .navigationTitle("All Tasks")
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
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            // Task counts grid - similar to Subscriptions stats layout
            HStack(spacing: AppConstants.Spacing.contentSpacing) {
                StatsCardView(
                    title: "Total",
                    value: "\(viewModel.taskCounts.total)"
                )
                
                StatsCardView(
                    title: "Pending",
                    value: "\(viewModel.taskCounts.pending)"
                )
            }
            
            HStack(spacing: AppConstants.Spacing.contentSpacing) {
                StatsCardView(
                    title: "Completed",
                    value: "\(viewModel.taskCounts.completed)"
                )
                
                StatsCardView(
                    title: "Deferred",
                    value: "\(viewModel.taskCounts.deferred)"
                )
            }
        }
    }
    
    // MARK: - Filter Section
    
    private var filterSection: some View {
        VStack(spacing: AppConstants.Spacing.elementSpacing) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppConstants.Colors.secondaryText)
                
                TextField("Search tasks...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppConstants.Colors.secondaryBackground)
            .cornerRadius(AppConstants.CornerRadius.smallElement)
            
            // Filter Picker
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Text(filter.displayName)
                        .tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Task List View
    
    private var taskListView: some View {
        Group {
            if viewModel.filteredTasks.isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Task list
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskRowView(
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
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.horizontal, AppConstants.Spacing.pageMargin)
                    }
                }
                .listStyle(PlainListStyle())
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
                    Text("Add Your First Task")
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
            return "No Results"
        } else if viewModel.selectedFilter != .all {
            return "No \(viewModel.selectedFilter.displayName) Tasks"
        } else {
            return "No Tasks Yet"
        }
    }
    
    private var emptyStateMessage: String {
        if !viewModel.searchText.isEmpty {
            return "Try adjusting your search terms or filter settings."
        } else if viewModel.selectedFilter != .all {
            return "You don't have any \(viewModel.selectedFilter.displayName.lowercased()) tasks at the moment."
        } else {
            return "Start by adding your first task to get organized and focused."
        }
    }
}

// MARK: - Stats Card View

struct StatsCardView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppConstants.Fonts.categoryDisplay)
                .foregroundColor(AppConstants.Colors.primaryText)
                .tracking(-1)
            
            Text(title)
                .font(AppConstants.Fonts.secondaryContent)
                .foregroundColor(AppConstants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppConstants.Spacing.cardVerticalPadding)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card)
                .stroke(AppConstants.Colors.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview {
    AllTasksView()
}