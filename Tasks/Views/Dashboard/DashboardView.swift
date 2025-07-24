//
//  DashboardView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - 簡潔的應用標題
            VStack(spacing: AppConstants.Spacing.elementSpacing) {
                Text("Focus")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .padding(.top, 60)
            }
            
            Spacer()
            
            // Main Content Area
            VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                if let currentTask = viewModel.currentTask {
                    // Current Task Card - 更卡片化的設計
                    VStack(spacing: AppConstants.Spacing.contentSpacing) {
                        // Swipeable Task Content Card
                        SwipeableFocusCard(
                            task: currentTask,
                            onComplete: {
                                withAnimation(AppConstants.Animation.stateChange) {
                                    viewModel.markCurrentTaskAsCompleted()
                                }
                            },
                            onDefer: {
                                withAnimation(AppConstants.Animation.stateChange) {
                                    viewModel.deferCurrentTask()
                                }
                            }
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                } else if viewModel.hasIncompleteTasks {
                    // Loading state
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.accent))
                    
                } else {
                    // All tasks completed state - 更簡潔
                    VStack(spacing: AppConstants.Spacing.contentSpacing) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80, weight: .light))
                            .foregroundColor(AppConstants.Colors.accent)
                        
                        Text("全部完成！")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("今天的任務都完成了")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            Spacer()
            
            // Action Buttons - 只在有任務時顯示
            if viewModel.currentTask != nil {
                VStack(spacing: 12) {
                    // Mark as Done Button
                    Button(action: {
                        withAnimation(AppConstants.Animation.stateChange) {
                            viewModel.markCurrentTaskAsCompleted()
                        }
                    }) {
                        Text("Mark as Done")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .cornerRadius(16)
                    }
                    .disabled(viewModel.isLoading)
                    .scaleEffect(viewModel.isLoading ? 0.98 : 1.0)
                    .animation(AppConstants.Animation.buttonPress, value: viewModel.isLoading)
                    
                    // Defer Button
                    Button(action: {
                        withAnimation(AppConstants.Animation.stateChange) {
                            viewModel.deferCurrentTask()
                        }
                    }) {
                        Text("Defer")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppConstants.Colors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.clear)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppConstants.Colors.border, lineWidth: 1)
                            )
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.bottom, 40)
            }
        }
        .padding(.horizontal, 24)
        .background(AppConstants.Colors.background)
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Swipeable Focus Card

struct SwipeableFocusCard: View {
    let task: Task
    let onComplete: () -> Void
    let onDefer: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var showingFullDescription = false
    
    var body: some View {
        ZStack {
            // Background actions
            if abs(dragOffset.width) > 50 {
                HStack {
                    if dragOffset.width > 50 {
                        // Complete action (right swipe)
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                            Text("完成")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 40)
                    } else if dragOffset.width < -50 {
                        // Defer action (left swipe)
                        VStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                            Text("延期")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 40)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(dragOffset.width > 50 ? .green : .orange)
                )
            }
            
            // Main task card
            VStack(spacing: AppConstants.Spacing.contentSpacing) {
                // Priority indicator (if high/urgent)
                if task.priority == .high || task.priority == .urgent {
                    HStack {
                        Text(task.priority.displayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(task.priority == .urgent ? Color.red : Color.orange)
                            .cornerRadius(12)
                        
                        Spacer()
                    }
                }
                
                // Task Title - 更突出
                Text(task.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppConstants.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                
                // Task Description (if available)
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 20)
                }
                
                // Due Date (if set) - 更subtle
                if let dueDate = task.dueDate {
                    Text(dueDate.shortDateString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(dueDate.daysFromNow() <= 1 && dueDate.daysFromNow() >= 0 ? Color.red : AppConstants.Colors.secondaryText)
                        .padding(.top, 8)
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppConstants.Colors.border, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 120
                        
                        if value.translation.width > threshold {
                            // Complete task
                            onComplete()
                        } else if value.translation.width < -threshold {
                            // Defer task
                            onDefer()
                        }
                        
                        // Reset position
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
            )
            .onLongPressGesture {
                if let description = task.description, !description.isEmpty {
                    showingFullDescription = true
                }
            }
        }
        .alert("任務詳細描述", isPresented: $showingFullDescription) {
            Button("確定", role: .cancel) { }
        } message: {
            if let description = task.description {
                Text(description)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TabView {
        DashboardView()
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
    }
}