//
//  Priority.swift
//  TestViper
//
//  ╔══════════════════════════════════════════╗
//  ║  VIPER Layer: ENTITY (shared type)       ║
//  ╚══════════════════════════════════════════╝
//
//  Priority enum dùng chung cho TodoItem, ViewModel, và UI.
//  Codable để lưu vào UserDefaults.
//

import UIKit

// MARK: - Priority

enum Priority: String, Codable, CaseIterable {
    case high   = "high"
    case medium = "medium"
    case low    = "low"

    /// Text hiển thị đầy đủ (dùng trong cell badge, detail)
    var displayText: String {
        switch self {
        case .high:   return "🔴 Cao"
        case .medium: return "🟡 Trung bình"
        case .low:    return "🟢 Thấp"
        }
    }

    /// Text ngắn (dùng trong UISegmentedControl)
    var shortText: String {
        switch self {
        case .high:   return "Cao"
        case .medium: return "TB"
        case .low:    return "Thấp"
        }
    }

    /// Màu tương ứng từ design system
    var color: UIColor {
        switch self {
        case .high:   return AppTheme.Color.danger
        case .medium: return AppTheme.Color.warning
        case .low:    return AppTheme.Color.success
        }
    }

    /// Index để map sang/từ UISegmentedControl
    var segmentIndex: Int {
        switch self {
        case .high:   return 0
        case .medium: return 1
        case .low:    return 2
        }
    }

    static func from(segmentIndex: Int) -> Priority {
        switch segmentIndex {
        case 0: return .high
        case 1: return .medium
        default: return .low
        }
    }
}
