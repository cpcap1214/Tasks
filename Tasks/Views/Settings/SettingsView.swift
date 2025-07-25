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
    @State private var showingCompletedTasks = false
    @AppStorage("taskRemindersEnabled") private var taskRemindersEnabled = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    // Header
                    Text("設定")
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
            .sheet(isPresented: $showingCompletedTasks) {
                CompletedTasksView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("偏好設定")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "paintbrush",
                    title: "外觀設定",
                    showDivider: true
                ) {
                    Text("跟隨系統")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppConstants.Colors.secondaryBackground)
                        .cornerRadius(8)
                }
                
                ModernSettingsRow(
                    icon: "bell",
                    title: "任務提醒",
                    showDivider: false
                ) {
                    Toggle("", isOn: $taskRemindersEnabled)
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
            Text("資料總覽")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "list.bullet",
                    title: "總任務數",
                    showDivider: true
                ) {
                    Text("\(taskService.stats.totalTasksCreated) 個")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppConstants.Colors.primaryText)
                }
                
                Button(action: {
                    showingCompletedTasks = true
                }) {
                    ModernSettingsRow(
                        icon: "checkmark.circle",
                        title: "已完成任務",
                        showDivider: true
                    ) {
                        HStack(spacing: 8) {
                            Text("\(taskService.stats.tasksCompleted) 個")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppConstants.Colors.primaryText)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(AppConstants.Colors.secondaryText)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                ModernSettingsRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "完成率",
                    showDivider: false
                ) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.1f%%", taskService.getCompletionRate() * 100))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppConstants.Colors.primaryText)
                    }
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
            Text("關於")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.primaryText)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ModernSettingsRow(
                    icon: "app.badge",
                    title: "專注：任務管理",
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
                        title: "清除所有任務",
                        showDivider: true
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(taskService.tasks.isEmpty ? 
                                AppConstants.Colors.secondaryText.opacity(0.5) : 
                                AppConstants.Colors.destructive)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(taskService.tasks.isEmpty)
                .opacity(taskService.tasks.isEmpty ? 0.5 : 1.0)
                
                Button(action: {
                    showingResetAlert = true
                }) {
                    ModernSettingsRow(
                        icon: "arrow.clockwise",
                        title: "重置統計資料",
                        showDivider: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppConstants.Colors.destructive)
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