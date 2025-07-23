//
//  SettingsView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var taskService = TaskService.shared
    @State private var showingResetAlert = false
    @State private var showingClearTasksAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Preferences Section
                Section(header: Text("Preferences")) {
                    // Language Setting (placeholder)
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Language")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text("English")
                            .font(AppConstants.Fonts.secondaryContent)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        Image(systemName: "chevron.down")
                            .font(AppConstants.Fonts.iconText)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.vertical, 4)
                    
                    // Appearance Setting (placeholder)
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Appearance")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text("System")
                            .font(AppConstants.Fonts.secondaryContent)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        Image(systemName: "chevron.down")
                            .font(AppConstants.Fonts.iconText)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.vertical, 4)
                    
                    // Task Notifications (placeholder)
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Task Reminders")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Toggle("", isOn: .constant(true))
                    }
                    .padding(.vertical, 4)
                }
                
                // Data Overview Section
                Section(header: Text("Data Overview")) {
                    // Total Tasks
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Total Tasks")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text("\(taskService.stats.totalTasksCreated)")
                            .font(AppConstants.Fonts.primaryContent)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    .padding(.vertical, 4)
                    
                    // Tasks Completed
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Tasks Completed")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text("\(taskService.stats.tasksCompleted)")
                            .font(AppConstants.Fonts.primaryContent)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    .padding(.vertical, 4)
                    
                    // App Opens
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("App Opens")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text("\(taskService.stats.appOpens)")
                            .font(AppConstants.Fonts.primaryContent)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    .padding(.vertical, 4)
                    
                    // Completion Rate
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Completion Rate")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", taskService.getCompletionRate() * 100))
                            .font(AppConstants.Fonts.primaryContent)
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
                    .padding(.vertical, 4)
                }
                
                // Data Management Section
                Section(header: Text("Data Management")) {
                    // Clear Completed Tasks
                    Button(action: {
                        taskService.clearCompletedTasks()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(AppConstants.Colors.destructive)
                                .frame(width: 24, height: 24)
                            
                            Text("Clear Completed Tasks")
                                .font(AppConstants.Fonts.primaryContent)
                                .foregroundColor(AppConstants.Colors.destructive)
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(taskService.completedTasks.isEmpty)
                    
                    // Clear All Tasks
                    Button(action: {
                        showingClearTasksAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(AppConstants.Colors.destructive)
                                .frame(width: 24, height: 24)
                            
                            Text("Clear All Tasks")
                                .font(AppConstants.Fonts.primaryContent)
                                .foregroundColor(AppConstants.Colors.destructive)
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(taskService.tasks.isEmpty)
                    
                    // Reset Statistics
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(AppConstants.Colors.destructive)
                                .frame(width: 24, height: 24)
                            
                            Text("Reset Statistics")
                                .font(AppConstants.Fonts.primaryContent)
                                .foregroundColor(AppConstants.Colors.destructive)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        Text("Tasks")
                            .font(AppConstants.Fonts.primaryContent)
                        
                        Spacer()
                        
                        Text(AppConstants.appVersion)
                            .font(AppConstants.Fonts.secondaryContent)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.vertical, 4)
                    
                    // Developer Info
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(AppConstants.Colors.accent)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Developed with Claude Code")
                                .font(AppConstants.Fonts.primaryContent)
                            
                            Text("Single-task focus productivity app")
                                .font(AppConstants.Fonts.caption)
                                .foregroundColor(AppConstants.Colors.secondaryText)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Statistics", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    taskService.resetAllStats()
                }
            } message: {
                Text("This will permanently reset all your statistics. This action cannot be undone.")
            }
            .alert("Clear All Tasks", isPresented: $showingClearTasksAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    taskService.clearAllTasks()
                }
            } message: {
                Text("This will permanently delete all your tasks. This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}