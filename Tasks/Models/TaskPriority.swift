//
//  TaskPriority.swift
//  Tasks
//
//  Created by Claude Code on 2025/7/23.
//

import Foundation

enum TaskPriority: Int, CaseIterable, Codable {
    case low = 1
    case normal = 2
    case high = 3
    case urgent = 4
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }
    
    var sortOrder: Int {
        return self.rawValue
    }
}