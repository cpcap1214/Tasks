//
//  TaskCardView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct TaskCardView: View {
    let task: Task
    let onDone: () -> Void
    let onDefer: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.contentSpacing) {
            // Task Content
            VStack(spacing: AppConstants.Spacing.elementSpacing) {
                // Priority indicator (if high/urgent)
                if task.priority == .high || task.priority == .urgent {
                    HStack {
                        Circle()
                            .fill(task.priority == .urgent ? AppConstants.Colors.destructive : Color.yellow)
                            .frame(width: 8, height: 8)
                        
                        Text(task.priority.displayName)
                            .font(AppConstants.Fonts.smallLabel)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                        
                        Spacer()
                    }
                }
                
                // Task Title
                Text(task.title)
                    .font(AppConstants.Fonts.largeTitle)
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Task Description (if available)
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(AppConstants.Fonts.secondaryContent)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                
                // Due Date (if set)
                if let dueDate = task.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(AppConstants.Fonts.caption)
                        
                        Text(dueDate.shortDateString)
                            .font(AppConstants.Fonts.caption)
                        
                        if dueDate.daysFromNow() <= 3 && dueDate.daysFromNow() >= 0 {
                            Text("• \(dueDate.relativeString)")
                                .font(AppConstants.Fonts.caption)
                                .foregroundColor(dueDate.daysFromNow() <= 1 ? AppConstants.Colors.destructive : AppConstants.Colors.secondaryText)
                        }
                    }
                    .foregroundColor(AppConstants.Colors.secondaryText)
                }
            }
            .padding(.vertical, AppConstants.Spacing.contentSpacing)
            
            // Action Buttons
            VStack(spacing: AppConstants.Spacing.elementSpacing) {
                // Done Button
                Button(action: onDone) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.background))
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Text("完成")
                            .font(AppConstants.Fonts.button)
                    }
                    .foregroundColor(AppConstants.Colors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppConstants.Colors.accent)
                    .cornerRadius(AppConstants.CornerRadius.button)
                }
                .disabled(isLoading)
                .scaleEffect(isLoading ? 0.98 : 1.0)
                .animation(AppConstants.Animation.buttonPress, value: isLoading)
                
                // Defer Button
                Button(action: onDefer) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("延期")
                            .font(AppConstants.Fonts.button)
                    }
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .cornerRadius(AppConstants.CornerRadius.button)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                            .stroke(AppConstants.Colors.border, lineWidth: 1)
                    )
                }
                .disabled(isLoading)
                .scaleEffect(isLoading ? 0.98 : 1.0)
                .animation(AppConstants.Animation.buttonPress, value: isLoading)
            }
        }
        .padding(AppConstants.Spacing.cardPadding)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.largeCard)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.largeCard)
                .stroke(AppConstants.Colors.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        TaskCardView(
            task: Task(
                title: "Complete project wireframes",
                description: "Design the main screens for the mobile app including dashboard, task list, and settings",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
            ),
            onDone: {},
            onDefer: {},
            isLoading: false
        )
        .padding()
        
        TaskCardView(
            task: Task(
                title: "Review quarterly reports",
                priority: .urgent,
                dueDate: Date()
            ),
            onDone: {},
            onDefer: {},
            isLoading: true
        )
        .padding()
    }
    .background(AppConstants.Colors.secondaryBackground)
}