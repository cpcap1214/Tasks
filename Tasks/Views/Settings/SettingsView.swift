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
                VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                    // Header
                    VStack(spacing: AppConstants.Spacing.elementSpacing) {
                        Text("設定")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("管理你的專注工具")
                            .font(AppConstants.Fonts.secondaryContent)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                    }
                    .padding(.top, AppConstants.Spacing.contentSpacing)
                    
                    // Statistics Cards
                    statisticsSection
                    
                    // Appearance Section
                    appearanceSection
                    
                    // Data Management Section
                    dataManagementSection
                    
                    // About Section
                    aboutSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppConstants.Spacing.pageMargin)
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
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            sectionHeader(title: "統計資料", icon: "chart.bar.fill")
            
            VStack(spacing: AppConstants.Spacing.elementSpacing) {
                HStack(spacing: AppConstants.Spacing.contentSpacing) {
                    StatCardView(
                        title: "總任務",
                        value: "\(taskService.stats.totalTasksCreated)",
                        icon: "list.bullet"
                    )
                    
                    StatCardView(
                        title: "已完成",
                        value: "\(taskService.stats.tasksCompleted)",
                        icon: "checkmark.circle.fill"
                    )
                }
                
                HStack(spacing: AppConstants.Spacing.contentSpacing) {
                    StatCardView(
                        title: "開啟次數",
                        value: "\(taskService.stats.appOpens)",
                        icon: "app.badge"
                    )
                    
                    StatCardView(
                        title: "完成率",
                        value: String(format: "%.0f%%", taskService.getCompletionRate() * 100),
                        icon: "chart.line.uptrend.xyaxis"
                    )
                }
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            sectionHeader(title: "外觀設定", icon: "paintbrush.fill")
            
            SettingsCardView {
                VStack(spacing: AppConstants.Spacing.contentSpacing) {
                    SettingsRowView(
                        title: "語言",
                        subtitle: "繁體中文",
                        icon: "globe",
                        showChevron: true
                    )
                    
                    Divider()
                        .background(AppConstants.Colors.border)
                    
                    SettingsRowView(
                        title: "外觀模式",
                        subtitle: "跟隨系統",
                        icon: "circle.lefthalf.filled",
                        showChevron: true
                    )
                    
                    Divider()
                        .background(AppConstants.Colors.border)
                    
                    HStack {
                        HStack(spacing: AppConstants.Spacing.elementSpacing) {
                            Image(systemName: "bell")
                                .foregroundColor(AppConstants.Colors.accent)
                                .font(.system(size: 18, weight: .medium))
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("任務提醒")
                                    .font(AppConstants.Fonts.primaryContent)
                                    .foregroundColor(AppConstants.Colors.primaryText)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: .constant(true))
                            .toggleStyle(SwitchToggleStyle(tint: AppConstants.Colors.accent))
                    }
                }
            }
        }
    }
    
    // MARK: - Data Management Section
    
    private var dataManagementSection: some View {
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            sectionHeader(title: "資料管理", icon: "folder.fill")
            
            SettingsCardView {
                VStack(spacing: AppConstants.Spacing.contentSpacing) {
                    Button(action: {
                        taskService.clearCompletedTasks()
                    }) {
                        SettingsRowView(
                            title: "清除已完成任務",
                            subtitle: "移除所有已完成的任務",
                            icon: "trash",
                            titleColor: taskService.completedTasks.isEmpty ? AppConstants.Colors.secondaryText : AppConstants.Colors.destructive,
                            showChevron: false
                        )
                    }
                    .disabled(taskService.completedTasks.isEmpty)
                    
                    Divider()
                        .background(AppConstants.Colors.border)
                    
                    Button(action: {
                        showingClearTasksAlert = true
                    }) {
                        SettingsRowView(
                            title: "清除所有任務",
                            subtitle: "永久刪除所有任務資料",
                            icon: "trash.fill",
                            titleColor: taskService.tasks.isEmpty ? AppConstants.Colors.secondaryText : AppConstants.Colors.destructive,
                            showChevron: false
                        )
                    }
                    .disabled(taskService.tasks.isEmpty)
                    
                    Divider()
                        .background(AppConstants.Colors.border)
                    
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        SettingsRowView(
                            title: "重置統計資料",
                            subtitle: "清除所有使用統計",
                            icon: "arrow.clockwise",
                            titleColor: AppConstants.Colors.destructive,
                            showChevron: false
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            sectionHeader(title: "關於", icon: "info.circle.fill")
            
            SettingsCardView {
                VStack(spacing: AppConstants.Spacing.contentSpacing) {
                    SettingsRowView(
                        title: "Focus",
                        subtitle: "版本 \(AppConstants.appVersion)",
                        icon: "app.badge",
                        showChevron: false
                    )
                    
                    Divider()
                        .background(AppConstants.Colors.border)
                    
                    SettingsRowView(
                        title: "開發工具",
                        subtitle: "使用 Claude Code 開發",
                        icon: "hammer",
                        showChevron: false
                    )
                    
                    Divider()
                        .background(AppConstants.Colors.border)
                    
                    SettingsRowView(
                        title: "設計理念",
                        subtitle: "專注單一任務的極簡工具",
                        icon: "target",
                        showChevron: false
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            HStack(spacing: AppConstants.Spacing.elementSpacing) {
                Image(systemName: icon)
                    .foregroundColor(AppConstants.Colors.accent)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.primaryText)
            }
            
            Spacer()
        }
    }
}

// MARK: - Supporting Views

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.elementSpacing) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppConstants.Colors.accent)
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryText)
                
                Text(title)
                    .font(AppConstants.Fonts.secondaryContent)
                    .foregroundColor(AppConstants.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppConstants.Spacing.cardPadding)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.card)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

struct SettingsCardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(AppConstants.Spacing.cardPadding)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.card)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

struct SettingsRowView: View {
    let title: String
    let subtitle: String
    let icon: String
    let titleColor: Color
    let showChevron: Bool
    
    init(title: String, subtitle: String, icon: String, titleColor: Color = AppConstants.Colors.primaryText, showChevron: Bool = true) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.titleColor = titleColor
        self.showChevron = showChevron
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.elementSpacing) {
            Image(systemName: icon)
                .foregroundColor(AppConstants.Colors.accent)
                .font(.system(size: 18, weight: .medium))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppConstants.Fonts.primaryContent)
                    .foregroundColor(titleColor)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppConstants.Fonts.secondaryContent)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppConstants.Colors.secondaryText)
                    .font(.system(size: 14, weight: .medium))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}