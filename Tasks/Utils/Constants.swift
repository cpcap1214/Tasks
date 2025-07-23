//
//  Constants.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI

struct AppConstants {
    
    // MARK: - App Info
    
    static let appName = "Focus"
    static let appVersion = "1.0.0"
    
    // MARK: - Design System (Following DESIGN.md)
    
    struct Colors {
        // Light Mode Colors
        static let lightBackground = Color.white
        static let lightSecondaryBackground = Color(UIColor.systemGray6)
        static let lightCardBackground = Color.white
        static let lightPrimaryText = Color.black
        static let lightSecondaryText = Color.gray
        static let lightAccent = Color.black
        static let lightBorder = Color(UIColor.systemGray4)
        static let lightDestructive = Color.red
        
        // Dark Mode Colors
        static let darkBackground = Color(red: 0.11, green: 0.11, blue: 0.12)
        static let darkSecondaryBackground = Color(red: 0.17, green: 0.17, blue: 0.18)
        static let darkCardBackground = Color(red: 0.17, green: 0.17, blue: 0.18)
        static let darkPrimaryText = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let darkSecondaryText = Color(red: 0.64, green: 0.64, blue: 0.67)
        static let darkAccent = Color(red: 0.98, green: 0.98, blue: 0.98)
        static let darkBorder = Color(red: 0.27, green: 0.27, blue: 0.29)
        static let darkDestructive = Color(red: 1.0, green: 0.27, blue: 0.23)
        
        // Adaptive Colors (Using System Colors for simplicity)
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let cardBackground = Color(UIColor.systemBackground)
        static let primaryText = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let accent = Color(UIColor.label)
        static let border = Color(UIColor.separator)
        static let destructive = Color(UIColor.systemRed)
    }
    
    struct Fonts {
        // Following DESIGN.md font system
        static let largeTitle = Font.system(size: 24, weight: .bold)
        static let title = Font.system(size: 20, weight: .bold)
        static let sectionTitle = Font.system(size: 18, weight: .semibold)
        static let primaryContent = Font.system(size: 16, weight: .semibold)
        static let secondaryContent = Font.system(size: 14, weight: .medium)
        static let caption = Font.system(size: 13, weight: .regular)
        static let button = Font.system(size: 16, weight: .semibold)
        static let bigDisplay = Font.system(size: 48, weight: .bold)
        static let categoryDisplay = Font.system(size: 36, weight: .bold)
        static let smallLabel = Font.system(size: 12, weight: .semibold)
        static let iconText = Font.system(size: 10)
    }
    
    struct Spacing {
        static let pageMargin: CGFloat = 24
        static let sectionSpacing: CGFloat = 32
        static let contentSpacing: CGFloat = 16
        static let elementSpacing: CGFloat = 8
        static let cardPadding: CGFloat = 20
        static let cardVerticalPadding: CGFloat = 16
    }
    
    struct CornerRadius {
        static let card: CGFloat = 12
        static let largeCard: CGFloat = 16
        static let button: CGFloat = 12
        static let smallElement: CGFloat = 8
    }
    
    // MARK: - Animation
    
    struct Animation {
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let stateChange = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let pageTransition = SwiftUI.Animation.easeInOut(duration: 0.25)
    }
    
    // MARK: - Tab Bar
    
    enum TabItem: String, CaseIterable {
        case dashboard = "Dashboard"
        case allTasks = "All Tasks"
        case settings = "Settings"
        
        var systemImage: String {
            switch self {
            case .dashboard:
                return "house.fill"
            case .allTasks:
                return "list.bullet"
            case .settings:
                return "gearshape.fill"
            }
        }
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    // MARK: - User Defaults Keys
    
    struct UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let preferredSortMethod = "preferredSortMethod"
        static let maxTasksPerDay = "maxTasksPerDay"
        static let showCompletedTasks = "showCompletedTasks"
    }
}