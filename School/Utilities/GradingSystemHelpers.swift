//
//  GradingSystemHelpers.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import Foundation

/// Helper functions for working with different grading systems
/// Debug: Provides display, color, and validation functions for both traditional (1-6) and points (0-15) systems
class GradingSystemHelpers {
    
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
        // Debug: Check user setting for rounding point averages (default is true)
        let shouldRound = UserDefaults.standard.object(forKey: "roundPointAverages") as? Bool ?? true
        
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
    
    // MARK: - Grade Generation Functions
    
    /// Get all possible grade values for a grading system
    /// Debug: Used for generating grade picker buttons
    static func getAllGradeValues(for system: GradingSystem) -> [(value: Double, display: String, color: Color)] {
        switch system {
        case .traditional:
            return getTraditionalGradeValues()
        case .points:
            return getPointsGradeValues()
        }
    }
    
    /// Traditional system grade values organized by grade
    private static func getTraditionalGradeValues() -> [(value: Double, display: String, color: Color)] {
        let grades: [(Double, String)] = [
            (0.7, "1+"), (1.0, "1"), (1.3, "1-"),
            (1.7, "2+"), (2.0, "2"), (2.3, "2-"),
            (2.7, "3+"), (3.0, "3"), (3.3, "3-"),
            (3.7, "4+"), (4.0, "4"), (4.3, "4-"),
            (4.7, "5+"), (5.0, "5"), (5.3, "5-"),
            (5.7, "6+"), (6.0, "6")
        ]
        
        return grades.map { value, display in
            (value: value, display: display, color: traditionalGradeColor(for: value))
        }
    }
    
    /// Points system grade values (0-15)
    private static func getPointsGradeValues() -> [(value: Double, display: String, color: Color)] {
        return (0...15).map { points in
            let value = Double(points)
            let display = "\(points) P"
            let color = pointsGradeColor(for: value)
            return (value: value, display: display, color: color)
        }
    }
    
    /// Get grade values organized in rows for UI display
    /// Debug: Traditional system: 6 rows of 3 grades each, Points system: 4 rows of 4 points each
    static func getGradeRows(for system: GradingSystem) -> [(Int, [(value: Double, display: String)], Color)] {
        switch system {
        case .traditional:
            return [
                (1, [(0.7, "1+"), (1.0, "1"), (1.3, "1-")], .green),
                (2, [(1.7, "2+"), (2.0, "2"), (2.3, "2-")], .blue),
                (3, [(2.7, "3+"), (3.0, "3"), (3.3, "3-")], .cyan),
                (4, [(3.7, "4+"), (4.0, "4"), (4.3, "4-")], .orange),
                (5, [(4.7, "5+"), (5.0, "5"), (5.3, "5-")], .red),
                (6, [(5.7, "6+"), (6.0, "6")], .pink)
            ]
        case .points:
            return [
                (1, [(15.0, "15 P"), (14.0, "14 P"), (13.0, "13 P"), (12.0, "12 P")], .green),
                (2, [(11.0, "11 P"), (10.0, "10 P"), (9.0, "9 P"), (8.0, "8 P")], .blue),
                (3, [(7.0, "7 P"), (6.0, "6 P"), (5.0, "5 P"), (4.0, "4 P")], .cyan),
                (4, [(3.0, "3 P"), (2.0, "2 P"), (1.0, "1 P"), (0.0, "0 P")], .orange)
            ]
        }
    }
    
    // MARK: - Performance Evaluation Functions
    
    /// Get performance message based on overall average and grading system
    /// Debug: Adapted messages for different systems since scales are inverted
    static func getPerformanceMessage(for average: Double?, system: GradingSystem) -> String {
        guard let average = average else {
            return "Viel Erfolg und Gute Noten!"
        }
        
        switch system {
        case .traditional:
            return getTraditionalPerformanceMessage(for: average)
        case .points:
            return getPointsPerformanceMessage(for: average)
        }
    }
    
    /// Traditional system performance messages (lower values = better)
    private static func getTraditionalPerformanceMessage(for average: Double) -> String {
        switch average {
        case 0.7..<2.5:
            return "Sehr gut, weiter so!"
        case 2.5..<3.5:
            return "Nicht schlecht, aber noch Luft nach oben!"
        case 3.5..<4.5:
            return "Gib ein bisschen mehr Gas!"
        case 4.5...6.0:
            return "Das kannst du eigentlich besser!"
        default:
            return "Viel Erfolg und Gute Noten!"
        }
    }
    
    /// Points system performance messages (higher values = better)
    private static func getPointsPerformanceMessage(for average: Double) -> String {
        switch average {
        case 12...15:
            return "Sehr gut, weiter so!"
        case 8..<12:
            return "Nicht schlecht, aber noch Luft nach oben!"
        case 4..<8:
            return "Gib ein bisschen mehr Gas!"
        case 0..<4:
            return "Das kannst du eigentlich besser!"
        default:
            return "Viel Erfolg und Gute Noten!"
        }
    }
    
    // MARK: - Validation Functions
    
    /// Validate if a grade value is valid for the given grading system
    /// Debug: Used in grade input validation
    static func isValidGrade(_ value: Double?, for system: GradingSystem) -> Bool {
        guard let value = value else { return false }
        return value >= system.minValue && value <= system.maxValue
    }
    
    /// Get validation range description for display
    static func getValidationDescription(for system: GradingSystem) -> String {
        switch system {
        case .traditional:
            return "Noten zwischen 1+ (0,7) und 6 (6,0)"
        case .points:
            return "Punkte zwischen 0 und 15"
        }
    }
    
    // MARK: - Grade Conversion Functions
    
    /// Convert grade value from one system to another
    /// Debug: Handles conversion between traditional (1-6) and points (0-15) systems
    static func convertGrade(_ value: Double, from sourceSystem: GradingSystem, to targetSystem: GradingSystem) -> Double {
        // Debug: No conversion needed if systems are the same
        guard sourceSystem != targetSystem else { return value }
        
        if sourceSystem == .traditional && targetSystem == .points {
            return convertTraditionalToPoints(value)
        } else if sourceSystem == .points && targetSystem == .traditional {
            return convertPointsToTraditional(value)
        } else {
            // Debug: This should never happen due to the guard above
            return value
        }
    }
    
    /// Convert traditional grade (1-6 system) to points (0-15 system)
    /// Debug: 1+ (0.7) = 15 points (best), 6 (6.0) = 0 points (worst)
    private static func convertTraditionalToPoints(_ traditionalValue: Double) -> Double {
        switch traditionalValue {
        case 0.7: return 15.0  // 1+
        case 1.0: return 14.0  // 1
        case 1.3: return 13.0  // 1-
        case 1.7: return 12.0  // 2+
        case 2.0: return 11.0  // 2
        case 2.3: return 10.0  // 2-
        case 2.7: return 9.0   // 3+
        case 3.0: return 8.0   // 3
        case 3.3: return 7.0   // 3-
        case 3.7: return 6.0   // 4+
        case 4.0: return 5.0   // 4
        case 4.3: return 4.0   // 4-
        case 4.7: return 3.0   // 5+
        case 5.0: return 2.0   // 5
        case 5.3: return 1.0   // 5-
        case 5.7: return 0.0   // 6+
        case 6.0: return 0.0   // 6
        default:
            // Debug: For intermediate values, use linear interpolation
            let clampedValue = max(0.7, min(6.0, traditionalValue))
            // Map 0.7-6.0 to 15-0 linearly
            let normalizedValue = (clampedValue - 0.7) / (6.0 - 0.7)
            let pointsValue = 15.0 - (normalizedValue * 15.0)
            return max(0.0, min(15.0, round(pointsValue)))
        }
    }
    
    /// Convert points grade (0-15 system) to traditional (1-6 system)
    /// Debug: 15 points = 1+ (0.7), 0 points = 6 (6.0)
    private static func convertPointsToTraditional(_ pointsValue: Double) -> Double {
        let roundedPoints = Int(pointsValue.rounded())
        
        switch roundedPoints {
        case 15: return 0.7   // 1+
        case 14: return 1.0   // 1
        case 13: return 1.3   // 1-
        case 12: return 1.7   // 2+
        case 11: return 2.0   // 2
        case 10: return 2.3   // 2-
        case 9:  return 2.7   // 3+
        case 8:  return 3.0   // 3
        case 7:  return 3.3   // 3-
        case 6:  return 3.7   // 4+
        case 5:  return 4.0   // 4
        case 4:  return 4.3   // 4-
        case 3:  return 4.7   // 5+
        case 2:  return 5.0   // 5
        case 1:  return 5.3   // 5-
        case 0:  return 6.0   // 6
        default:
            // Debug: For out-of-range values, clamp and convert
            let clampedPoints = max(0.0, min(15.0, pointsValue))
            // Map 15-0 to 0.7-6.0 linearly
            let normalizedValue = (15.0 - clampedPoints) / 15.0
            let traditionalValue = 0.7 + (normalizedValue * (6.0 - 0.7))
            return max(0.7, min(6.0, traditionalValue))
        }
    }
    
    /// Get conversion preview message for user
    /// Debug: Shows what the conversion will do for user confirmation
    static func getConversionPreviewMessage(gradeCount: Int, from sourceSystem: GradingSystem, to targetSystem: GradingSystem) -> String {
        let fromName = sourceSystem.displayName
        let toName = targetSystem.displayName
        
        return "Alle \(gradeCount) Noten werden von \(fromName) zu \(toName) konvertiert.\n\nBeispiele:\n\(getConversionExamples(from: sourceSystem, to: targetSystem))"
    }
    
    /// Get conversion examples for user preview
    /// Debug: Shows specific conversion examples so user knows what to expect
    private static func getConversionExamples(from sourceSystem: GradingSystem, to targetSystem: GradingSystem) -> String {
        switch (sourceSystem, targetSystem) {
        case (.traditional, .points):
            return "1+ → 15 P, 2 → 11 P, 3 → 8 P, 4 → 5 P, 6 → 0 P"
        case (.points, .traditional):
            return "15 P → 1+, 11 P → 2, 8 P → 3, 5 P → 4, 0 P → 6"
        default:
            return ""
        }
    }
} 