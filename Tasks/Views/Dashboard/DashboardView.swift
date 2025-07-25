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
                Text("專注")
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
                        HStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isLoading ? "處理中..." : "完成任務")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(viewModel.isLoading ? Color.black.opacity(0.7) : Color.black)
                        .cornerRadius(16)
                    }
                    .disabled(viewModel.isLoading)
                    .scaleEffect(viewModel.isLoading ? 0.95 : 1.0)
                    .opacity(viewModel.isLoading ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
                    
                    // Defer Button
                    Button(action: {
                        withAnimation(AppConstants.Animation.stateChange) {
                            viewModel.deferCurrentTask()
                        }
                    }) {
                        Text("稍後處理")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(viewModel.isLoading ? AppConstants.Colors.secondaryText : AppConstants.Colors.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.clear)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(viewModel.isLoading ? AppConstants.Colors.border.opacity(0.5) : AppConstants.Colors.border, lineWidth: 1)
                            )
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.6 : 1.0)
                    .scaleEffect(viewModel.isLoading ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
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
            // Background actions - 更早顯示預覽效果
            if abs(dragOffset.width) > 30 {
                HStack {
                    if dragOffset.width > 30 {
                        // Complete action (right swipe)
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: abs(dragOffset.width) > 60 ? 36 : 28))
                                .foregroundColor(.white)
                                .scaleEffect(abs(dragOffset.width) > 60 ? 1.1 : 1.0)
                            Text("完成")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(abs(dragOffset.width) > 50 ? 1.0 : 0.7)
                        }
                        .padding(.trailing, 40)
                        .animation(.easeOut(duration: 0.1), value: dragOffset.width)
                    } else if dragOffset.width < -30 {
                        // Defer action (left swipe)
                        VStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: abs(dragOffset.width) > 60 ? 36 : 28))
                                .foregroundColor(.white)
                                .scaleEffect(abs(dragOffset.width) > 60 ? 1.1 : 1.0)
                            Text("稍後處理")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .opacity(abs(dragOffset.width) > 50 ? 1.0 : 0.7)
                        }
                        .padding(.leading, 40)
                        .animation(.easeOut(duration: 0.1), value: dragOffset.width)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(dragOffset.width > 30 ? 
                              (dragOffset.width > 0 ? .green : .orange) : 
                              .clear)
                        .opacity(min(abs(dragOffset.width) / 100.0, 0.9))
                        .animation(.easeOut(duration: 0.1), value: dragOffset.width)
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
                        let threshold: CGFloat = 80  // 降低閾值使滑動更容易觸發
                        
                        if value.translation.width > threshold {
                            // Complete task with haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            onComplete()
                        } else if value.translation.width < -threshold {
                            // Defer task with haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            onDefer()
                        }
                        
                        // Reset position with spring animation
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
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