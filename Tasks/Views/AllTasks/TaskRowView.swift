//
//  TaskRowView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggleCompletion: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.contentSpacing) {
            // Status Indicator
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(task.isCompleted ? AppConstants.Colors.accent : AppConstants.Colors.border)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                // Title and Status
                HStack {
                    Text(task.title)
                        .font(AppConstants.Fonts.primaryContent)
                        .foregroundColor(task.isCompleted ? AppConstants.Colors.secondaryText : AppConstants.Colors.primaryText)
                        .strikethrough(task.isCompleted)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Status badges
                    HStack(spacing: 4) {
                        if task.isDeferred {
                            Label("Deferred", systemImage: "clock.fill")
                                .font(AppConstants.Fonts.smallLabel)
                                .foregroundColor(AppConstants.Colors.secondaryText)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppConstants.Colors.secondaryBackground)
                                .cornerRadius(4)
                        }
                        
                        if task.priority == .high || task.priority == .urgent {
                            Circle()
                                .fill(task.priority == .urgent ? AppConstants.Colors.destructive : Color.yellow)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                // Description (if available)
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(AppConstants.Fonts.secondaryContent)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .lineLimit(1)
                }
                
                // Due Date and Creation Date
                HStack {
                    if let dueDate = task.dueDate {
                        Label(dueDate.shortDateString, systemImage: "calendar")
                            .font(AppConstants.Fonts.caption)
                            .foregroundColor(
                                dueDate.daysFromNow() <= 1 && dueDate.daysFromNow() >= 0 
                                ? AppConstants.Colors.destructive 
                                : AppConstants.Colors.secondaryText
                            )
                    }
                    
                    Spacer()
                    
                    Text("Created \(task.createdAt.shortDateString)")
                        .font(AppConstants.Fonts.caption)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            // Delete Action
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            
            // Edit Action
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit Task", systemImage: "pencil")
            }
            
            Button(action: onToggleCompletion) {
                Label(
                    task.isCompleted ? "Mark as Pending" : "Mark as Done",
                    systemImage: task.isCompleted ? "circle" : "checkmark.circle"
                )
            }
            
            Divider()
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete Task", systemImage: "trash")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        TaskRowView(
            task: Task(
                title: "Complete project wireframes",
                description: "Design the main screens for the mobile app",
                priority: .high,
                dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())
            ),
            onToggleCompletion: {},
            onEdit: {},
            onDelete: {}
        )
        
        Divider()
        
        TaskRowView(
            task: {
                var task = Task(
                    title: "Review quarterly reports",
                    priority: .urgent,
                    dueDate: Date()
                )
                task.markAsCompleted()
                return task
            }(),
            onToggleCompletion: {},
            onEdit: {},
            onDelete: {}
        )
        
        Divider()
        
        TaskRowView(
            task: {
                var task = Task(
                    title: "Schedule team meeting",
                    description: "Plan next sprint activities"
                )
                task.markAsDeferred()
                return task
            }(),
            onToggleCompletion: {},
            onEdit: {},
            onDelete: {}
        )
    }
    .padding()
    .background(AppConstants.Colors.background)
}