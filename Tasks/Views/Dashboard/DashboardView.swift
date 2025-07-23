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
        NavigationView {
            VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                // Header
                VStack(spacing: AppConstants.Spacing.elementSpacing) {
                    Text("Tasks")
                        .font(AppConstants.Fonts.largeTitle)
                        .foregroundColor(AppConstants.Colors.primaryText)
                    
                    Text(viewModel.dashboardMessage)
                        .font(AppConstants.Fonts.secondaryContent)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, AppConstants.Spacing.contentSpacing)
                
                Spacer()
                
                // Main Content
                if let currentTask = viewModel.currentTask {
                    // Current Task Display
                    TaskCardView(
                        task: currentTask,
                        onDone: {
                            withAnimation(AppConstants.Animation.stateChange) {
                                viewModel.markCurrentTaskAsCompleted()
                            }
                        },
                        onDefer: {
                            withAnimation(AppConstants.Animation.stateChange) {
                                viewModel.deferCurrentTask()
                            }
                        },
                        isLoading: viewModel.isLoading
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                } else if viewModel.hasIncompleteTasks {
                    // Loading state when we have tasks but none is current
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: AppConstants.Colors.accent))
                    
                } else {
                    // All tasks completed state
                    VStack(spacing: AppConstants.Spacing.contentSpacing) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64, weight: .light))
                            .foregroundColor(AppConstants.Colors.accent)
                        
                        Text("All Done!")
                            .font(AppConstants.Fonts.title)
                            .foregroundColor(AppConstants.Colors.primaryText)
                        
                        Text("You've completed everything for today.\nGreat job!")
                            .font(AppConstants.Fonts.secondaryContent)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
            .padding(.horizontal, AppConstants.Spacing.pageMargin)
            .background(AppConstants.Colors.background)
            .navigationBarHidden(true)
        }
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