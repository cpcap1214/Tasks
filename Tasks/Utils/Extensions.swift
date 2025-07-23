//
//  Extensions.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import SwiftUI
import Foundation

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    func daysFromNow() -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
    
    var relativeString: String {
        if isToday {
            return "Today"
        } else if isTomorrow {
            return "Tomorrow"
        } else if isYesterday {
            return "Yesterday"
        } else {
            let days = daysFromNow()
            if days > 0 {
                return "in \(days) days"
            } else {
                return "\(-days) days ago"
            }
        }
    }
    
    var shortDateString: String {
        let formatter = DateFormatter()
        if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
        }
        return formatter.string(from: self)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .padding(AppConstants.Spacing.cardPadding)
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.CornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.card)
                    .stroke(AppConstants.Colors.border, lineWidth: 0.5)
            )
    }
    
    func buttonStyle(isSecondary: Bool = false) -> some View {
        self
            .font(AppConstants.Fonts.button)
            .foregroundColor(isSecondary ? AppConstants.Colors.primaryText : AppConstants.Colors.background)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isSecondary ? Color.clear : AppConstants.Colors.accent)
            .cornerRadius(AppConstants.CornerRadius.button)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.button)
                    .stroke(AppConstants.Colors.border, lineWidth: isSecondary ? 1 : 0)
            )
    }
    
    func pressEffect() -> some View {
        self
            .scaleEffect(1.0)
            .animation(AppConstants.Animation.buttonPress, value: false)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - String Extensions

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isNotEmpty: Bool {
        return !self.trimmed.isEmpty
    }
}

// MARK: - Binding Extensions

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}