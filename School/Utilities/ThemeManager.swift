//
//  ThemeManager.swift
//  School
//
//  Created by Antigravity on 12.01.26.
//

import SwiftUI
import Observation

/// Manages the app's global theme and accent color
/// Debug: Synchronizes the app-wide tint color with the current grade average performance
@Observable
class ThemeManager {
    static let shared = ThemeManager()
    
    /// Current app-wide accent color
    /// Debug: Defaults to standard iOS blue if no grades are available
    var accentColor: Color = .blue
    
    /// Initializer
    private init() {}
    
    /// Update the global accent color based on the current average
    /// - Parameters:
    ///   - average: The calculated grade average
    ///   - system: The current grading system
    func update(average: Double?, system: GradingSystem) {
        if let average = average {
            // Debug: Map the grade performance to its corresponding color
            let newColor = GradingSystemHelpers.gradeColor(for: average, system: system)
            
            // Debug: Only update if the color actually changed to prevent unnecessary re-renders
            if accentColor != newColor {
                accentColor = newColor
                debugLog(" App accent color updated to \(newColor) based on average \(average)")
            }
        } else {
            // Debug: Fallback to blue if no grades exist
            if accentColor != .blue {
                accentColor = .blue
                debugLog(" App accent color reset to default blue")
            }
        }
    }
}
