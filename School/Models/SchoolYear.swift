//
//  SchoolYear.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation

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
    
    var description: String {
        switch self {
        case .traditional:
            return "Traditionelles System: 1+ ist die beste Note, 6 die schlechteste"
        case .points:
            return "Punktesystem: 15 Punkte ist die beste Note, 0 die schlechteste"
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
    
    /// Display format with grading system: "2024/2025 (Noten)"
    var displayNameWithSystem: String {
        return "\(displayName) (\(gradingSystem.displayName))"
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
    
    /// Generate all available school years for picker (2000/2001 to 2099/2100)
    /// Debug: Returns school years with saved grading systems from UserDefaults
    static var allAvailableYears: [SchoolYear] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear-10...currentYear).map { year in
            let savedSystem = UserDefaults.standard.gradingSystem(forSchoolYear: year) ?? .traditional
            return SchoolYear(startYear: year, gradingSystem: savedSystem)
        }
    }
}

extension SchoolYear: Comparable {
    static func < (lhs: SchoolYear, rhs: SchoolYear) -> Bool {
        return lhs.startYear < rhs.startYear
    }
}

// MARK: - UserDefaults Extensions for Grading System Persistence

extension UserDefaults {
    
    /// Get grading system for a specific school year
    /// Debug: Returns saved grading system or nil if not set
    func gradingSystem(forSchoolYear startYear: Int) -> GradingSystem? {
        let key = "gradingSystem_\(startYear)"
        guard let systemString = string(forKey: key) else { return nil }
        return GradingSystem(rawValue: systemString)
    }
    
    /// Set grading system for a specific school year
    /// Debug: Saves grading system choice persistently
    func setGradingSystem(_ system: GradingSystem, forSchoolYear startYear: Int) {
        let key = "gradingSystem_\(startYear)"
        set(system.rawValue, forKey: key)
        print("Debug: Saved grading system '\(system.displayName)' for school year \(startYear)/\(startYear + 1)")
    }
    
    /// Check if a school year has any saved grading system setting
    /// Debug: Used to determine if we should allow changing the system
    func hasGradingSystemSetting(forSchoolYear startYear: Int) -> Bool {
        let key = "gradingSystem_\(startYear)"
        return object(forKey: key) != nil
    }
} 
