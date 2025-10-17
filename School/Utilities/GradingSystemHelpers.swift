//
//  GradingSystemHelpers.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import Foundation

/// Performance level enumeration for visual indicators
/// Debug: Used to categorize academic performance for UI elements like badges and colors
enum PerformanceLevel {
    case excellent, good, satisfactory, sufficient, poor, insufficient, none
    
    var title: String {
        switch self {
        case .excellent: return "Sehr gut"       // 1 (Sehr gut)
        case .good: return "Gut"                 // 2 (Gut)
        case .satisfactory: return "Befriedigend" // 3 (Befriedigend)
        case .sufficient: return "Ausreichend"    // 4 (Ausreichend)
        case .poor: return "Mangelhaft"          // 5 (Mangelhaft)
        case .insufficient: return "Ungenügend"   // 6 (Ungenügend)
        case .none: return "Keine Noten"
        }
    }
    
    var icon: String {
        switch self {
        case .excellent: return "star.fill"
        case .good: return "hand.thumbsup.fill"
        case .satisfactory: return "checkmark.circle.fill"
        case .sufficient: return "minus.circle.fill"
        case .poor: return "exclamationmark.circle.fill"
        case .insufficient: return "xmark.circle.fill"
        case .none: return "questionmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .excellent: return .green
        case .good: return .blue
        case .satisfactory: return .cyan
        case .sufficient: return .orange
        case .poor: return .red
        case .insufficient: return .pink
        case .none: return .gray
        }
    }
}

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
    /// Debug: Ranges aligned with traditional system equivalents to maintain color consistency
    private static func pointsGradeColor(for value: Double) -> Color {
        switch value {
        case 12...15: return .green      // Debug: 12-15 points (excellent = 1+ to 1-)
        case 9..<12: return .blue        // Debug: 9-11 points (good = 2+ to 2-)
        case 6..<9: return .cyan         // Debug: 6-8 points (satisfactory = 3+ to 3-)
        case 3..<6: return .orange       // Debug: 3-5 points (sufficient = 4+ to 4-)
        case 0.001..<3: return .red      // Debug: 1-2 points (poor = 5+ to 5-)
        case 0...0: return .pink         // Debug: 0 points (insufficient = 6)
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
    
    /// Get grade values organized in rows for final grade selection (only full grades for traditional system)
    /// Debug: Traditional system: 2 rows of 3 full grades (1-6) without plus/minus variants, Points system: same as getGradeRows
    /// Returns: Array of (row identifier, array of (value, display, color))
    static func getFullGradeRowsForFinalGrade(for system: GradingSystem) -> [(Int, [(value: Double, display: String, color: Color)])] {
        switch system {
        case .traditional:
            // Debug: Organize in 2 rows with 3 grades each for compact display, each with individual color
            return [
                (1, [
                    (1.0, "1", .green),
                    (2.0, "2", .blue),
                    (3.0, "3", .cyan)
                ]),
                (2, [
                    (4.0, "4", .orange),
                    (5.0, "5", .red),
                    (6.0, "6", .pink)
                ])
            ]
        case .points:
            // For points system, return all values as final grades can be any point value
            return [
                (1, [
                    (15.0, "15 P", .green),
                    (14.0, "14 P", .green),
                    (13.0, "13 P", .green),
                    (12.0, "12 P", .green)
                ]),
                (2, [
                    (11.0, "11 P", .blue),
                    (10.0, "10 P", .blue),
                    (9.0, "9 P", .blue),
                    (8.0, "8 P", .blue)
                ]),
                (3, [
                    (7.0, "7 P", .cyan),
                    (6.0, "6 P", .cyan),
                    (5.0, "5 P", .cyan),
                    (4.0, "4 P", .cyan)
                ]),
                (4, [
                    (3.0, "3 P", .orange),
                    (2.0, "2 P", .orange),
                    (1.0, "1 P", .orange),
                    (0.0, "0 P", .orange)
                ])
            ]
        }
    }
    
    // MARK: - Performance Evaluation Functions
    
    /// Get performance level based on overall average and grading system
    /// Debug: Returns structured performance level for UI indicators and badges
    static func getPerformanceLevel(for average: Double, system: GradingSystem) -> PerformanceLevel {
        switch system {
        case .traditional:
            return getTraditionalPerformanceLevel(for: average)
        case .points:
            return getPointsPerformanceLevel(for: average)
        }
    }
    
    /// Traditional system performance levels (lower values = better)
    /// Debug: Angepasst, um konsistent mit den Notenstufen des deutschen Schulsystems zu sein
    private static func getTraditionalPerformanceLevel(for average: Double) -> PerformanceLevel {
        switch average {
        case 0.7..<1.7: return .excellent    // 1+ bis 1-: Sehr gut
        case 1.7..<2.7: return .good         // 2+ bis 2-: Gut
        case 2.7..<3.7: return .satisfactory // 3+ bis 3-: Befriedigend
        case 3.7..<4.7: return .sufficient   // 4+ bis 4-: Ausreichend
        case 4.7..<5.7: return .poor         // 5+ bis 5-: Mangelhaft
        case 5.7...6.0: return .insufficient // 6: Ungenügend
        default: return .none
        }
    }
    
    /// Points system performance levels (higher values = better)
    /// Debug: Angepasst, um konsistent mit den traditionellen Notenstufen zu sein
    private static func getPointsPerformanceLevel(for average: Double) -> PerformanceLevel {
        switch average {
        case 12...15: return .excellent     // 15-12 Punkte: Sehr gut (1+ bis 1-)
        case 9..<12: return .good           // 11-9 Punkte: Gut (2+ bis 2-)
        case 6..<9: return .satisfactory    // 8-6 Punkte: Befriedigend (3+ bis 3-)
        case 3..<6: return .sufficient      // 5-3 Punkte: Ausreichend (4+ bis 4-)
        case 0.001..<3: return .poor        // 2-1 Punkte: Mangelhaft (5+ bis 5-)
        case 0...0: return .insufficient    // 0 Punkte: Ungenügend (6)
        default: return .none
        }
    }
    
    /// Get performance message based on overall average and grading system
    /// Debug: Adapted messages for different systems since scales are inverted
    static func getPerformanceMessage(for average: Double?, system: GradingSystem) -> String {
        guard let average = average else {
            return "Hey, lass uns gemeinsam durchstarten! 🚀"
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
            let messages = [
                "Hervorragend! Du bist ein echtes Talent! ⭐",
                "Fantastische Leistung! Du zeigst, was in dir steckt! 🌟"
            ]
            return messages.randomElement() ?? messages[0]
        case 2.5..<3.5:
            let messages = [
                "Solide Arbeit! Mit etwas mehr Einsatz schaffst du noch mehr! 💪",
                "Guter Grundstein! Du bist auf dem richtigen Weg nach oben! 🚀"
            ]
            return messages.randomElement() ?? messages[0]
        case 3.5..<4.5:
            let messages = [
                "Du packst das! Jede Anstrengung zahlt sich aus! 🎯",
                "Bleib dran! Der Erfolg ist näher als du denkst! ⚡"
            ]
            return messages.randomElement() ?? messages[0]
        case 4.5...6.0:
            let messages = [
                "Jeder Anfang ist schwer! Du schaffst die Wende! 🔄",
                "Nicht aufgeben! In dir steckt mehr, als du glaubst! 💎"
            ]
            return messages.randomElement() ?? messages[0]
        default:
            let messages = [
                "Los geht's! Deine Erfolgsgeschichte beginnt jetzt! 🌅",
                "Auf zu neuen Höhen! Jede Note bringt dich weiter! 🎈"
            ]
            return messages.randomElement() ?? messages[0]
        }
    }
    
    /// Points system performance messages (higher values = better)
    private static func getPointsPerformanceMessage(for average: Double) -> String {
        switch average {
        case 12...15:
            let messages = [
                "Hervorragend! Du bist ein echtes Talent! ⭐",
                "Fantastische Leistung! Du zeigst, was in dir steckt! 🌟"
            ]
            return messages.randomElement() ?? messages[0]
        case 8..<12:
            let messages = [
                "Solide Arbeit! Mit etwas mehr Einsatz schaffst du noch mehr! 💪",
                "Guter Grundstein! Du bist auf dem richtigen Weg nach oben! 🚀"
            ]
            return messages.randomElement() ?? messages[0]
        case 4..<8:
            let messages = [
                "Du packst das! Jede Anstrengung zahlt sich aus! 🎯",
                "Bleib dran! Der Erfolg ist näher als du denkst! ⚡️"
            ]
            return messages.randomElement() ?? messages[0]
        case 0..<4:
            let messages = [
                "Jeder Anfang ist schwer! Du schaffst die Wende! 🔄",
                "Nicht aufgeben! In dir steckt mehr, als du glaubst! 💎"
            ]
            return messages.randomElement() ?? messages[0]
        default:
            let messages = [
                "Los geht's! Deine Erfolgsgeschichte beginnt jetzt! 🌅",
                "Auf zu neuen Höhen! Jede Note bringt dich weiter! 🎈"
            ]
            return messages.randomElement() ?? messages[0]
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