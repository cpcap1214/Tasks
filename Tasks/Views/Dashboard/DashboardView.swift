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
                        // Task Content Card
                        VStack(spacing: AppConstants.Spacing.contentSpacing) {
                            // Priority indicator (if high/urgent)
                            if currentTask.priority == .high || currentTask.priority == .urgent {
                                HStack {
                                    Text(currentTask.priority.displayName)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(currentTask.priority == .urgent ? Color.red : Color.orange)
                                        .cornerRadius(12)
                                    
                                    Spacer()
                                }
                            }
                            
                            // Task Title - 更突出
                            Text(currentTask.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppConstants.Colors.primaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .padding(.horizontal, 20)
                            
                            // Task Description (if available)
                            if let description = currentTask.description, !description.isEmpty {
                                Text(description)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(AppConstants.Colors.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .padding(.horizontal, 20)
                            }
                            
                            // Due Date (if set) - 更subtle
                            if let dueDate = currentTask.dueDate {
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
            if let currentTask = viewModel.currentTask {
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