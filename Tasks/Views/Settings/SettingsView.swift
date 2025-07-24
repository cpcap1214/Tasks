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
            ScrollView {
                VStack(spacing: 40) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                    
                    VStack(spacing: 32) {
                        // Preferences Section
                        preferencesSection
                        
                        // Data Overview Section
                        dataOverviewSection
                        
                        // About Section
                        aboutSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
            .background(AppConstants.Colors.background)
            .navigationBarHidden(true)
            .alert("重置統計", isPresented: $showingResetAlert) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) {
                    taskService.resetAllStats()
                }
            } message: {
                Text("這將永久重置所有統計資料，此操作無法復原。")
            }
            .alert("清除所有任務", isPresented: $showingClearTasksAlert) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) {
                    taskService.clearAllTasks()
                }
            } message: {
                Text("這將永久刪除所有任務，此操作無法復原。")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "globe",
                    title: "Language",
                    showDivider: true
                ) {
                    HStack(spacing: 4) {
                        Text("繁體中文")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppConstants.Colors.secondaryBackground)
                    .cornerRadius(8)
                }
                
                ModernSettingsRow(
                    icon: "paintbrush",
                    title: "Appearance",
                    showDivider: true
                ) {
                    HStack(spacing: 4) {
                        Text("跟隨系統")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppConstants.Colors.secondaryBackground)
                    .cornerRadius(8)
                }
                
                ModernSettingsRow(
                    icon: "bell",
                    title: "Task Reminders",
                    showDivider: false
                ) {
                    Toggle("", isOn: .constant(true))
                        .toggleStyle(SwitchToggleStyle())
                }
            }
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Data Overview Section
    
    private var dataOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Overview")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "list.bullet",
                    title: "Total Tasks",
                    showDivider: true
                ) {
                    Text("\(taskService.stats.totalTasksCreated) 個任務")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
                
                ModernSettingsRow(
                    icon: "calendar",
                    title: "Tasks Completed",
                    showDivider: true
                ) {
                    Text("\(taskService.stats.tasksCompleted) 已完成")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
                
                ModernSettingsRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Completion Rate",
                    showDivider: false
                ) {
                    Text(String(format: "%.0f%%", taskService.getCompletionRate() * 100))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
            }
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "app.badge",
                    title: "Focus: Tasks",
                    showDivider: true
                ) {
                    Text(AppConstants.appVersion)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppConstants.Colors.secondaryText)
                }
                
                Button(action: {
                    showingClearTasksAlert = true
                }) {
                    ModernSettingsRow(
                        icon: "trash",
                        title: "Clear All Tasks",
                        showDivider: true
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(taskService.tasks.isEmpty)
                
                Button(action: {
                    showingResetAlert = true
                }) {
                    ModernSettingsRow(
                        icon: "arrow.clockwise",
                        title: "Reset Statistics",
                        showDivider: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Supporting Views

struct ModernSettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    let showDivider: Bool
    
    init(icon: String, title: String, showDivider: Bool = true, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
        self.showDivider = showDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .frame(width: 24, height: 24)
                    .background(AppConstants.Colors.secondaryBackground)
                    .clipShape(Circle())
                    .padding(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
                
                Spacer()
                
                content
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            if showDivider {
                Divider()
                    .padding(.horizontal, 64)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}