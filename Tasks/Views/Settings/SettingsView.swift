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
                VStack(spacing: 32) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    VStack(spacing: 24) {
                        // Preferences Section
                        preferencesSection
                        
                        // Data Overview Section
                        dataOverviewSection
                        
                        // About Section
                        aboutSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
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
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "globe",
                    title: "Language",
                    value: "繁體中文",
                    showDivider: true
                )
                
                ModernSettingsRow(
                    icon: "paintbrush",
                    title: "Appearance",
                    value: "跟隨系統",
                    showDivider: true
                )
                
                ModernSettingsRow(
                    icon: "bell",
                    title: "Task Reminders",
                    hasToggle: true,
                    toggleValue: .constant(true),
                    showDivider: true
                )
                
                ModernSettingsRow(
                    icon: "dollarsign.square",
                    title: "Preferred Currency",
                    value: "TWD",
                    showDivider: false
                )
            }
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Data Overview Section
    
    private var dataOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Overview")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "list.bullet",
                    title: "Total Tasks",
                    value: "\(taskService.stats.totalTasksCreated) 個任務",
                    showDivider: true
                )
                
                ModernSettingsRow(
                    icon: "calendar",
                    title: "Tasks Completed",
                    value: "\(taskService.stats.tasksCompleted) 已完成",
                    showDivider: true
                )
                
                ModernSettingsRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Completion Rate",
                    value: String(format: "%.0f%%", taskService.getCompletionRate() * 100),
                    showDivider: false
                )
            }
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "app.badge",
                    title: "Focus: Tasks",
                    value: AppConstants.appVersion,
                    showDivider: true
                )
                
                Button(action: {
                    showingClearTasksAlert = true
                }) {
                    ModernSettingsRow(
                        icon: "trash",
                        title: "Clear All Tasks",
                        titleColor: AppConstants.Colors.destructive,
                        showDivider: true
                    )
                }
                .disabled(taskService.tasks.isEmpty)
                
                Button(action: {
                    showingResetAlert = true
                }) {
                    ModernSettingsRow(
                        icon: "arrow.clockwise",
                        title: "Reset Statistics",
                        titleColor: AppConstants.Colors.destructive,
                        showDivider: false
                    )
                }
            }
            .background(AppConstants.Colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppConstants.Colors.border, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Supporting Views

struct ModernSettingsRow: View {
    let icon: String
    let title: String
    let value: String?
    let titleColor: Color
    let hasToggle: Bool
    let toggleValue: Binding<Bool>?
    let showDivider: Bool
    
    init(
        icon: String,
        title: String,
        value: String? = nil,
        titleColor: Color = AppConstants.Colors.primaryText,
        hasToggle: Bool = false,
        toggleValue: Binding<Bool>? = nil,
        showDivider: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.titleColor = titleColor
        self.hasToggle = hasToggle
        self.toggleValue = toggleValue
        self.showDivider = showDivider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .frame(width: 24, height: 24)
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                // Value or Toggle
                if hasToggle, let toggleBinding = toggleValue {
                    Toggle("", isOn: toggleBinding)
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                } else if let valueText = value {
                    HStack(spacing: 4) {
                        Text(valueText)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            if showDivider {
                Rectangle()
                    .fill(AppConstants.Colors.border.opacity(0.3))
                    .frame(height: 0.5)
                    .padding(.horizontal, 64) // Match reference code padding
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}