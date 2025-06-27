//
//  SharedModels.swift
//  SchoolWidget
//
//  Created by Carl on 26.06.25.
//

import Foundation
import SwiftUI

// MARK: - Shared Models for Widget
// Debug: These are simplified versions of the main app models that can be used in widgets

/// Grading system types used in German schools
/// Debug: Traditional system (1-6, lower is better) vs Points system (0-15, higher is better)
enum GradingSystem: String, Codable, CaseIterable {
    case traditional = "traditional" // Debug: 1-6 system (1+ = 0.7 best, 6 = 6.0 worst)
    case points = "points"           // Debug: 0-15 system (15 = best, 0 = worst)
    
    var displayName: String {
        switch self {
        case .traditional:
            return "Noten (1-6)"
        case .points:
            return "Punkte (0-15)"
        }
    }
    
    /// Minimum grade value for this system
    var minValue: Double {
        switch self {
        case .traditional: return 0.7  // Debug: 1+ in traditional system
        case .points: return 0.0       // Debug: 0 points
        }
    }
    
    /// Maximum grade value for this system  
    var maxValue: Double {
        switch self {
        case .traditional: return 6.0  // Debug: 6 in traditional system
        case .points: return 15.0      // Debug: 15 points
        }
    }
}

/// Represents a German school year (e.g., 2024/2025) with grading system
struct SchoolYear: Hashable, Codable {
    
    let startYear: Int // 2024
    let endYear: Int   // 2025
    let gradingSystem: GradingSystem // Debug: Which grading system this year uses
    
    init(startYear: Int, gradingSystem: GradingSystem = .traditional) {
        self.startYear = startYear
        self.endYear = startYear + 1
        self.gradingSystem = gradingSystem
    }
    
    /// Display format: "2024/2025"
    var displayName: String {
        return "\(startYear)/\(endYear)"
    }
    
    /// Current school year based on German school calendar (starts in August)
    static var current: SchoolYear {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // German school year starts in August/September
        if month >= 8 {
            return SchoolYear(startYear: year)
        } else {
            return SchoolYear(startYear: year - 1)
        }
    }
}

/// Represents the two halves of a German school year
enum Semester: String, CaseIterable, Identifiable, Codable {
    case first = "1. Halbjahr"
    case second = "2. Halbjahr"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        return rawValue
    }
    
    /// Short display name
    var shortName: String {
        switch self {
        case .first: return "1. HJ"
        case .second: return "2. HJ"
        }
    }
}

// MARK: - Widget Helper Functions

/// Helper functions for working with different grading systems in widgets
/// Debug: Simplified version of GradingSystemHelpers for widget use
class WidgetGradingHelpers {
    
    // MARK: - Grade Display Functions
    
    /// Convert grade value to display text based on grading system
    /// Debug: Traditional system uses German notation (1+, 1, 1-), Points system shows plain numbers
    static func gradeDisplayText(for value: Double, system: GradingSystem) -> String {
        switch system {
        case .traditional:
            return traditionalGradeDisplayText(for: value)
        case .points:
            return pointsGradeDisplayText(for: value)
        }
    }
    
    /// Traditional system display (1+ to 6)
    private static func traditionalGradeDisplayText(for value: Double) -> String {
        switch value {
        case 0.7: return "1+"
        case 1.0: return "1"
        case 1.3: return "1-"
        case 1.7: return "2+"
        case 2.0: return "2"
        case 2.3: return "2-"
        case 2.7: return "3+"
        case 3.0: return "3"
        case 3.3: return "3-"
        case 3.7: return "4+"
        case 4.0: return "4"
        case 4.3: return "4-"
        case 4.7: return "5+"
        case 5.0: return "5"
        case 5.3: return "5-"
        case 5.7: return "6+"
        case 6.0: return "6"
        default: return String(format: "%.1f", value)
        }
    }
    
    /// Points system display (0 to 15)
    private static func pointsGradeDisplayText(for value: Double) -> String {
        // Debug: Check user setting for rounding point averages via App Group (default is true)
        let sharedDefaults = UserDefaults(suiteName: "group.de.designedbycarl.School")
        let shouldRound = sharedDefaults?.object(forKey: "roundPointAverages") as? Bool ?? true
        
        if shouldRound {
            let intValue = Int(value.rounded())
            return "\(intValue) P" // Debug: P for "Punkte" (Points)
        } else {
            return String(format: "%.1f P", value)
        }
    }
    
    // MARK: - Grade Color Functions
    
    /// Get color for grade value based on grading system
    /// Debug: Colors are optimized for each system's performance ranges
    static func gradeColor(for value: Double, system: GradingSystem) -> Color {
        switch system {
        case .traditional:
            return traditionalGradeColor(for: value)
        case .points:
            return pointsGradeColor(for: value)
        }
    }
    
    /// Traditional system colors (0.7 = green best, 6.0 = pink worst)
    private static func traditionalGradeColor(for value: Double) -> Color {
        switch value {
        case 0.7..<1.7: return .green    // Debug: Grade 1 range (excellent)
        case 1.7..<2.7: return .blue     // Debug: Grade 2 range (good)
        case 2.7..<3.7: return .cyan     // Debug: Grade 3 range (satisfactory)
        case 3.7..<4.7: return .orange   // Debug: Grade 4 range (sufficient)
        case 4.7..<5.7: return .red      // Debug: Grade 5 range (poor)
        case 5.7...6.0: return .pink     // Debug: Grade 6 range (insufficient)
        default: return .gray
        }
    }
    
    /// Points system colors (15 = green best, 0 = pink worst)
    private static func pointsGradeColor(for value: Double) -> Color {
        switch value {
        case 13...15: return .green      // Debug: 13-15 points (excellent)
        case 10..<13: return .blue       // Debug: 10-12 points (good)
        case 7..<10: return .cyan        // Debug: 7-9 points (satisfactory)
        case 4..<7: return .orange       // Debug: 4-6 points (sufficient)
        case 1..<4: return .red          // Debug: 1-3 points (poor)
        case 0..<1: return .pink         // Debug: 0 points (insufficient)
        default: return .gray
        }
    }
}

// MARK: - Compatibility Bridge

/// Compatibility bridge to use main app's GradingSystemHelpers in widget
/// Debug: This allows the widget to use the same helper functions as the main app
typealias GradingSystemHelpers = WidgetGradingHelpers 