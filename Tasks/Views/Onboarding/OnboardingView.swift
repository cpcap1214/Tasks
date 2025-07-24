//
//  OnboardingView.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showingContent = false
    @State private var titleOffset: CGFloat = 50
    @State private var subtitleOffset: CGFloat = 80
    @State private var imageScale: CGFloat = 0.7
    @State private var buttonOpacity: Double = 0
    
    let onComplete: () -> Void
    
    private let pages = [
        OnboardingPage(
            title: "專注於一個任務",
            subtitle: "一次只顯示一個任務\n減少干擾，提升專注力",
            systemImage: "target",
            backgroundColor: Color.blue.opacity(0.1)
        ),
        OnboardingPage(
            title: "簡單的操作方式",
            subtitle: "右滑完成任務\n左滑延期處理",
            systemImage: "hand.draw",
            backgroundColor: Color.green.opacity(0.1)
        ),
        OnboardingPage(
            title: "管理所有任務",
            subtitle: "在「所有任務」頁面\n查看和編輯完整清單",
            systemImage: "list.bullet",
            backgroundColor: Color.purple.opacity(0.1)
        ),
        OnboardingPage(
            title: "開始使用 Focus",
            subtitle: "讓我們創建您的第一個任務\n開始專注的工作體驗",
            systemImage: "checkmark.circle",
            backgroundColor: AppConstants.Colors.accent.opacity(0.1)
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("跳過") {
                            completeOnboarding()
                        }
                        .font(AppConstants.Fonts.secondaryContent)
                        .foregroundColor(AppConstants.Colors.secondaryText)
                        .padding(.trailing, AppConstants.Spacing.pageMargin)
                        .padding(.top, 16)
                    }
                }
                
                // Content area
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isActive: index == currentPage,
                            geometry: geometry
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Page indicator and navigation
                VStack(spacing: AppConstants.Spacing.sectionSpacing) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? AppConstants.Colors.accent : AppConstants.Colors.secondaryText.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button("上一步") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                }
                            }
                            .font(AppConstants.Fonts.button)
                            .foregroundColor(AppConstants.Colors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                                    .stroke(AppConstants.Colors.border, lineWidth: 1)
                            )
                            .cornerRadius(AppConstants.CornerRadius.button)
                        }
                        
                        Button(currentPage == pages.count - 1 ? "開始使用" : "下一步") {
                            if currentPage == pages.count - 1 {
                                completeOnboarding()
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                        }
                        .font(AppConstants.Fonts.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppConstants.Colors.accent)
                        .cornerRadius(AppConstants.CornerRadius.button)
                    }
                    .padding(.horizontal, AppConstants.Spacing.pageMargin)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(AppConstants.Colors.background)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func completeOnboarding() {
        // Mark as completed and call completion handler
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.hasLaunchedBefore)
        onComplete()
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    let geometry: GeometryProxy
    
    @State private var titleOffset: CGFloat = 50
    @State private var subtitleOffset: CGFloat = 80
    @State private var imageScale: CGFloat = 0.7
    @State private var backgroundScale: CGFloat = 0.8
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Background circle with animation
            ZStack {
                Circle()
                    .fill(page.backgroundColor)
                    .frame(width: 280, height: 280)
                    .scaleEffect(backgroundScale)
                    .blur(radius: 20)
                
                // Main icon
                Image(systemName: page.systemImage)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(AppConstants.Colors.accent)
                    .scaleEffect(imageScale)
            }
            .frame(height: 320)
            
            Spacer().frame(height: 60)
            
            // Title
            Text(page.title)
                .font(AppConstants.Fonts.largeTitle)
                .foregroundColor(AppConstants.Colors.primaryText)
                .multilineTextAlignment(.center)
                .offset(y: titleOffset)
                .opacity(titleOffset == 0 ? 1 : 0)
            
            Spacer().frame(height: 20)
            
            // Subtitle
            Text(page.subtitle)
                .font(AppConstants.Fonts.secondaryContent)
                .foregroundColor(AppConstants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .offset(y: subtitleOffset)
                .opacity(subtitleOffset == 0 ? 1 : 0)
                .padding(.horizontal, AppConstants.Spacing.pageMargin)
            
            Spacer()
        }
        .onChange(of: isActive) { active in
            if active {
                animateIn()
            } else {
                animateOut()
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
            backgroundScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            imageScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            titleOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            subtitleOffset = 0
        }
    }
    
    private func animateOut() {
        titleOffset = 50
        subtitleOffset = 80
        imageScale = 0.7
        backgroundScale = 0.8
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let backgroundColor: Color
}

// MARK: - Preview

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}