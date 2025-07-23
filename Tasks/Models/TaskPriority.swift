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
            return "低"
        case .normal:
            return "普通"
        case .high:
            return "高"
        case .urgent:
            return "緊急"
        }
    }
    
    var sortOrder: Int {
        return self.rawValue
    }
}