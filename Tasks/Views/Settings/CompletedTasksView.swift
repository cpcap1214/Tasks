//
//  CompletedTasksView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/25.
//

import SwiftUI

struct CompletedTasksView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean white background
                Color.white
                    .ignoresSafeArea()
                
                if viewModel.doneThisWeek.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Completed tasks list
                    completedTasksList
                }
            }
            .navigationTitle("已完成任務")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Completed Tasks List
    
    private var completedTasksList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.doneThisWeek) { task in
                    CompletedTaskCard(task: task)
                }
                
                // Add some bottom padding
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("尚無已完成任務")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("完成任務後將會在此顯示")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Completed Task Card

struct CompletedTaskCard: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 16) {
            // Completed checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.green)
            
            // Task Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .strikethrough()
                    .lineLimit(2)
                
                // Description
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.8))
                        .lineLimit(2)
                }
                
                // Completion date
                if let completedAt = task.completedAt {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text("完成於 \(formatCompletionDate(completedAt))")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.green.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(
                    color: .black.opacity(0.04),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Helper Functions

private func formatCompletionDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    let calendar = Calendar.current
    
    if calendar.isDateInToday(date) {
        formatter.dateFormat = "今天 HH:mm"
    } else if calendar.isDateInYesterday(date) {
        formatter.dateFormat = "昨天 HH:mm"
    } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
        formatter.dateFormat = "EEEE HH:mm"
    } else {
        formatter.dateFormat = "M/d HH:mm"
    }
    
    return formatter.string(from: date)
}

// MARK: - Preview

#Preview {
    CompletedTasksView()
        .preferredColorScheme(.light)
}